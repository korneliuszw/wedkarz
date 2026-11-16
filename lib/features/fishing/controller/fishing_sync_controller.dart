import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nad_parseta/application/network_controller.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/data/angler_api.dart';
import 'package:nad_parseta/data/local_store.dart';
import 'package:nad_parseta/data/offline_inspection.dart';
import 'package:nad_parseta/data/permit_push.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';
import 'package:nad_parseta/features/fishing/controller/catalog_controller.dart';
import 'package:nad_parseta/features/fishing/controller/fishing_status.dart';
import 'package:nad_parseta/features/permits/service/inspection_provider.dart';

class FishingSyncController {
  FishingSyncController({
    required Ref ref,
    required this.ownerId,
    required LocalFishingRepository repository,
    required bool Function() hasSnapshot,
    required void Function() requireOwner,
    required Future<AnglerSnapshot> Function(
      AnglerSnapshot Function(AnglerSnapshot),
    )
    update,
  }) : _ref = ref,
       _repository = repository,
       _hasSnapshot = hasSnapshot,
       _requireOwner = requireOwner,
       _update = update;

  final Ref _ref;
  final String ownerId;
  final LocalFishingRepository _repository;
  final bool Function() _hasSnapshot;
  final void Function() _requireOwner;
  final Future<AnglerSnapshot> Function(AnglerSnapshot Function(AnglerSnapshot))
  _update;
  bool _syncing = false;
  bool _syncAgain = false;
  bool _loadedRemote = false;
  DateTime? _nextPushRefresh;

  Future<void> sync() async {
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    if (!_ref.read(networkProvider).online || !_hasSnapshot()) return;
    _syncing = true;
    _ref.read(syncingProvider.notifier).state = true;
    try {
      do {
        _syncAgain = false;
        FailureCode? photoFailure;
        final session = await _ref
            .read(authProvider.notifier)
            .requireOnline(role: UserRole.angler);
        if (session.user.id != ownerId) throw const AuthorizationFailure();
        final snapshot = await _repository.read();
        final operations = snapshot.outbox.toList()
          ..sort((a, b) {
            final priority = (a.kind == SyncKind.attachment ? 1 : 0).compareTo(
              b.kind == SyncKind.attachment ? 1 : 0,
            );
            return priority != 0
                ? priority
                : a.createdAt.compareTo(b.createdAt);
          });
        for (final operation in operations) {
          _requireOwner();
          if (!_ref.read(networkProvider).online) {
            throw const DomainFailure(FailureCode.offline);
          }
          final api = _ref.read(anglerApiProvider);
          if (operation.kind == SyncKind.attachment) {
            try {
              await _sendPhoto(api, operation, snapshot.attachments);
            } catch (error) {
              photoFailure ??= error is DomainFailure
                  ? error.code
                  : FailureCode.syncFailed;
            }
            continue;
          }
          String? signedReceipt;
          final receipt = await _ref.read(authProvider.notifier).apiRequest((
            current,
          ) {
            if (current.user.id != ownerId) {
              throw const AuthorizationFailure();
            }
            if (operation.kind != SyncKind.session) {
              return api.sendCatch(operation, current);
            }
            return api.submitFishingSession(operation, current).then((result) {
              signedReceipt = result.signed;
              return result.at;
            });
          });
          await _update(
            (s) => s.copyWith(
              outbox: s.outbox.where((e) => e.id != operation.id).toList(),
              lastSyncedAt: receipt,
              sessions: operation.kind != SyncKind.session
                  ? null
                  : s.sessions
                        .map(
                          (session) => session.id == operation.entityId
                              ? session.withReceipt(receipt, signedReceipt)
                              : session,
                        )
                        .toList(),
              catches: s.catches
                  .map(
                    (e) =>
                        (e.id == operation.entityId &&
                                e.revision == operation.revision) ||
                            (operation.kind == SyncKind.session &&
                                e.sessionId == operation.entityId &&
                                e.deletedAt == null)
                        ? e.acknowledge(receipt)
                        : e,
                  )
                  .toList(),
            ),
          );
        }
        final api = _ref.read(anglerApiProvider);
        if (!_loadedRemote) await _loadRemote(api);
        unawaited(_refreshInspection());
        unawaited(_refreshPush(api));
        _ref.read(syncFailureProvider.notifier).state = photoFailure;
      } while (_syncAgain && _ref.read(networkProvider).online);
    } catch (error) {
      _ref.read(syncFailureProvider.notifier).state = error is DomainFailure
          ? error.code
          : FailureCode.syncFailed;
    } finally {
      _syncing = false;
      _ref.read(syncingProvider.notifier).state = false;
    }
  }

