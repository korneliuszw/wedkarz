import 'package:nad_parseta/features/fishing/model/angler_snapshot.dart';
import 'snapshot_store.dart';

class LocalFishingRepository {
  LocalFishingRepository(this.ownerId, this._store);
  final String ownerId;
  final SnapshotStore _store;
  AnglerSnapshot? _current;
  Future<void> _tail = Future.value();
  Future<AnglerSnapshot> read() async {
    if (_current != null) return _current!;
    final saved = await _store.read(ownerId);
    final snapshot = saved ?? AnglerSnapshot();
    if (saved == null) await _store.write(ownerId, snapshot);
    _current = snapshot;
    return snapshot;
  }

  Future<AnglerSnapshot> update(
    AnglerSnapshot Function(AnglerSnapshot) change,
  ) {
    final result = _tail.then((_) async {
      final next = change(await read());
      await _store.write(ownerId, next);
      _current = next;
      return next;
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
}
