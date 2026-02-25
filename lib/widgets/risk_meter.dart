import 'package:flutter/material.dart';
import 'package:LingkunganSehat/config/colors_theme.dart';
import 'dart:math';

import 'package:LingkunganSehat/models/weather.dart';

class RiskMeter extends StatelessWidget{

  final Weather weather;

  Color get riskColor => RiskLevelColors.getRiskColor(weather);

  const RiskMeter({super.key,required this.weather});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _CircleMeterPainter(progress: weather.riskScore, color: riskColor),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Risiko"),
              Text(
                weather.getRiskLevel,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleMeterPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleMeterPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawCircle(center, radius - 10, bgPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
