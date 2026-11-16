import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/features/fishing/controller/catalog_controller.dart';

import 'catch_tile.dart';

class SpeciesPickerScreen extends ConsumerWidget {
  const SpeciesPickerScreen({super.key});

  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(back: true, title: c.l.whichSpecies),
          PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final species in ref.watch(speciesProvider)) ...[
                  SurfacePanel(
                    onTap: () => Navigator.pop(c, species.id),
                    child: Row(
                      children: [
                        FishPicture(
                          speciesId: species.id,
                          width: 76,
                          height: 60,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(species.name, style: c.text.titleLarge),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(c.l.speciesCaption, style: c.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
