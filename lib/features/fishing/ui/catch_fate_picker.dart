import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';

class CatchFatePicker extends StatelessWidget {
  const CatchFatePicker({super.key, required this.selected, this.onSelected});

  final FishFate? selected;
  final ValueChanged<FishFate>? onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, constraints) {
      final choices = [
        for (final fate in FishFate.values)
          Semantics(
            selected: selected == fate,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: selected == fate
                    ? AppColors.green
                    : AppColors.paper,
                foregroundColor: selected == fate
                    ? AppColors.paper
                    : AppColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(70),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                textStyle: TextStyle(
                  fontFamily: AnglerAssets.fontOf(c, displayFont),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onPressed: onSelected == null ? null : () => onSelected!(fate),
              child: Text(fateLabel(c, fate), textAlign: TextAlign.center),
            ),
          ),
      ];
      if (constraints.maxWidth < 285 ||
          MediaQuery.textScalerOf(c).scale(1) > 1.3) {
        return Column(
          children: [choices[0], const SizedBox(height: 8), choices[1]],
        );
      }
      return Row(
        children: [
          Expanded(child: choices[0]),
          const SizedBox(width: 12),
          Expanded(child: choices[1]),
        ],
      );
    },
  );
}