  Future<void> _sendPhoto(
    AnglerApi api,
    SyncOperation operation,
    List<CatchAttachment> attachments,
  ) async {
    final photo = attachments
        .where((item) => item.id == operation.entityId)
        .firstOrNull;
    if (photo == null) throw const DomainFailure(FailureCode.storage);
    final receipt = await _ref.read(authProvider.notifier).apiRequest((
      session,
    ) {
      if (session.user.id != ownerId) throw const AuthorizationFailure();
      return api.sendCatchPhoto(photo, session);
    });
    await _update(
      (snapshot) => snapshot.copyWith(
        attachments: snapshot.attachments
            .map(
              (item) => item.id == photo.id ? item.acknowledge(receipt) : item,
            )
            .toList(),
        outbox: snapshot.outbox
            .where((item) => item.id != operation.id)
            .toList(),
        lastSyncedAt: receipt,
      ),
    );
  }

  Future<void> _refreshPush(AnglerApi api) async {
    if (!PermitPush.configured) return;
    final now = DateTime.now();
    if (_nextPushRefresh?.isAfter(now) == true) return;
    _nextPushRefresh = now.add(const Duration(minutes: 5));
    try {
      final registration = await PermitPush.registration();
      if (registration == null) return;
      _requireOwner();
      await _ref.read(authProvider.notifier).apiRequest((session) async {
        if (session.user.id != ownerId) throw const AuthorizationFailure();
        final settings = ReminderSettings.fromJson(
          await api.request('GET', 'me/permit-reminders', session: session),
        );
        if (!(settings.sevenDays || settings.oneDay || settings.expiryDay)) {
          return;
        }
        _requireOwner();
        await api.request(
          'PUT',
          'me/push-device',
          session: session,
          body: {'registration': registration},
        );
      });
      _nextPushRefresh = now.add(const Duration(hours: 1));
    } catch (_) {
      // Retry during a later foreground sync.
    }
  }

  Future<void> _refreshInspection() async {
    if (OfflineInspection.root.isEmpty) return;
    final inspection = _ref.read(offlineInspectionProvider);
    try {
      await _ref.read(authProvider.notifier).apiRequest((session) async {
        if (session.user.id != ownerId) throw const AuthorizationFailure();
        await inspection.ensureProvisioned(session);
      });
    } catch (_) {
      // Keep the last signed credential when refresh fails.
    }
  }

  Future<void> _loadRemote(AnglerApi api) async {
    final auth = _ref.read(authProvider.notifier);
    final species = await auth.apiRequest((session) {
      if (session.user.id != ownerId) throw const AuthorizationFailure();
      return api.fetchSpecies(session);
    });
    _requireOwner();
    final saved = await _ref
        .read(preferencesProvider)
        .setString(
          'species:${_ref.read(anglerApiUrlProvider)}',
          jsonEncode(
            species
                .map(
                  (fish) => {
                    'id': fish.id,
                    'name': fish.name,
                    'asset': fish.asset,
                  },
                )
                .toList(),
          ),
        );
    if (!saved) throw const DomainFailure(FailureCode.storage);
    _ref.read(speciesProvider.notifier).state = species;
    final history = await auth.apiRequest((session) {
      if (session.user.id != ownerId) throw const AuthorizationFailure();
      return api.catchHistory(session);
    });
    await _update((snapshot) => mergeCatchHistory(snapshot, ownerId, history));
    _loadedRemote = true;
  }
}
