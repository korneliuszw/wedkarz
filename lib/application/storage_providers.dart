import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nad_parseta/data/angler_api.dart';
import 'package:nad_parseta/data/local_store.dart';

import '../data/angler_http_adapter.dart'
    if (dart.library.io) '../data/angler_http_adapter_native.dart';

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
final anglerHttpAdapterFactoryProvider = Provider<HttpClientAdapter Function()>(
  (ref) => createAnglerHttpAdapter,
);

final anglerApiProvider = Provider<AnglerApi>((ref) {
  final url = ref.watch(anglerApiUrlProvider);
  final client = Dio()
    ..httpClientAdapter = ref.watch(anglerHttpAdapterFactoryProvider)();
  ref.onDispose(() => client.close(force: true));
  return AnglerApi(client, ref.watch(preferencesProvider), url: url);
});
