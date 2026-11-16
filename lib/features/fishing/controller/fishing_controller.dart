import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/data/local_store.dart';
import 'package:nad_parseta/data/permit_push.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/domain/rules.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';
import 'package:nad_parseta/features/fishing/controller/catalog_controller.dart';
import 'package:nad_parseta/features/fishing/controller/fishing_status.dart';

import 'fishing_sync_controller.dart';

final fishingRepositoryProvider =
    Provider.family<LocalFishingRepository, String>(
      (ref, ownerId) =>
          LocalFishingRepository(ownerId, ref.watch(snapshotStoreProvider)),
    );
final fishingProvider =
    StateNotifierProvider.family<
      FishingController,
      AsyncValue<AnglerSnapshot>,
      String
    >((ref, ownerId) => FishingController(ref, ownerId));

class FishingController extends StateNotifier<AsyncValue<AnglerSnapshot>> {
  FishingController(this._ref, this.ownerId) : super(const AsyncLoading()) {
    _repository = _ref.read(fishingRepositoryProvider(ownerId));
    _syncController = FishingSyncController(
      ref: _ref,
      ownerId: ownerId,
      repository: _repository,
      hasSnapshot: () => state.hasValue,
      requireOwner: _requireOwner,
      update: _update,
    );
    unawaited(load());
  }
  final Ref _ref;
  final String ownerId;
  late final LocalFishingRepository _repository;
  late final FishingSyncController _syncController;
  final Uuid _uuid = const Uuid();
  Future<void> load() async {
    state = await AsyncValue.guard(_repository.read);
    if (state.hasValue) unawaited(sync());
  }

  void _requireOwner() {
    final session = _ref.read(authProvider).valueOrNull;
    if (session?.user.id != ownerId || session?.user.role != UserRole.angler) {
      throw const AuthorizationFailure();
    }
  }

  SyncOperation _operation(
    String id,
    SyncKind kind,
    int revision, {
    required Json payload,
  }) => SyncOperation(
    id: _uuid.v4(),
    entityId: id,
    kind: kind,
    revision: revision,
    createdAt: DateTime.now(),
    payload: payload,
  );
  Future<AnglerSnapshot> _update(
    AnglerSnapshot Function(AnglerSnapshot) change,
  ) async {
    _requireOwner();
    final next = await _repository.update(change);
    state = AsyncData(next);
    return next;
  }

  Future<void> start(String placeId, {FishingPlace? newPlace}) async {
    final session = FishingSession(
      id: _uuid.v4(),
      ownerId: ownerId,
      startedAt: DateTime.now(),
      placeIds: [placeId],
      currentPlaceId: placeId,
    );
    await _update((s) {
      final places = _selectablePlaces(s, placeId, newPlace);
      if (s.activeSession != null) {
        throw const DomainFailure(FailureCode.closedSession);
      }
      return s.copyWith(
        places: places,
        sessions: [...s.sessions, session],
        activeSessionId: session.id,
      );
    });
    unawaited(sync());
  }

  List<FishingPlace> _selectablePlaces(
    AnglerSnapshot snapshot,
    String id,
    FishingPlace? newPlace,
  ) {
    if (snapshot.places.any((p) => p.id == id) ||
        legacyPlaces.any((p) => p.id == id)) {
      return snapshot.places;
    }
    if (newPlace == null || newPlace.id != id || newPlace.coordinates == null) {
      throw const DomainFailure(FailureCode.invalidMeasurement);
    }
    return [...snapshot.places, newPlace];
  }

  Future<void> selectPlace(String placeId, {FishingPlace? newPlace}) async {
    await _update((s) {
      final places = _selectablePlaces(s, placeId, newPlace);
      final current = s.activeSession;
      if (current == null) throw const DomainFailure(FailureCode.closedSession);
      final next = current.selectPlace(placeId);
      return s.copyWith(
        places: places,
        sessions: s.sessions.map((e) => e.id == next.id ? next : e).toList(),
      );
    });
    unawaited(sync());
  }

