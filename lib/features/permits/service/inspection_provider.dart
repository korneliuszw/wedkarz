import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/data/offline_inspection.dart';
import 'package:nad_parseta/application/storage_providers.dart';

final offlineInspectionProvider = Provider<OfflineInspection>((ref) {
  final api = ref.watch(anglerApiProvider);
  return OfflineInspection(api, ref.watch(preferencesProvider));
});
