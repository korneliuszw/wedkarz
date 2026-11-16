import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/features/auth/controller/auth_controller.dart';

Future<void> confirmSignOut(BuildContext c, WidgetRef ref) async {
  final confirm = await showDialog<bool>(
    context: c,
    builder: (d) => AlertDialog(
      content: Text(c.l.signOutQuestion),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d, false),
          child: Text(c.l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(d, true),
          child: Text(c.l.logout),
        ),
      ],
    ),
  );
  if (confirm == true && c.mounted) {
    await runAction(c, ref.read(authProvider.notifier).signOut);
  }
}
