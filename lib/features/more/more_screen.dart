import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../fishing/fishing_screen.dart';
import '../permits/permit_screens.dart';
import '../permits/offline_inspection_screen.dart';

import 'ui/readability_screen.dart';
import 'ui/sign_out.dart';

export 'ui/readability_screen.dart' show ReadabilityScreen;

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key, required this.user, this.accountActions});
  final AppUser user;
  final WidgetBuilder? accountActions;
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final online = ref.watch(networkProvider).online;
    final permits = online
        ? ref.watch(permitsProvider(user.id)).valueOrNull ?? []
        : const <Permit>[];
    final permit = permits
        .where((p) => p.isValidAt(DateTime.now()))
        .firstOrNull;
    return SingleChildScrollView(
      child: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in [
              (
                c.l.permits,
                permit == null
                    ? null
                    : '${c.l.validUntil} ${dayLabel(lastPermitDay(permit))}',
                PermitsScreen(user: user),
                online,
              ),
              (
                c.l.showControl,
                null,
                OfflineInspectionScreen(ownerId: user.id),
                true,
              ),
              (c.l.reminders, null, ReminderScreen(ownerId: user.id), online),
              (
                c.l.accounts,
                c.l.anglerAccount,
                _AccountScreen(user: user, accountActions: accountActions),
                true,
              ),
              (
                c.l.recentSessions,
                null,
                PreviousDaysScreen(ownerId: user.id),
                true,
              ),
            ]) ...[
              MenuPanel(
                title: item.$1,
                subtitle: item.$2,
                onTap: item.$4 ? () => pushPage(c, item.$3) : null,
              ),
              const SizedBox(height: 10),
            ],
            MenuPanel(
              title: c.l.help,
              onTap: () => pushPage(
                c,
                Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        FishingHeader(back: true, title: c.l.help),
                        PageBody(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(c.l.helpSteps),
                              const SizedBox(height: 20),
                              MenuPanel(
                                title: c.l.readability,
                                onTap: () =>
                                    pushPage(c, const ReadabilityScreen()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => confirmSignOut(c, ref),
              child: Text(
                c.l.logout,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountScreen extends ConsumerWidget {
  const _AccountScreen({required this.user, this.accountActions});
  final AppUser user;
  final WidgetBuilder? accountActions;

  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(back: true, title: c.l.accounts),
          PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: c.text.titleLarge),
                      Text(c.l.anglerAccount),
                      Text(user.email, style: c.text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (accountActions case final WidgetBuilder actions) ...[
                  Consumer(
                    builder: (context, ref, _) {
                      ref.watch(
                        networkProvider.select((status) => status.online),
                      );
                      return actions(context);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  onPressed: () => confirmSignOut(c, ref),
                  child: Text(c.l.logout),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
