import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/features/fishing/model/catch_entry.dart';

import 'catch_tile.dart';

class DeleteCatchScreen extends StatelessWidget {
  const DeleteCatchScreen({super.key, required this.entry});

  final CatchEntry entry;

  @override
  Widget build(BuildContext c) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(back: true, title: c.l.deleteQuestion),
          PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchTile(entry: entry),
                const SizedBox(height: 16),
                Text(c.l.deleteHint),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(c.l.keepEntry),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.paper,
                  ),
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(c.l.deleteFish),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
