import 'package:flutter_test/flutter_test.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/domain/rules.dart';

void main() {
  final now = DateTime.utc(2026, 11, 6, 10);
  FishingSession session() => FishingSession(
    id: 'session',
    ownerId: 'angler',
    startedAt: now,
    placeIds: const ['a', 'b'],
    currentPlaceId: 'a',
  );
  CatchEntry fish(
    String id,
    String place, {
    int lengthMm = 280,
    int? weightGrams = 350,
    FishFate fate = FishFate.released,
  }) => CatchEntry(
    id: id,
    sessionId: 'session',
    placeId: place,
    speciesId: 'perch',
    caughtAt: now,
    lengthMm: lengthMm,
    weightGrams: weightGrams,
    fate: fate,
  );
  test('returning to a previous place does not duplicate it', () {
    final changed = session().selectPlace('b').selectPlace('a');
    expect(changed.placeIds, ['a', 'b']);
    expect(changed.currentPlaceId, 'a');
  });
  test(
    'inspection catch selection includes only the active session across places',
    () {
      final previous = FishingSession(
        id: 'previous',
        ownerId: 'angler',
        startedAt: now,
        endedAt: now,
        placeIds: ['a'],
        currentPlaceId: 'a',
      );
      final old = CatchEntry(
        id: 'old',
        sessionId: previous.id,
        placeId: 'a',
        speciesId: 'perch',
        caughtAt: now,
        lengthMm: 280,
        weightGrams: null,
        fate: FishFate.released,
      );
      final snapshot = AnglerSnapshot(
        sessions: [previous, session()],
        catches: [old, fish('first', 'a'), fish('second', 'b')],
        activeSessionId: 'session',
      );

      expect(
        snapshot.currentSessionCatches.map((fish) => fish.id),
        unorderedEquals(['first', 'second']),
      );
      expect(
        snapshot.copyWith(clearActiveSession: true).currentSessionCatches,
        isEmpty,
      );
    },
  );

  test(
    'saved place keeps its display name separate from the register coordinates',
    () {
      const coordinates = '-90.000000,-180.000000';
      const place = FishingPlace(
        id: 'gps',
        waterName: 'Parsęta',
        sectionName: '',
        areaId: 7,
        coordinates: coordinates,
        customName: 'Przy moście',
      );
      final snapshot = AnglerSnapshot.fromJson(
        AnglerSnapshot(places: [place]).toJson(),
      );
      expect(snapshot.places.single.label, 'Przy moście');
      expect(snapshot.places.single.registerLocation, coordinates);
      expect(coordinates.length, lessThanOrEqualTo(32));
      expect(
        FishingPlace.fromJson({...place.toJson(), 'customName': null}).label,
        'Parsęta · $coordinates',
      );
    },
  );
  test('adding a third place preserves the session identity', () {
    final changed = session().selectPlace('c');
    expect(changed.id, 'session');
    expect(changed.placeIds, ['a', 'b', 'c']);
  });
  test('accounting separates retained weight from released fish', () {
    final total = CatchAccounting.fromEntries([
      fish('1', 'a'),
      fish('2', 'b', weightGrams: 1200, fate: FishFate.retained),
    ]);
    expect(total.retainedWeightGrams, 1200);
    expect(total.releasedCount, 1);
    expect(total.retainedCount, 1);
  });
  test('unknown retained weight is not a complete zero total', () {
    final total = CatchAccounting.fromEntries([
      fish('1', 'a', weightGrams: null, fate: FishFate.retained),
    ]);
    expect(total.hasUnknownRetainedWeight, isTrue);
  });
  test('equal length is not a new personal record', () {
    expect(
      compareRecord(fish('new', 'a'), [fish('old', 'b')]).lengthImproved,
      isFalse,
    );
  });
  test('released fish can improve a personal record', () {
    final result = compareRecord(fish('new', 'a', lengthMm: 300), [
      fish('old', 'b'),
    ]);
    expect(result.lengthImproved, isTrue);
    expect(result.previousLengthMm, 280);
  });
  test('first record has no fabricated zero baseline', () {
    final result = compareRecord(fish('new', 'a'), []);
    expect(result.isFirst, isTrue);
    expect(result.previousLengthMm, isNull);
  });
  test('snapshot round trip preserves place and unsent operation', () {
    final snapshot = AnglerSnapshot(
      sessions: [session()],
      catches: [fish('1', 'b')],
      outbox: [
        SyncOperation(
          id: 'op',
          entityId: '1',
          kind: SyncKind.catchEntry,
          revision: 1,
          createdAt: now,
        ),
      ],
    );
    final restored = AnglerSnapshot.fromJson(snapshot.toJson());
    expect(restored.catches.single.placeId, 'b');
    expect(restored.outbox.single.id, 'op');
  });
  test(
    'an outbox operation owns an immutable copy of its revision payload',
    () {
      final payload = <String, dynamic>{'lengthMm': 280};
      final operation = SyncOperation(
        id: 'op',
        entityId: 'fish',
        kind: SyncKind.catchEntry,
        revision: 1,
        createdAt: now,
        payload: payload,
      );
      payload['lengthMm'] = 310;
      expect(operation.payload['lengthMm'], 280);
      expect(
        SyncOperation.fromJson(operation.toJson()).payload['lengthMm'],
        280,
      );
    },
  );
}
