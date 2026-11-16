import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

final migrationRecordingsProvider =
    FutureProvider.autoDispose<List<MigrationRecording>>((ref) async {
      final api = ref.watch(anglerApiProvider);
      final response = await ref
          .read(authProvider.notifier)
          .apiRequest(
            (session) =>
                api.request('GET', 'migration-recordings', session: session),
          );
      return readList(
        response,
        'items',
        (row) => MigrationRecording(
          id: row['id'] as String,
          site: row['site'] as String,
          recordedAt: DateTime.parse(row['recordedAt'] as String),
          durationSeconds: row['durationSeconds'] as int,
          mediaUrl: row['mediaUrl'] == null
              ? null
              : Uri.parse(row['mediaUrl'] as String),
        ),
      );
    });
