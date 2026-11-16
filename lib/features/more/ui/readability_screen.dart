import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';

class ReadabilityScreen extends ConsumerWidget {
  const ReadabilityScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) => OnlineGate(
    child: Scaffold(
      appBar: AppBar(title: Text(c.l.readability)),
      body: SingleChildScrollView(
        child: PageBody(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.l.largeText),
                value: ref.watch(textScaleProvider) > 1,
                onChanged: (v) async {
                  ref.read(textScaleProvider.notifier).state = v ? 1.25 : 1;
                  await ref
                      .read(preferencesProvider)
                      .setDouble('textScale', v ? 1.25 : 1);
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.l.reduceMotion),
                value: ref.watch(reducedMotionProvider),
                onChanged: (v) async {
                  ref.read(reducedMotionProvider.notifier).state = v;
                  await ref
                      .read(preferencesProvider)
                      .setBool('reducedMotion', v);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
