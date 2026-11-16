import 'models.dart';

class CatchAccounting {
  const CatchAccounting({
    required this.retainedCount,
    required this.releasedCount,
    required this.retainedWeightGrams,
    required this.hasUnknownRetainedWeight,
  });
  final int retainedCount;
  final int releasedCount;
  final int retainedWeightGrams;
  final bool hasUnknownRetainedWeight;
  factory CatchAccounting.fromEntries(Iterable<CatchEntry> entries) {
    final visible = entries.where((e) => e.deletedAt == null).toList();
    final retained = visible.where((e) => e.fate == FishFate.retained).toList();
    return CatchAccounting(
      retainedCount: retained.fold(0, (sum, entry) => sum + entry.quantity),
      releasedCount: visible
          .where((entry) => entry.fate == FishFate.released)
          .fold(0, (sum, entry) => sum + entry.quantity),
      retainedWeightGrams: retained.fold(
        0,
        (sum, e) => sum + (e.weightGrams ?? 0),
      ),
      hasUnknownRetainedWeight: retained.any((e) => e.weightGrams == null),
    );
  }
}

class RecordAchievement {
  const RecordAchievement({
    required this.entry,
    required this.previousLengthMm,
    required this.previousWeightGrams,
    required this.isFirst,
  });
  final CatchEntry entry;
  final int? previousLengthMm;
  final int? previousWeightGrams;
  final bool isFirst;
  bool get lengthImproved =>
      entry.lengthMm != null &&
      (previousLengthMm == null || entry.lengthMm! > previousLengthMm!);
  bool get weightImproved =>
      entry.weightGrams != null &&
      (previousWeightGrams == null ||
          entry.weightGrams! > previousWeightGrams!);
  bool get isRecord => lengthImproved || weightImproved;
}

RecordAchievement compareRecord(
  CatchEntry entry,
  Iterable<CatchEntry> history,
) {
  final previous = history
      .where(
        (e) =>
            e.speciesId == entry.speciesId &&
            e.quantity == 1 &&
            e.deletedAt == null &&
            e.id != entry.id,
      )
      .toList();
  final lengths = previous.map((e) => e.lengthMm).whereType<int>().toList()
    ..sort();
  final weights = previous.map((e) => e.weightGrams).whereType<int>().toList()
    ..sort();
  return RecordAchievement(
    entry: entry,
    previousLengthMm: lengths.lastOrNull,
    previousWeightGrams: weights.lastOrNull,
    isFirst: previous.isEmpty,
  );
}

void validateCatch(CatchEntry entry, FishingSession session) {
  if (!session.isActive) throw const DomainFailure(FailureCode.closedSession);
  if (entry.sessionId != session.id ||
      !session.placeIds.contains(entry.placeId) ||
      (entry.lengthMm != null &&
          (entry.lengthMm! <= 0 || entry.lengthMm! > 5000)) ||
      (entry.weightGrams != null &&
          (entry.weightGrams! <= 0 || entry.weightGrams! > 500000)) ||
      entry.caughtAt.isBefore(session.startedAt) ||
      (entry.lengthMm == null && entry.weightGrams == null)) {
    throw const DomainFailure(FailureCode.invalidMeasurement);
  }
}
