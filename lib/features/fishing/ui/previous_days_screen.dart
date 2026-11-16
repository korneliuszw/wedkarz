import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/features/fishing/ui/session_fish_screen.dart';
import 'package:nad_parseta/features/fishing/ui/fishing_format.dart';

class PreviousDaysScreen extends ConsumerWidget {
  const PreviousDaysScreen({super.key, required this.ownerId});
  final String ownerId;

  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(back: true, title: c.l.recentSessions),
          AsyncBody(
            value: ref.watch(fishingProvider(ownerId)),
            data: (snapshot) => PageBody(
              child: Column(
                children: [
                  for (final session in snapshot.sessions.reversed.where(
                    (s) => !s.isActive,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurfacePanel(
                        onTap: () => pushPage(
                          c,
                          SessionFishScreen(
                            ownerId: ownerId,
                            sessionId: session.id,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            dayLabel(session.startedAt),
                            style: c.text.titleMedium,
                          ),
                          subtitle: Text(
                            c.l.fishCount(
                              fishCount(snapshot.forSession(session.id)),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
