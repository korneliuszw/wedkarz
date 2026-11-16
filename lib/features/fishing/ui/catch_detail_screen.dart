import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';
import 'catch_form.dart';
import 'catch_tile.dart';

class CatchDetailScreen extends ConsumerWidget {
  const CatchDetailScreen({
    super.key,
    required this.ownerId,
    required this.entryId,
  });
  final String ownerId;
  final String entryId;
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final snapshot = ref.watch(fishingProvider(ownerId)).valueOrNull;
    final entry = snapshot?.visibleCatches
        .where((e) => e.id == entryId)
        .firstOrNull;
    if (entry == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox());
    }
    final session = snapshot!.sessions.firstWhere(
      (e) => e.id == entry.sessionId,
    );
    final photo = snapshot.attachments
        .where((e) => e.catchId == entry.id)
        .lastOrNull;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FishingHeader(
              back: true,
              title: speciesById(
                entry.speciesId,
                ref.watch(speciesProvider),
              ).name,
              subtitle:
                  '${placeById(entry.placeId, snapshot.places).label} · ${entry.dateOnly ? dayLabel(entry.caughtAt) : timeLabel(entry.caughtAt)}',
            ),
            PageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FishPicture(
                    speciesId: entry.speciesId,
                    photo: photo,
                    width: double.infinity,
                    height: 190,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    photo == null
                        ? c.l.speciesCaption
                        : photo.syncedAt == null
                        ? c.l.catchPhotoPending
                        : c.l.catchPhotoSent,
                    style: c.text.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SurfacePanel(
                          child: Column(
                            children: [
                              Text(
                                cm(entry.lengthMm),
                                style: c.text.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(c.l.length, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SurfacePanel(
                          child: Column(
                            children: [
                              Text(
                                kg(entry.weightGrams),
                                style: c.text.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(c.l.weight, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SurfacePanel(
                    child: Text('${c.l.fate} · ${fateLabel(c, entry.fate)}'),
                  ),
                  const SizedBox(height: 16),
                  StatusLine(
                    entry.syncedAt == null ? c.l.fishSaved : c.l.received,
                    pending: entry.syncedAt == null,
                  ),
                  if (session.isActive &&
                      entry.syncedAt == null &&
                      !snapshot.outbox.any(
                        (op) =>
                            op.kind == SyncKind.catchEntry &&
                            op.entityId == entry.id,
                      )) ...[
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => pushPage(
                        c,
                        CatchForm(
                          ownerId: ownerId,
                          session: session,
                          entry: entry,
                        ),
                      ),
                      child: Text(c.l.editFish),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
