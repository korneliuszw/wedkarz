import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/permits/ui/permit_labels.dart';
import 'package:nad_parseta/features/permits/ui/permit_detail_screen.dart';
import 'package:nad_parseta/features/permits/ui/reminder_screen.dart';

class PermitsScreen extends ConsumerStatefulWidget {
  const PermitsScreen({super.key, required this.user, this.expired = false});
  final AppUser user;
  final bool expired;
  @override
  ConsumerState<PermitsScreen> createState() => _PermitsScreenState();
}

class _PermitsScreenState extends ConsumerState<PermitsScreen>
    with WidgetsBindingObserver {
  Set<String>? _permitsBeforePurchase;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permitsProvider(widget.user.id));
    }
  }

  Future<void> _buy() async {
    const address = String.fromEnvironment('PURCHASE_URL');
    final uri = Uri.tryParse(address);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l.purchaseNotConfigured)));
      return;
    }
    await runAction(context, () async {
      await ref.read(authProvider.notifier).requireOnline();
      final current =
          ref.read(permitsProvider(widget.user.id)).valueOrNull ?? [];
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      )) {
        throw const DomainFailure(FailureCode.offline);
      }
      if (!mounted) return;
      setState(
        () =>
            _permitsBeforePurchase = current.map((permit) => permit.id).toSet(),
      );
      ref.invalidate(permitsProvider(widget.user.id));
    });
  }

  @override
  Widget build(BuildContext c) => OnlineGate(
    child: AsyncBody(
      value: ref.watch(permitsProvider(widget.user.id)),
      retry: () => ref.invalidate(permitsProvider(widget.user.id)),
      data: (permits) {
        final now = DateTime.now();
        final before = _permitsBeforePurchase;
        if (before != null &&
            !permits.any((p) => !before.contains(p.id) && p.isValidAt(now))) {
          return FishingScreenBody(
            title: c.l.permits,
            footer: FilledButton(
              onPressed: () => ref.invalidate(permitsProvider(widget.user.id)),
              child: Text(c.l.checkPurchase),
            ),
            child: SurfacePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(c.l.purchasePending, style: c.text.titleLarge),
                  const SizedBox(height: 12),
                  Text(c.l.purchasePendingHint),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _permitsBeforePurchase = null),
                    child: Text(c.l.myPermits),
                  ),
                ],
              ),
            ),
          );
        }
        final selected = permits.where(
          (p) => widget.expired ? !p.validUntil.isAfter(now) : p.isValidAt(now),
        );
        return FishingScreenBody(
          title: widget.expired ? c.l.expiredPermits : c.l.permits,
          footer: widget.expired
              ? null
              : Column(
                  children: [
                    Text(
                      c.l.externalPurchase,
                      textAlign: TextAlign.center,
                      style: c.text.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _buy,
                      icon: const Icon(Icons.north_east),
                      label: Text(c.l.buyPermit),
                    ),
                  ],
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected.isEmpty)
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expired
                            ? c.l.noExpiredPermits
                            : c.l.noValidPermit,
                        style: c.text.titleLarge,
                      ),
                      if (!widget.expired) ...[
                        const SizedBox(height: 8),
                        Text(c.l.noPermitHint),
                      ],
                    ],
                  ),
                ),
              for (final permit in selected) ...[
                SurfacePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(permit.areaName, style: c.text.titleLarge),
                      const SizedBox(height: 8),
                      Text(permitPeriod(permit), style: c.text.bodyLarge),
                      if (!widget.expired) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: PermitExpiryLabel(permit: permit),
                        ),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => pushPage(
                          c,
                          PermitDetailScreen(user: widget.user, permit: permit),
                        ),
                        child: Text(c.l.showPermit),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (!widget.expired) ...[
                MenuPanel(
                  title: c.l.reminders,
                  onTap: () =>
                      pushPage(c, ReminderScreen(ownerId: widget.user.id)),
                ),
                const SizedBox(height: 12),
                MenuPanel(
                  title: c.l.expiredPermits,
                  onTap: () => pushPage(
                    c,
                    PermitsScreen(user: widget.user, expired: true),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}
