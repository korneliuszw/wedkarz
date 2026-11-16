import 'package:nad_parseta/domain/model/json.dart';
import 'package:nad_parseta/features/fishing/model/fishing_place.dart';
import 'package:nad_parseta/features/fishing/model/fishing_session.dart';
import 'package:nad_parseta/features/fishing/model/catch_entry.dart';
import 'package:nad_parseta/features/fishing/model/catch_attachment.dart';
import 'package:nad_parseta/features/fishing/model/sync_operation.dart';
import 'package:nad_parseta/features/permits/model/reminder_settings.dart';

class AnglerSnapshot {
  AnglerSnapshot({
    List<FishingPlace> places = const [],
    List<FishingSession> sessions = const [],
    List<CatchEntry> catches = const [],
    List<CatchAttachment> attachments = const [],
    List<SyncOperation> outbox = const [],
    this.activeSessionId,
    this.reminders = const ReminderSettings(),
    this.lastSyncedAt,
  }) : places = List.unmodifiable(places),
       sessions = List.unmodifiable(sessions),
       catches = List.unmodifiable(catches),
       attachments = List.unmodifiable(attachments),
       outbox = List.unmodifiable(outbox);
  final List<FishingSession> sessions;
  final List<FishingPlace> places;
  final List<CatchEntry> catches;
  final List<CatchAttachment> attachments;
  final List<SyncOperation> outbox;
  final String? activeSessionId;
  final ReminderSettings reminders;
  final DateTime? lastSyncedAt;
  FishingSession? get activeSession {
    for (final session in sessions) {
      if (session.id == activeSessionId && session.isActive) return session;
    }
    return null;
  }

  List<CatchEntry> get visibleCatches =>
      catches.where((e) => e.deletedAt == null).toList();
  List<CatchEntry> forSession(String id) =>
      visibleCatches.where((e) => e.sessionId == id).toList()
        ..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
  List<CatchEntry> get currentSessionCatches =>
      activeSession == null ? const [] : forSession(activeSession!.id);
  int get pendingAccounting => outbox.where((e) => e.isAccounting).length;
  AnglerSnapshot copyWith({
    List<FishingPlace>? places,
    List<FishingSession>? sessions,
    List<CatchEntry>? catches,
    List<CatchAttachment>? attachments,
    List<SyncOperation>? outbox,
    String? activeSessionId,
    bool clearActiveSession = false,
    ReminderSettings? reminders,
    DateTime? lastSyncedAt,
  }) => AnglerSnapshot(
    places: places ?? this.places,
    sessions: sessions ?? this.sessions,
    catches: catches ?? this.catches,
    attachments: attachments ?? this.attachments,
    outbox: outbox ?? this.outbox,
    activeSessionId: clearActiveSession
        ? null
        : activeSessionId ?? this.activeSessionId,
    reminders: reminders ?? this.reminders,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  Json toJson() => {
    'schemaVersion': 1,
    'places': places.map((e) => e.toJson()).toList(),
    'sessions': sessions.map((e) => e.toJson()).toList(),
    'catches': catches.map((e) => e.toJson()).toList(),
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'outbox': outbox.map((e) => e.toJson()).toList(),
    'activeSessionId': activeSessionId,
    'reminders': reminders.toJson(),
    'lastSyncedAt': lastSyncedAt?.toUtc().toIso8601String(),
  };
  factory AnglerSnapshot.fromJson(Json j) => AnglerSnapshot(
    places: j['places'] == null
        ? const []
        : readList(j, 'places', FishingPlace.fromJson),
    sessions: readList(j, 'sessions', FishingSession.fromJson),
    catches: readList(j, 'catches', CatchEntry.fromJson),
    attachments: readList(j, 'attachments', CatchAttachment.fromJson),
    outbox: readList(j, 'outbox', SyncOperation.fromJson),
    activeSessionId: j['activeSessionId'],
    reminders: ReminderSettings.fromJson(j['reminders'] ?? {}),
    lastSyncedAt: optionalDate(j['lastSyncedAt']),
  );
}
