import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/field_motifs.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/rules.dart';
import 'package:nad_parseta/features/fishing/catch_tile.dart';

class RecordNotice extends ConsumerWidget {
  const RecordNotice({super.key, required this.achievement});
  final RecordAchievement achievement;
  @override
  Widget build(BuildContext c, WidgetRef ref) => Semantics(
    liveRegion: true,
    child: TweenAnimationBuilder<double>(
      key: ValueKey('${achievement.entry.id}:${achievement.entry.revision}'),
      tween: Tween(begin: MediaQuery.disableAnimationsOf(c) ? 1 : 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(c)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (c, progress, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child!,
          const SizedBox(height: 8),
          RecordRuler(progress: progress),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final species = speciesById(
            achievement.entry.speciesId,
            ref.watch(speciesProvider),
          );
          final image = FishPicture(
            speciesId: species.id,
            width: 116,
            height: 77,
          );
          final previous = achievement.lengthImproved
              ? achievement.previousLengthMm
              : achievement.previousWeightGrams;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${achievement.isFirst ? c.l.firstRecord : c.l.newRecord}\n'
                '${species.name} · ${achievement.lengthImproved ? cm(achievement.entry.lengthMm) : kg(achievement.entry.weightGrams)}',
                style: c.text.bodyMedium,
              ),
              if (previous != null)
                Text(
                  '${c.l.previousRecord}: ${achievement.lengthImproved ? cm(previous) : kg(previous)}',
                  style: c.text.bodySmall,
                ),
            ],
          );
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(c).scale(1) > 1.3) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 12), text],
            );
          }
          return Row(
            children: [
              image,
              const SizedBox(width: 20),
              Expanded(child: text),
            ],
          );
        },
      ),
    ),
  );
}
