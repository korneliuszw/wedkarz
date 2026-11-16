import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/application/network_controller.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

final permitsProvider = FutureProvider.autoDispose.family<List<Permit>, String>(
  (ref, ownerId) async {
    if (!ref.watch(networkProvider).online) {
      throw const DomainFailure(FailureCode.offline);
    }
    final session = await ref.read(authProvider.notifier).requireOnline();
    if (session.user.id != ownerId) throw const AuthorizationFailure();
    final api = ref.read(anglerApiProvider);
    return ref.read(authProvider.notifier).apiRequest((current) {
      if (current.user.id != ownerId) throw const AuthorizationFailure();
      return api.permits(current);
    });
  },
);
