import 'package:flutter/material.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/domain/rules.dart';

class AccountingSummary extends StatelessWidget {
  const AccountingSummary({super.key, required this.entries});
  final List<CatchEntry> entries;
  @override
  Widget build(BuildContext c) {
    final summary = CatchAccounting.fromEntries(entries);
    final mass = switch ((
      summary.hasUnknownRetainedWeight,
      summary.retainedWeightGrams,
    )) {
      (true, 0) => '— kg',
      (true, final known) => '${kg(known)} + ?',
      _ => kg(summary.retainedWeightGrams),
    };
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TotalCard(
                value: summary.releasedCount,
                label: c.l.releasedTotal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TotalCard(
                value: summary.retainedCount,
                label: '${c.l.retainedTotal} · $mass',
              ),
            ),
          ],
        ),
        if (summary.hasUnknownRetainedWeight)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(c.l.unknownWeight, style: c.text.bodySmall),
          ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext c) => SurfacePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$value', style: c.text.headlineMedium),
        Text(label),
      ],
    ),
  );
}
