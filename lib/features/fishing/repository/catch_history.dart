import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';

AnglerSnapshot mergeCatchHistory(
  AnglerSnapshot snapshot,
  String ownerId,
  List<Json> rows,
) {
  final sessions = {
    for (final session in snapshot.sessions) session.id: session,
  };
  final catches = {for (final entry in snapshot.catches) entry.id: entry};
  final remoteSessions = <String, List<CatchEntry>>{};
  for (final row in rows) {
    final id = row['clientId'] as String? ?? 'legacy:${row['id']}';
    if (catches.containsKey(id)) continue;
    final date = row['date'] as String;
    final sessionId = row['sessionId'] as String? ?? 'legacy-day:$date';
    final instant = row['caughtAt'] as String?;
    final at = DateTime.parse(instant ?? date);
    final label = row['place'] as String;
    final placeId =
        legacyPlaces.where((place) => place.label == label).firstOrNull?.id ??
        'legacy-place:$label';
    final entry = CatchEntry(
      id: id,
      sessionId: sessionId,
      placeId: placeId,
      speciesId: row['speciesId'].toString(),
      caughtAt: at,
      dateOnly: instant == null,
      syncedAt: at,
      quantity: row['quantity'] as int,
      lengthMm: row['lengthMm'] as int?,
      weightGrams: row['weightGrams'] as int?,
      fate: FishFate.values.byName(row['fate'] as String),
    );
    catches[id] = entry;
    (remoteSessions[sessionId] ??= []).add(entry);
  }
  for (final group in remoteSessions.entries) {
    final previous = sessions[group.key];
    final entries = group.value
      ..sort((a, b) => a.caughtAt.compareTo(b.caughtAt));
    final places = [
      ...?previous?.placeIds,
      ...entries.map((entry) => entry.placeId),
    ];
    sessions[group.key] = FishingSession(
      id: group.key,
      ownerId: ownerId,
      startedAt: previous?.startedAt ?? entries.first.caughtAt,
      endedAt: previous == null ? entries.last.caughtAt : previous.endedAt,
      placeIds: places,
      currentPlaceId: previous?.currentPlaceId ?? places.first,
      revision: previous?.revision ?? 1,
      signedReceipt: previous?.signedReceipt,
      submittedAt: previous?.submittedAt,
    );
  }
  return snapshot.copyWith(
    sessions: sessions.values.toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt)),
    catches: catches.values.toList(),
  );
}
