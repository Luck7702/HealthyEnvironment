import 'dart:math';

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/colors_theme.dart';
import '../models/weather.dart';

class RiskMeter extends StatelessWidget {
  final Weather weather;
  final double size;

  const RiskMeter({super.key, required this.weather, this.size = 280});

  @override
  Widget build(BuildContext context) {
    final riskColor = RiskLevelColors.getRiskColor(weather);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircleMeterPainter(
          progress: weather.riskScore,
          color: riskColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Risiko Saat Ini',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: size * .085,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                weather.getRiskLevel,
                style: TextStyle(
                  color: riskColor,
                  fontSize: size * .18,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (weather.riskState == RiskState.incomplete) ...[
                const SizedBox(height: 4),
                Text(
                  'Data belum lengkap',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: size * .052,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Icon(
                Icons.air,
                color: riskColor.withValues(alpha: .8),
                size: size * .18,
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
    final radius = size.width / 2 - 10;
    final strokeWidth = (size.width * .06).clamp(13.0, 17.0).toDouble();
    final background = Paint()
      ..color = const Color(0xFFE8EEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final foreground = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0, 1),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleMeterPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
