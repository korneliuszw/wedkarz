import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../../domain/models.dart';
import '../fishing/catch_tile.dart';
import '../fishing/fishing_screen.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key, required this.user});
  final AppUser user;

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  bool _length = true;

  int? _measurement(CatchEntry entry) =>
      _length ? entry.lengthMm : entry.weightGrams;

  @override
  Widget build(BuildContext c) => AsyncBody(
    value: ref.watch(fishingProvider(widget.user.id)),
    data: (snapshot) {
      final best = <String, CatchEntry>{};
      for (final entry in snapshot.visibleCatches) {
        if (entry.quantity != 1) continue;
        final value = _measurement(entry);
        if (value == null) continue;
        final previous = best[entry.speciesId];
        if (previous == null || value > _measurement(previous)!) {
          best[entry.speciesId] = entry;
        }
      }
      final records = best.values.toList()
        ..sort((a, b) => _measurement(b)!.compareTo(_measurement(a)!));
      return SingleChildScrollView(
        child: PageBody(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  direction: MediaQuery.textScalerOf(c).scale(1) > 1.35
                      ? Axis.vertical
                      : Axis.horizontal,
                  style: ButtonStyle(
                    minimumSize: const WidgetStatePropertyAll(Size(48, 56)),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: AppColors.ink, width: 2.5),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColors.green
                          : AppColors.paper,
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColors.paper
                          : AppColors.ink,
                    ),
                    textStyle: WidgetStatePropertyAll(c.text.bodyMedium),
                  ),
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(c.l.longest, textAlign: TextAlign.center),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(c.l.heaviest, textAlign: TextAlign.center),
                    ),
                  ],
                  selected: {_length},
                  onSelectionChanged: (value) =>
                      setState(() => _length = value.single),
                ),
              ),
              const SizedBox(height: 16),
              if (records.isEmpty)
                SurfacePanel(
                  child: Text(c.l.noRecord, style: c.text.titleLarge),
                ),
              for (final entry in records) ...[
                SurfacePanel(
                  onTap: () => pushPage(
                    c,
                    CatchDetailScreen(
                      ownerId: widget.user.id,
                      entryId: entry.id,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FishPicture(
                            speciesId: entry.speciesId,
                            photo: snapshot.attachments
                                .where((photo) => photo.catchId == entry.id)
                                .lastOrNull,
                            width: MediaQuery.sizeOf(c).width < 360 ? 76 : 120,
                            height: 82,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  speciesById(
                                    entry.speciesId,
                                    ref.watch(speciesProvider),
                                  ).name,
                                  style: c.text.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _length
                                      ? cm(entry.lengthMm)
                                      : kg(entry.weightGrams),
                                  style: c.text.headlineLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${dayLabel(entry.caughtAt)} · ${fateLabel(c, entry.fate).toLowerCase()}',
                        style: c.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Text(
                c.l.recordsHint,
                textAlign: TextAlign.center,
                style: c.text.bodySmall,
              ),
            ],
          ),
        ),
      );
    },
  );
}
