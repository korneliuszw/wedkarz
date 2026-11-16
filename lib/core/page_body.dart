import 'package:flutter/material.dart';
import 'package:nad_parseta/core/fishing_header.dart';

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext c) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class FishingScreenBody extends StatelessWidget {
  const FishingScreenBody({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    required this.child,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final Widget? status;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext c) {
    final content = SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(
            back: true,
            title: title,
            subtitle: subtitle,
            status: status,
          ),
          PageBody(child: child),
        ],
      ),
    );
    return Scaffold(
      body: footer == null
          ? content
          : Column(
              children: [
                Expanded(child: content),
                SafeArea(
                  top: false,
                  child: PageBody(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: footer!,
                  ),
                ),
              ],
            ),
    );
  }
}
