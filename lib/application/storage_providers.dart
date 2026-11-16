import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nad_parseta/data/angler_api.dart';
import 'package:nad_parseta/data/local_store.dart';

final anglerApiUrlProvider = Provider<String>((ref) => apiUrl);

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('bootstrap override'),
);
final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
    apiNamespace: ref.watch(anglerApiUrlProvider),
  ),
);
final snapshotStoreProvider = Provider<SnapshotStore>(
  (ref) => PreferencesSnapshotStore(
    ref.watch(preferencesProvider),
    apiNamespace: ref.watch(anglerApiUrlProvider),
  ),
);
final anglerApiProvider = Provider<AnglerApi>((ref) {
  final url = ref.watch(anglerApiUrlProvider);
  final client = http.Client();
  ref.onDispose(client.close);
  return AnglerApi(client, ref.watch(preferencesProvider), url: url);
});
