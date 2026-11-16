import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/field_motifs.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/data/catalog.dart';
import 'package:nad_parseta/domain/models.dart';
import 'catch_form.dart';
import 'catch_tile.dart';
import 'offline_pill.dart';
import 'previous_session_panel.dart';
import 'place_picker_screen.dart';
import 'record_notice.dart';
import 'end_session_screen.dart';
import 'catch_detail_screen.dart';
import 'fishing_format.dart';

class FishingScreen extends ConsumerWidget {
  const FishingScreen({super.key, required this.user});
  final AppUser user;
  @override
  Widget build(BuildContext c, WidgetRef ref) => AsyncBody(
    value: ref.watch(fishingProvider(user.id)),
    retry: () => ref.read(fishingProvider(user.id).notifier).load(),
    data: (snapshot) {
      final session = snapshot.activeSession;
      if (session == null) {
        return PreviousSessionPanel(user: user, snapshot: snapshot);
      }
      final all = snapshot.forSession(session.id);
      final place = placeById(session.currentPlaceId, snapshot.places);
      final entries = all.where((e) => e.placeId == place.id);
      final achievement = ref.watch(achievementProvider);
      final online = ref.watch(networkProvider).online;
      final sending = ref.watch(syncingProvider);
      final failed =
          online &&
          !sending &&
          snapshot.outbox.isNotEmpty &&
          ref.watch(syncFailureProvider) != null;
      final pending = snapshot.outbox.isNotEmpty;
      final status = !online
          ? StatePill(
              c.l.offline,
              color: AppColors.amberSurface,
              icon: Icons.signal_wifi_off,
            )
          : sending || (pending && !failed)
          ? StatePill(
              c.l.sending,
              color: AppColors.amberSurface,
              icon: Icons.sync,
            )
          : failed
          ? StatePill(
              c.l.sendFailedShort,
              color: AppColors.error,
              icon: Icons.error,
            )
          : null;
      final actionBottom = 12.0;
      final textScale = MediaQuery.textScalerOf(c).scale(1);
      final actionHeight = textScale > 1.5 ? 84.0 : 64.0;
      return Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: actionHeight + actionBottom + 16,
              ),
              child: Column(
                children: [
                  FishingHeader(
                    title: '${place.waterName}\n${place.sectionName}',
                    place: true,
                    subtitle:
                        '${fishingDate(session.startedAt)} · ${c.l.placeCount(session.placeIds.length)}',
                    status: AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: MediaQuery.disableAnimationsOf(c)
                            ? 0
                            : 300,
                      ),
                      child: status == null
                          ? const SizedBox.shrink()
                          : Semantics(
                              key: ValueKey((online, failed)),
                              liveRegion: true,
                              child: online ? status : const OfflinePill(),
                            ),
                    ),
                    action: OutlinedButton.icon(
                      key: const Key('place-options'),
                      style: darkHeaderButton(),
                      onPressed: () => pushPage(
                        c,
                        PlacePickerScreen(ownerId: user.id, existingOnly: true),
                      ),
                      icon: const Icon(Icons.place),
                      label: Text(c.l.changePlace),
                    ),
                  ),
                  PageBody(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (failed) ...[
                          SurfacePanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.l.localSaved),
                                TextButton(
                                  onPressed: () => ref
                                      .read(fishingProvider(user.id).notifier)
                                      .sync(),
                                  child: Text(c.l.trySend),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (achievement != null &&
                            achievement.entry.sessionId == session.id &&
                            achievement.entry.placeId == place.id) ...[
                          SurfacePanel(
                            child: RecordNotice(achievement: achievement),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (entries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const EmptyFishingPlace(),
                                Text(
                                  c.l.placeReady,
                                  style: c.text.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.l.firstCatchHint,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        for (final entry in entries) ...[
                          CatchTile(
                            entry: entry,
                            photo: snapshot.attachments
                                .where((p) => p.catchId == entry.id)
                                .lastOrNull,
                            onTap: () => pushPage(
                              c,
                              CatchDetailScreen(
                                ownerId: user.id,
                                entryId: entry.id,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (!online)
                          Text(c.l.localOffline, textAlign: TextAlign.center)
                        else if (!pending && all.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${c.l.todayAllPlaces}:\n${dayBalance(c, all)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: actionBottom,
            child: PageBody(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: actionHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        key: const Key('add-catch'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          elevation: 5,
                        ),
                        onPressed: () => _addCatch(c, ref, session),
                        child: Text(c.l.addFish, textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        onPressed: () =>
                            pushPage(c, EndSessionScreen(ownerId: user.id)),
                        child: Text(
                          c.l.endSessionShort,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _addCatch(
  BuildContext c,
  WidgetRef ref,
  FishingSession session,
) async {
  if (ref.read(authProvider).valueOrNull?.user.registerEnabled != true) {
    final accepted = await showDialog<bool>(
      context: c,
      builder: (dialog) => AlertDialog(
        title: Text(c.l.registerConsentTitle),
        content: Text(c.l.registerConsentText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(c.l.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(c.l.acceptRegister),
          ),
        ],
      ),
    );
    if (accepted != true || !c.mounted) return;
    final success = await runAction(
      c,
      ref.read(authProvider.notifier).acceptRegister,
    );
    if (!success || !c.mounted) return;
  }
  if (ref.read(speciesProvider).isEmpty) {
    await ref.read(fishingProvider(session.ownerId).notifier).sync();
    if (!c.mounted) return;
    if (ref.read(speciesProvider).isEmpty) {
      showFailure(c, const DomainFailure(FailureCode.speciesUnavailable));
      return;
    }
  }

  pushPage(c, CatchForm(ownerId: session.ownerId, session: session));
}
