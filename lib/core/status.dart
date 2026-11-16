import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/context.dart';

class StatePill extends StatelessWidget {
  const StatePill(
    this.label, {
    super.key,
    this.color = AppColors.green,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext c) {
    final ink = color == AppColors.green || color == AppColors.error
        ? AppColors.paper
        : AppColors.ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: ink, size: 19),
            Text(
              label,
              style: c.text.bodySmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  const StatusLine(this.text, {super.key, this.pending = false});
  final String text;
  final bool pending;
  @override
  Widget build(BuildContext c) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: c.text.bodySmall?.copyWith(
        color: pending ? AppColors.amber : AppColors.muted,
      ),
    ),
  );
}
