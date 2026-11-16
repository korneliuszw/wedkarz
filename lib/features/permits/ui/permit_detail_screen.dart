import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/permits/offline_inspection_screen.dart';
import 'package:nad_parseta/features/permits/ui/permit_labels.dart';
import 'package:nad_parseta/features/permits/ui/reminder_screen.dart';

class PermitDetailScreen extends StatelessWidget {
  const PermitDetailScreen({
    super.key,
    required this.user,
    required this.permit,
  });
  final AppUser user;
  final Permit permit;
  @override
  Widget build(BuildContext c) => OnlineGate(
    child: FishingScreenBody(
      title: c.l.permit,
      footer: permit.isValidAt(DateTime.now())
          ? FilledButton.icon(
              onPressed: () =>
                  pushPage(c, OfflineInspectionScreen(ownerId: user.id)),
              icon: const Icon(Icons.qr_code),
              label: Text(c.l.showControl),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfacePanel(
            selected: true,
            child: Row(
              children: [
                const Icon(Icons.check, color: AppColors.paper),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${permit.isValidAt(DateTime.now()) ? c.l.validUntil : c.l.expiredOn} ${dayLabel(lastPermitDay(permit))}',
                    style: c.text.bodyMedium?.copyWith(color: AppColors.paper),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final item in [
            (c.l.water, permit.areaName),
            (c.l.angler, user.displayName),
            (c.l.permitNumber, permit.number),
            (c.l.permitPeriod, permitPeriod(permit)),
          ]) ...[
            SurfacePanel(
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Text(item.$1, style: c.text.bodySmall),
                    Text(item.$2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          MenuPanel(
            title: c.l.reminders,
            onTap: () => pushPage(c, ReminderScreen(ownerId: user.id)),
          ),
        ],
      ),
    ),
  );
}