  Future<void> saveCatch(
    CatchEntry entry, {
    ({String? base64})? photoChange,
  }) async {
    final photoBytes = photoChange?.base64;
    if (photoBytes != null && !isCatchPhotoJpeg(base64Decode(photoBytes))) {
      throw const DomainFailure(FailureCode.invalidMeasurement);
    }
    RecordAchievement? achievement;
    await _update((s) {
      final session = s.activeSession;
      if (session == null) throw const DomainFailure(FailureCode.closedSession);
      validateCatch(entry, session);
      if (entry.caughtAt.isAfter(DateTime.now()) ||
          !_ref.read(speciesProvider).any((e) => e.id == entry.speciesId)) {
        throw const DomainFailure(FailureCode.invalidMeasurement);
      }
      achievement = compareRecord(entry, s.visibleCatches);
      final old = s.catches.where((e) => e.id == entry.id).firstOrNull;
      if (old?.syncedAt != null ||
          s.outbox.any(
            (op) => op.kind == SyncKind.catchEntry && op.entityId == entry.id,
          ) ||
          _ref.read(authProvider).valueOrNull?.user.registerEnabled != true) {
        throw const AuthorizationFailure();
      }
      final grams = entry.weightGrams;
      if (grams != null &&
          (grams / 1000).toString().replaceFirst(RegExp(r'\.0$'), '').length >
              5) {
        throw const DomainFailure(FailureCode.invalidMeasurement);
      }
      if (old != null && entry.revision != old.revision + 1) {
        throw const DomainFailure(FailureCode.invalidMeasurement);
      }
      return s.copyWith(
        catches: [...s.catches.where((e) => e.id != entry.id), entry],
        attachments: photoChange == null
            ? null
            : [
                ...s.attachments.where((photo) => photo.catchId != entry.id),
                if (photoBytes != null)
                  CatchAttachment(
                    id: _uuid.v4(),
                    catchId: entry.id,
                    base64Bytes: photoBytes,
                    createdAt: DateTime.now(),
                  ),
              ],
      );
    });
    _ref.read(achievementProvider.notifier).state =
        achievement?.isRecord == true ? achievement : null;
    unawaited(sync());
  }

  Future<void> deleteCatch(CatchEntry entry) async {
    await _update((s) {
      if (s.activeSession?.id != entry.sessionId) {
        throw const DomainFailure(FailureCode.closedSession);
      }
      final current = s.catches.firstWhere((fish) => fish.id == entry.id);
      if (current.syncedAt != null ||
          s.outbox.any(
            (op) => op.kind == SyncKind.catchEntry && op.entityId == entry.id,
          )) {
        throw const AuthorizationFailure();
      }
      final deleted = current.softDelete(DateTime.now());
      final photoIds = s.attachments
          .where((e) => e.catchId == entry.id)
          .map((e) => e.id)
          .toSet();
      return s.copyWith(
        catches: s.catches.map((e) => e.id == entry.id ? deleted : e).toList(),
        attachments: s.attachments
            .where((e) => !photoIds.contains(e.id))
            .toList(),
        outbox: s.outbox.where((e) => !photoIds.contains(e.entityId)).toList(),
      );
    });
    _ref.read(achievementProvider.notifier).state = null;
    unawaited(sync());
  }

  Future<void> end() async {
    await _update((s) {
      final session = s.activeSession;
      if (session == null) throw const DomainFailure(FailureCode.closedSession);
      final ended = session.end(DateTime.now());
      final api = _ref.read(anglerApiProvider);
      final entries = s.forSession(ended.id);
      final catchIds = entries.map((entry) => entry.id).toSet();
      if (entries.length > 250) {
        throw const DomainFailure(FailureCode.invalidMeasurement);
      }
      return s.copyWith(
        sessions: s.sessions.map((e) => e.id == ended.id ? ended : e).toList(),
        clearActiveSession: true,
        outbox: [
          ...s.outbox,
          _operation(
            ended.id,
            SyncKind.session,
            ended.revision,
            payload: {
              'id': ended.id,
              'startedAt': ended.startedAt.toUtc().toIso8601String(),
              'endedAt': ended.endedAt!.toUtc().toIso8601String(),
              'places': ended.placeIds
                  .map((id) => placeById(id, s.places).registerLocation)
                  .toSet()
                  .toList(),
              'catches': entries
                  .map(
                    (entry) => api.catchPayload(
                      entry,
                      placeById(entry.placeId, s.places).registerLocation,
                    ),
                  )
                  .toList(),
            },
          ),
          for (final photo in s.attachments)
            if (photo.syncedAt == null && catchIds.contains(photo.catchId))
              _operation(photo.id, SyncKind.attachment, 1, payload: const {}),
        ],
      );
    });
    _ref.read(achievementProvider.notifier).state = null;
    unawaited(sync());
  }

  Future<void> saveReminders(ReminderSettings settings) async {
    final api = _ref.read(anglerApiProvider);
    final enabled = settings.sevenDays || settings.oneDay || settings.expiryDay;
    final registration = enabled
        ? await PermitPush.registration(prompt: true)
        : null;
    if (enabled && registration == null) {
      throw const DomainFailure(FailureCode.pushUnavailable);
    }
    await _ref.read(authProvider.notifier).apiRequest((session) {
      if (session.user.id != ownerId) throw const AuthorizationFailure();
      return api.request(
        'PUT',
        'me/permit-reminders',
        session: session,
        body: {
          ...settings.toJson(),
          if (registration != null) 'registration': registration,
        },
      );
    });
    await _update((s) => s.copyWith(reminders: settings));
  }

  Future<void> sync() => _syncController.sync();
}
