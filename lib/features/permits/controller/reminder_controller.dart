import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/application/storage_providers.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

final remoteReminderProvider = FutureProvider.autoDispose<ReminderSettings>((
  ref,
) async {
  final api = ref.read(anglerApiProvider);
  final value = await ref
      .read(authProvider.notifier)
      .apiRequest(
        (session) =>
            api.request('GET', 'me/permit-reminders', session: session),
      );
  return ReminderSettings.fromJson(value);
});
