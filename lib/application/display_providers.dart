import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/storage_providers.dart';

final textScaleProvider = StateProvider<double>(
  (ref) => ref.read(preferencesProvider).getDouble('textScale') ?? 1,
);
final reducedMotionProvider = StateProvider<bool>(
  (ref) => ref.read(preferencesProvider).getBool('reducedMotion') ?? false,
);
