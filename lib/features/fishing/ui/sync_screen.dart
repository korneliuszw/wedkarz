import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';

class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key, required this.ownerId});
  final String ownerId;
  @override
  Widget build(BuildContext c, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(c.l.sendingEntries)),
    body: AsyncBody(
      value: ref.watch(fishingProvider(ownerId)),
      data: (s) => SingleChildScrollView(
        child: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.outbox.isEmpty
                    ? c.l.received
                    : '${c.l.pending}: ${s.outbox.length}',
                style: c.text.titleLarge,
              ),
              if (s.lastSyncedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    '${c.l.lastReceipt}: ${timeLabel(s.lastSyncedAt!)}',
                    style: c.text.bodySmall,
                  ),
                ),
              const SizedBox(height: 24),
              ...s.outbox.map(
                (op) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(switch (op.kind) {
                    SyncKind.session => c.l.sessionRecord,
                    SyncKind.catchEntry => c.l.fish,
                    SyncKind.attachment => c.l.attachment,
                  }),
                  subtitle: Text(timeLabel(op.createdAt)),
                ),
              ),
              if (ref.watch(syncFailureProvider) case final code?)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(failureText(c, DomainFailure(code))),
                ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: ref.watch(syncingProvider)
                    ? null
                    : () async {
                        await ref
                            .read(fishingProvider(ownerId).notifier)
                            .sync();
                      },
                child: Text(
                  ref.watch(syncingProvider) ? c.l.sending : c.l.trySend,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
