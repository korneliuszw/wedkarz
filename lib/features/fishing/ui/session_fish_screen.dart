import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'catch_tile.dart';
import 'accounting_summary.dart';
import 'catch_detail_screen.dart';

class SessionFishScreen extends ConsumerWidget {
  const SessionFishScreen({
    super.key,
    required this.ownerId,
    required this.sessionId,
  });
  final String ownerId;
  final String sessionId;
  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    body: AsyncBody(
      value: ref.watch(fishingProvider(ownerId)),
      data: (s) {
        final entries = s.forSession(sessionId);
        final session = s.sessions
            .where((item) => item.id == sessionId)
            .firstOrNull;
        return SingleChildScrollView(
          child: Column(
            children: [
              FishingHeader(back: true, title: c.l.allFish),
              PageBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AccountingSummary(entries: entries),
                    for (final place in session?.placeIds ?? <String>[])
                      if (entries.any((entry) => entry.placeId == place)) ...[
                        const SizedBox(height: 16),
                        Text(
                          placeById(place, s.places).label,
                          style: c.text.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        for (final entry in entries.where(
                          (e) => e.placeId == place,
                        )) ...[
                          CatchTile(
                            entry: entry,
                            photo: s.attachments
                                .where((p) => p.catchId == entry.id)
                                .lastOrNull,
                            onTap: () => pushPage(
                              c,
                              CatchDetailScreen(
                                ownerId: ownerId,
                                entryId: entry.id,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
