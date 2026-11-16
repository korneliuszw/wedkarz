import 'package:flutter/material.dart';

import 'theme.dart';

class EmptyFishingPlace extends StatelessWidget {
  const EmptyFishingPlace({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SizedBox(
      width: 240,
      height: 140,
      child: CustomPaint(painter: _EmptyPlacePainter()),
    ),
  );
}

class _EmptyPlacePainter extends CustomPainter {
  const _EmptyPlacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240, size.height / 140);
    final paint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(
      const Rect.fromLTWH(12, 62, 218, 65),
      Paint()..color = AppColors.soft,
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, 108)
        ..quadraticBezierTo(42, 97, 79, 108)
        ..quadraticBezierTo(116, 119, 153, 108)
        ..quadraticBezierTo(190, 97, 232, 108),
      paint,
    );
    for (final reed in [
      (14.0, 55.0, -10.0),
      (27.0, 40.0, 8.0),
      (40.0, 67.0, 9.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(reed.$1, 107)
          ..quadraticBezierTo(
            reed.$1 + reed.$3,
            83,
            reed.$1 + reed.$3,
            reed.$2,
          ),
        paint,
      );
    }
    canvas.drawLine(const Offset(133, 21), const Offset(133, 61), paint);
    final float = Path()
      ..moveTo(133, 61)
      ..cubicTo(117, 72, 121, 92, 133, 99)
      ..cubicTo(145, 92, 149, 72, 133, 61)
      ..close();
    canvas.drawPath(float, Paint()..color = AppColors.paper);
    canvas.save();
    canvas.clipPath(float);
    canvas.drawRect(
      const Rect.fromLTWH(116, 61, 34, 14),
      Paint()..color = AppColors.orange,
    );
    canvas.drawRect(
      const Rect.fromLTWH(116, 75, 34, 6),
      Paint()..color = AppColors.amberSurface,
    );
    canvas.restore();
    canvas.drawPath(float, paint);
    canvas.drawLine(const Offset(122, 81), const Offset(144, 81), paint);
    canvas.drawLine(const Offset(133, 99), const Offset(133, 119), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmptyPlacePainter oldDelegate) => false;
}

/// A decorative field ruler, not a measurement scale.
class RecordRuler extends StatelessWidget {
  const RecordRuler({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: double.infinity,
      height: 24,
      child: CustomPaint(painter: _RulerPainter(progress)),
    ),
  );
}

class _RulerPainter extends CustomPainter {
  const _RulerPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 1.5;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      paint,
    );
    for (var i = 0; i <= 28; i++) {
      final x = size.width * i / 28;
      final height = i % 4 == 0 ? 14.0 : 7.0;
      canvas.drawLine(
        Offset(x, size.height - 2),
        Offset(x, size.height - 2 - height),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
