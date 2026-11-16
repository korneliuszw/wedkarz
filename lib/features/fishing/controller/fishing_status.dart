import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/domain/rules.dart';

final achievementProvider = StateProvider<RecordAchievement?>((ref) => null);
final syncingProvider = StateProvider<bool>((ref) => false);
final syncFailureProvider = StateProvider<FailureCode?>((ref) => null);
