import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/context.dart';
import 'package:nad_parseta/core/actions.dart';
import 'package:nad_parseta/core/page_body.dart';

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    this.retry,
  });
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext c) => value.when(
    data: data,
    loading: () => Center(
      child: Semantics(
        label: c.l.loading,
        child: const CircularProgressIndicator(),
      ),
    ),
    error: (error, _) => PageBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(failureText(c, error)),
          const SizedBox(height: 24),
          if (retry != null)
            OutlinedButton(onPressed: retry, child: Text(c.l.retry)),
        ],
      ),
    ),
  );
}

class OnlineGate extends ConsumerWidget {
  const OnlineGate({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    if (ref.watch(networkProvider).online) return child;
    return Scaffold(
      appBar: AppBar(),
      body: PageBody(
        child: Column(
          children: [
            Text(c.l.onlineOnly, style: c.text.titleLarge),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(c).popUntil((route) => route.isFirst),
              child: Text(c.l.registry),
            ),
          ],
        ),
      ),
    );
  }
}
