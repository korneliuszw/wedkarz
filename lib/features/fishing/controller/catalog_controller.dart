import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/application/network_controller.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

final fishingAreasProvider =
    FutureProvider.autoDispose<List<({int id, String name})>>((ref) async {
      final prefs = ref.read(preferencesProvider);
      final auth = ref.read(authProvider.notifier);
      ref.watch(networkProvider.select((network) => network.online));
      final api = ref.read(anglerApiProvider);
      final owner = ref.watch(
        authProvider.select((state) => state.valueOrNull?.user.id),
      );
      final cacheKey = 'areas:${ref.read(anglerApiUrlProvider)}:$owner';
      List<({int id, String name})> parse(Json response) => readList(
        response,
        'items',
        (row) => (id: row['id'] as int, name: row['name'] as String),
      );
      try {
        final response = await auth.apiRequest(
          (session) => api.request('GET', 'areas', session: session),
        );
        final areas = parse(response);
        await prefs.setString(cacheKey, jsonEncode(response));
        return areas;
      } on DomainFailure catch (error) {
        if (error is AuthFailure || error is AuthorizationFailure) rethrow;
        final cached = prefs.getString(cacheKey);
        if (cached == null) rethrow;
        return parse(jsonDecode(cached) as Json);
      }
    });
final speciesProvider = StateProvider<List<FishSpecies>>((ref) {
  final raw = ref
      .watch(preferencesProvider)
      .getString('species:${ref.watch(anglerApiUrlProvider)}');
  if (raw == null) return const [];
  try {
    return (jsonDecode(raw) as List)
        .map(
          (row) => FishSpecies(
            id: row['id'] as String,
            name: row['name'] as String,
            asset: row['asset'] as String,
          ),
        )
        .toList();
  } catch (_) {
    return const [];
  }
});
