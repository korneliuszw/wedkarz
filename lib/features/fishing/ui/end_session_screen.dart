import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/features/fishing/ui/accounting_summary.dart';
import 'package:nad_parseta/features/fishing/ui/fishing_format.dart';

class EndSessionScreen extends ConsumerStatefulWidget {
  const EndSessionScreen({super.key, required this.ownerId});
  final String ownerId;
  @override
  ConsumerState<EndSessionScreen> createState() => _EndSessionScreenState();
}

class _EndSessionScreenState extends ConsumerState<EndSessionScreen> {
  bool _busy = false;
  @override
  Widget build(BuildContext c) {
    final s = ref.watch(fishingProvider(widget.ownerId)).valueOrNull;
    final session = s?.activeSession;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(c.l.sessionEnded)),
      );
    }
    final entries = s!.forSession(session.id);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FishingHeader(
              back: true,
              title: c.l.endQuestion,
              subtitle:
                  '${fishingDate(session.startedAt)} · ${timeLabel(session.startedAt)}',
            ),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (entries.isEmpty)
                    SurfacePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.l.noFishToday, style: c.text.titleLarge),
                          const SizedBox(height: 8),
                          Text(c.l.noFishDayHint),
                        ],
                      ),
                    )
                  else ...[
                    AccountingSummary(entries: entries),
                    const SizedBox(height: 20),
                    for (final placeId in session.placeIds) ...[
                      SurfacePanel(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(placeById(placeId, s.places).label),
                            ),
                            Flexible(
                              child: Text(
                                c.l.fishCount(
                                  fishCount(
                                    entries.where((e) => e.placeId == placeId),
                                  ),
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _busy ? null : () => Navigator.pop(c),
                    child: Text(c.l.keepFishing),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            final saved = await runAction(
                              c,
                              () => ref
                                  .read(
                                    fishingProvider(widget.ownerId).notifier,
                                  )
                                  .end(),
                            );
                            if (!mounted) return;
                            setState(() => _busy = false);
                            if (saved && c.mounted) Navigator.pop(c);
                          },
                    child: Text(c.l.submitFishingSession),
                  ),
                  const SizedBox(height: 8),
                  Text(c.l.submitFishingSessionHint, style: c.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
