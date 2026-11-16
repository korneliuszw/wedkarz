import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

final waterLevelsProvider = FutureProvider.autoDispose<Json>((ref) async {
  final api = ref.watch(anglerApiProvider);
  return ref
      .read(authProvider.notifier)
      .apiRequest(
        (session) => api.request('GET', 'water-levels', session: session),
      );
});
