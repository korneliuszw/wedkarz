import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext c) => StatePill(
    c.l.offline,
    color: AppColors.amberSurface,
    icon: Icons.signal_wifi_off,
  );
}
