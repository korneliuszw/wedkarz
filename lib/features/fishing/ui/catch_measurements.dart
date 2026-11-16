import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';

class CatchMeasurements extends StatelessWidget {
  const CatchMeasurements({
    super.key,
    required this.lengthController,
    required this.weightController,
    required this.validator,
  });

  final TextEditingController lengthController;
  final TextEditingController weightController;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, constraints) {
      final length = _measureField(
        c.l.length,
        'cm',
        'catch-length',
        lengthController,
      );
      final weight = _measureField(
        c.l.weight,
        'kg',
        'catch-weight',
        weightController,
      );
      if (constraints.maxWidth < 285 ||
          MediaQuery.textScalerOf(c).scale(1) > 1.3) {
        return Column(children: [length, const SizedBox(height: 12), weight]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: length),
          const SizedBox(width: 12),
          Expanded(child: weight),
        ],
      );
    },
  );

  Widget _measureField(
    String label,
    String unit,
    String key,
    TextEditingController controller,
  ) => LabeledField(
    label: label,
    semanticsLabel: '$label ($unit)',
    child: TextFormField(
      key: Key(key),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        suffixIcon: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(unit, style: const TextStyle(color: AppColors.muted)),
            ),
          ),
        ),
      ),
      validator: validator,
    ),
  );
}
