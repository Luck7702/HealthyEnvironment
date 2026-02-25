import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../config/colors_theme.dart';

class RiskCard extends StatelessWidget {
  final Weather weather;

  const RiskCard({super.key, required this.weather});

   Color get riskColor => RiskLevelColors.getRiskColor(weather);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: riskColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: riskColor, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Risiko Hari Ini", style: TextStyle(fontSize: 16)),
                Text(
                  weather.getRiskLevel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
