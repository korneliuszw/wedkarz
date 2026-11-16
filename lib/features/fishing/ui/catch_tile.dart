import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';

class FishPicture extends ConsumerWidget {
  const FishPicture({
    super.key,
    required this.speciesId,
    this.photo,
    required this.width,
    required this.height,
  });

  final String speciesId;
  final CatchAttachment? photo;
  final double width;
  final double height;

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final asset = speciesById(speciesId, ref.watch(speciesProvider)).asset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: AppColors.soft,
        child: photo == null && asset.isEmpty
            ? SizedBox(
                width: width,
                height: height,
                child: const ExcludeSemantics(
                  child: Icon(Icons.set_meal_outlined),
                ),
              )
            : photo == null
            ? Image.asset(
                asset,
                package: AnglerAssets.packageOf(c),
                width: width,
                height: height,
                fit: BoxFit.contain,
                semanticLabel: c.l.speciesIllustration,
              )
            : Image.memory(
                base64Decode(photo!.base64Bytes),
                width: width,
                height: height,
                fit: BoxFit.cover,
                semanticLabel: c.l.yourPhoto,
              ),
      ),
    );
  }
}

class CatchTile extends ConsumerWidget {
  const CatchTile({
    super.key,
    required this.entry,
    this.placeLabel,
    this.onTap,
    this.photo,
  });

  final CatchEntry entry;
  final String? placeLabel;
  final VoidCallback? onTap;
  final CatchAttachment? photo;

  @override
  Widget build(BuildContext c, WidgetRef ref) => SurfacePanel(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: LayoutBuilder(
      builder: (c, constraints) {
        final stacked =
            constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(c).scale(1) > 1.25;
        final name = Text(
          '${speciesById(entry.speciesId, ref.watch(speciesProvider)).name}${entry.quantity == 1 ? '' : ' × ${entry.quantity}'}',
          style: c.text.titleLarge,
        );
        final status = entry.syncedAt == null
            ? StatePill(c.l.pendingShort, color: AppColors.amberSurface)
            : StatePill(c.l.receivedShort);
        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stacked) ...[
              name,
              const SizedBox(height: 4),
            ] else
              Row(
                children: [
                  Expanded(child: name),
                  const SizedBox(width: 8),
                  status,
                ],
              ),
            Text(
              '${cm(entry.lengthMm)} · ${kg(entry.weightGrams)}',
              style: c.text.bodyLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.dateOnly ? dayLabel(entry.caughtAt) : timeLabel(entry.caughtAt)} · ${fateLabel(c, entry.fate)}',
                    style: c.text.bodySmall,
                  ),
                ),
                if (!stacked && onTap != null)
                  const Icon(Icons.chevron_right, size: 28),
              ],
            ),
            if (placeLabel case final label?)
              Text(label, style: c.text.bodySmall),
            if (stacked) ...[const SizedBox(height: 6), status],
          ],
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FishPicture(
              speciesId: entry.speciesId,
              photo: photo,
              width: stacked ? 60 : 76,
              height: stacked ? 60 : 76,
            ),
            const SizedBox(width: 14),
            Expanded(child: description),
            if (stacked && onTap != null) const Icon(Icons.chevron_right),
          ],
        );
      },
    ),
  );
}
