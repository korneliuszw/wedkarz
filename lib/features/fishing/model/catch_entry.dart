import 'package:nad_parseta/domain/model/json.dart';

enum FishFate { released, retained }

class CatchEntry {
  const CatchEntry({
    required this.id,
    required this.sessionId,
    required this.placeId,
    required this.speciesId,
    required this.caughtAt,
    required this.lengthMm,
    required this.weightGrams,
    required this.fate,
    this.revision = 1,
    this.deletedAt,
    this.syncedAt,
    this.quantity = 1,
    this.dateOnly = false,
  });
  final String id;
  final String sessionId;
  final String placeId;
  final String speciesId;
  final DateTime caughtAt;
  final int? lengthMm;
  final int? weightGrams;
  final FishFate fate;
  final int revision;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  final int quantity;
  final bool dateOnly;
  CatchEntry acknowledge(DateTime at) => CatchEntry(
    id: id,
    sessionId: sessionId,
    placeId: placeId,
    speciesId: speciesId,
    caughtAt: caughtAt,
    lengthMm: lengthMm,
    weightGrams: weightGrams,
    fate: fate,
    revision: revision,
    deletedAt: deletedAt,
    syncedAt: at,
    quantity: quantity,
    dateOnly: dateOnly,
  );
  CatchEntry softDelete(DateTime at) => CatchEntry(
    id: id,
    sessionId: sessionId,
    placeId: placeId,
    speciesId: speciesId,
    caughtAt: caughtAt,
    lengthMm: lengthMm,
    weightGrams: weightGrams,
    fate: fate,
    revision: revision + 1,
    deletedAt: at,
    quantity: quantity,
    dateOnly: dateOnly,
  );
  Json toJson() => {
    'id': id,
    'sessionId': sessionId,
    'placeId': placeId,
    'speciesId': speciesId,
    'caughtAt': dateOnly
        ? caughtAt.toLocal().toIso8601String().substring(0, 10)
        : caughtAt.toUtc().toIso8601String(),
    'lengthMm': lengthMm,
    'weightGrams': weightGrams,
    'fate': fate.name,
    'revision': revision,
    'deletedAt': deletedAt?.toUtc().toIso8601String(),
    'syncedAt': syncedAt?.toUtc().toIso8601String(),
    'quantity': quantity,
    'dateOnly': dateOnly,
  };
  factory CatchEntry.fromJson(Json j) => CatchEntry(
    id: j['id'],
    sessionId: j['sessionId'],
    placeId: j['placeId'],
    speciesId: j['speciesId'],
    caughtAt: DateTime.parse(j['caughtAt']),
    lengthMm: j['lengthMm'],
    weightGrams: j['weightGrams'],
    fate: FishFate.values.byName(j['fate']),
    revision: j['revision'],
    deletedAt: optionalDate(j['deletedAt']),
    syncedAt: optionalDate(j['syncedAt']),
    quantity: j['quantity'] as int? ?? 1,
    dateOnly: j['dateOnly'] as bool? ?? false,
  );
}
