import 'package:flutter/material.dart';
import 'package:nad_parseta/core/theme.dart';
import 'package:nad_parseta/core/context.dart';
import 'package:nad_parseta/core/page_body.dart';

class FishingHeader extends StatelessWidget {
  const FishingHeader({
    super.key,
    this.title,
    this.subtitle,
    this.status,
    this.action,
    this.back = false,
    this.place = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? status;
  final Widget? action;
  final bool back;
  final bool place;

  @override
  Widget build(BuildContext c) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.green,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: SafeArea(
      bottom: false,
      child: PageBody(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  if (back)
                    OutlinedButton.icon(
                      style: darkHeaderButton(),
                      onPressed: () => Navigator.maybePop(c),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(c.l.back),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FloatMark(),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            c.l.appTitle,
                            style: c.text.bodyLarge?.copyWith(
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (status != null) status!,
                ],
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 12),
              Semantics(
                header: true,
                child: Text(
                  title!,
                  style: (place ? c.text.headlineLarge : c.text.headlineMedium)
                      ?.copyWith(color: AppColors.paper),
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: c.text.bodySmall?.copyWith(color: AppColors.soft),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 10), action!],
          ],
        ),
      ),
    ),
  );
}

ButtonStyle darkHeaderButton() => OutlinedButton.styleFrom(
  minimumSize: const Size(48, 48),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  foregroundColor: AppColors.paper,
  backgroundColor: Colors.transparent,
  side: const BorderSide(color: AppColors.paper, width: 2.5),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
);

class FloatMark extends StatelessWidget {
  const FloatMark({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SizedBox(
      width: 18,
      height: 32,
      child: CustomPaint(painter: _FloatPainter()),
    ),
  );
}

class _FloatPainter extends CustomPainter {
  const _FloatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(9, 2),
      const Offset(9, 30),
      paint..color = AppColors.paper,
    );
    final body = Rect.fromCenter(
      center: const Offset(9, 16),
      width: 9,
      height: 18,
    );
    canvas.drawOval(body, paint);
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    canvas.drawRect(
      const Rect.fromLTWH(4, 7, 10, 5),
      paint..color = AppColors.orange,
    );
    canvas.drawRect(
      const Rect.fromLTWH(4, 13, 10, 3),
      paint..color = AppColors.amberSurface,
    );
    canvas.drawRect(
      const Rect.fromLTWH(4, 16, 10, 3),
      paint..color = AppColors.ink,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FloatPainter oldDelegate) => false;
}
