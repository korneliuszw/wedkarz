import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';

DateTime lastPermitDay(Permit permit) =>
    permit.validUntil.subtract(const Duration(microseconds: 1));

String permitPeriod(Permit permit) {
  final start = permit.validFrom.toLocal();
  final end = lastPermitDay(permit).toLocal();
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${dayLabel(end)}';
  }
  return '${dayLabel(start)} – ${dayLabel(end)}';
}

class PermitExpiryLabel extends StatelessWidget {
  const PermitExpiryLabel({super.key, required this.permit});
  final Permit permit;
  @override
  Widget build(BuildContext c) {
    final end = lastPermitDay(permit).toLocal();
    final now = DateTime.now();
    final days = DateTime.utc(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
    if (days > 7 || days < 0) return const SizedBox.shrink();
    return StatePill(
      days == 0 ? c.l.expiresToday : c.l.expiresInDays(days),
      color: AppColors.amberSurface,
    );
  }
}
