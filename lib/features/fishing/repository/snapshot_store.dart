import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nad_parseta/domain/model/failure.dart';
import 'package:nad_parseta/features/fishing/model/angler_snapshot.dart';

abstract interface class SnapshotStore {
  Future<AnglerSnapshot?> read(String ownerId);
  Future<void> write(String ownerId, AnglerSnapshot snapshot);
}

class PreferencesSnapshotStore implements SnapshotStore {
  const PreferencesSnapshotStore(
    this._preferences, {
    required this.apiNamespace,
  });
  final SharedPreferences _preferences;
  final String apiNamespace;
  String _key(String ownerId) =>
      'nad_parseta_api_snapshot_v1_${apiNamespace}_$ownerId';
  @override
  Future<AnglerSnapshot?> read(String ownerId) async {
    final raw = _preferences.getString(_key(ownerId));
    if (raw == null) return null;
    try {
      return AnglerSnapshot.fromJson(jsonDecode(raw));
    } catch (_) {
      throw const DomainFailure(FailureCode.storage);
    }
  }

  @override
  Future<void> write(String ownerId, AnglerSnapshot snapshot) async {
    final saved = await _preferences.setString(
      _key(ownerId),
      jsonEncode(snapshot.toJson()),
    );
    if (!saved) throw const DomainFailure(FailureCode.storage);
  }
}
