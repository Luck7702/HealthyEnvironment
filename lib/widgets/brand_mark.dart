import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandMarkPainter()),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 64;
    canvas.save();
    canvas.scale(scale);

    final leafPaint = Paint()..style = PaintingStyle.fill;
    final stemPaint = Paint()
      ..color = AppColors.forest.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final left = Path()
      ..moveTo(31, 57)
      ..cubicTo(18, 54, 7, 43, 7, 22)
      ..cubicTo(20, 23, 30, 31, 31, 57)
      ..close();
    final right = Path()
      ..moveTo(32, 57)
      ..cubicTo(34, 37, 45, 24, 59, 18)
      ..cubicTo(60, 39, 49, 51, 32, 57)
      ..close();

    leafPaint.shader = const LinearGradient(
      colors: [Color(0xFF73C37B), Color(0xFF238553)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 64, 64));
    canvas.drawPath(left, leafPaint);
    leafPaint.shader = const LinearGradient(
      colors: [Color(0xFF4FAF68), Color(0xFF176B4D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 64, 64));
    canvas.drawPath(right, leafPaint);

    canvas.drawLine(const Offset(31, 57), const Offset(29, 32), stemPaint);
    canvas.drawLine(const Offset(32, 57), const Offset(43, 29), stemPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
