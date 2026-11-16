import 'package:flutter/material.dart';
import 'package:nad_parseta/core/context.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.semanticsLabel,
  });
  final String label;
  final Widget child;
  final String? semanticsLabel;
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(
        child: Text(
          label,
          style: c.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(height: 8),
      MergeSemantics(
        child: Semantics(label: semanticsLabel ?? label, child: child),
      ),
    ],
  );
}
