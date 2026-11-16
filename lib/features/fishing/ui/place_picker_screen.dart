import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';
import 'new_fishing_place_screen.dart';
import 'session_fish_screen.dart';
import 'fishing_format.dart';

class PlacePickerScreen extends ConsumerStatefulWidget {
  const PlacePickerScreen({
    super.key,
    required this.ownerId,
    this.existingOnly = false,
    this.start = false,
  });
  final String ownerId;
  final bool existingOnly;
  final bool start;

  @override
  ConsumerState<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends ConsumerState<PlacePickerScreen> {
  bool _busy = false;

  Future<void> _choose(BuildContext c, String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    final controller = ref.read(fishingProvider(widget.ownerId).notifier);
    final saved = await runAction(c, () => controller.selectPlace(id));
    if (!c.mounted) return;
    setState(() => _busy = false);
    if (saved) Navigator.pop(c, true);
  }

  @override
  Widget build(BuildContext c) {
    final snapshot = ref.watch(fishingProvider(widget.ownerId)).valueOrNull;
    final session = snapshot?.activeSession;
    final entries = session == null
        ? <CatchEntry>[]
        : snapshot!.forSession(session.id);
    if (!widget.existingOnly) {
      return NewFishingPlaceScreen(
        ownerId: widget.ownerId,
        start: widget.start,
      );
    }
    final places =
        session?.placeIds.map((id) => placeById(id, snapshot!.places)) ??
        const <FishingPlace>[];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FishingHeader(back: true, title: c.l.whereFishing),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final place in places) ...[
                    SurfacePanel(
                      selected: session?.currentPlaceId == place.id,
                      onTap: _busy ? null : () => _choose(c, place.id),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.label,
                                  style: c.text.titleLarge?.copyWith(
                                    color: session?.currentPlaceId == place.id
                                        ? AppColors.paper
                                        : AppColors.ink,
                                  ),
                                ),
                                if (widget.existingOnly)
                                  Text(
                                    session?.currentPlaceId == place.id
                                        ? c.l.currentPlace
                                        : c.l.fishCount(
                                            fishCount(
                                              entries.where(
                                                (e) => e.placeId == place.id,
                                              ),
                                            ),
                                          ),
                                    style: c.text.bodySmall?.copyWith(
                                      color: session?.currentPlaceId == place.id
                                          ? AppColors.soft
                                          : AppColors.muted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            session?.currentPlaceId == place.id
                                ? Icons.check
                                : Icons.chevron_right,
                            color: session?.currentPlaceId == place.id
                                ? AppColors.paper
                                : AppColors.ink,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () async {
                      final added = await Navigator.push<bool>(
                        c,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlacePickerScreen(ownerId: widget.ownerId),
                        ),
                      );
                      if (added == true && c.mounted) Navigator.pop(c);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(c.l.addPlace),
                  ),
                  const SizedBox(height: 12),
                  Text(c.l.placeChangeHint, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  if (session != null)
                    SurfacePanel(
                      onTap: () => pushPage(
                        c,
                        SessionFishScreen(
                          ownerId: widget.ownerId,
                          sessionId: session.id,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${c.l.allSessionFish}\n${c.l.fishCount(fishCount(entries))} · ${c.l.placeCount(session.placeIds.length)}',
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
