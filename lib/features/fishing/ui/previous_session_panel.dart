import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/field_motifs.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/permits/permit_screens.dart';
import 'offline_pill.dart';
import 'previous_days_screen.dart';
import 'place_picker_screen.dart';
import 'session_fish_screen.dart';
import 'accounting_summary.dart';
import 'sync_screen.dart';
import 'fishing_format.dart';

class PreviousSessionPanel extends ConsumerWidget {
  const PreviousSessionPanel({
    super.key,
    required this.user,
    required this.snapshot,
  });
  final AppUser user;
  final AnglerSnapshot snapshot;

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final online = ref.watch(networkProvider).online;
    final last = snapshot.sessions
        .where(
          (s) =>
              !s.isActive &&
              DateUtils.isSameDay(s.endedAt?.toLocal(), DateTime.now()),
        )
        .lastOrNull;
    final entries = last == null
        ? <CatchEntry>[]
        : snapshot.forSession(last.id);
    final receiptTime = last?.submittedAt;
    final sent =
        last?.submittedAt != null ||
        (entries.isNotEmpty &&
            entries.every((entry) => entry.syncedAt != null));
    return SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(
            title: last == null ? null : c.l.dayEndedTitle,
            subtitle: last == null
                ? fishingDate(DateTime.now())
                : '${fishingDate(last.startedAt)} · ${c.l.fishCount(fishCount(entries))}',
            status: online ? null : const OfflinePill(),
          ),
          PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (last == null) ...[
                  const Center(child: EmptyFishingPlace()),
                  Text(c.l.noActiveSession, style: c.text.headlineSmall),
                  const SizedBox(height: 8),
                  Text(c.l.startDayHint),
                ] else ...[
                  const Center(child: EmptyFishingPlace()),
                  Text(
                    c.l.sessionEnded,
                    style: c.text.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SurfacePanel(
                    selected: sent,
                    child: Row(
                      children: [
                        Icon(
                          sent ? Icons.check : Icons.save,
                          color: sent ? AppColors.paper : AppColors.ink,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sent
                                ? '${c.l.received}${receiptTime == null ? '' : ' · ${timeLabel(receiptTime)}'}'
                                : c.l.localSaved,
                            style: c.text.bodyMedium?.copyWith(
                              color: sent ? AppColors.paper : AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AccountingSummary(entries: entries),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => pushPage(
                      c,
                      SessionFishScreen(ownerId: user.id, sessionId: last.id),
                    ),
                    child: Text(c.l.allSessionFish),
                  ),
                ],
                if (snapshot.outbox.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => pushPage(c, SyncScreen(ownerId: user.id)),
                    child: Text(c.l.sendingEntries),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => pushPage(
                    c,
                    PlacePickerScreen(ownerId: user.id, start: true),
                  ),
                  child: Text(
                    last == null ? c.l.startFishing : c.l.startNewDay,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      pushPage(c, PreviousDaysScreen(ownerId: user.id)),
                  child: Text(c.l.recentSessions),
                ),
                if (online && last == null)
                  TextButton(
                    onPressed: () => pushPage(c, PermitsScreen(user: user)),
                    child: Text(c.l.permits),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
