import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../models/weather.dart';

class RiskLevelColors {
  static Color getRiskColor(Weather weather) {
    switch (weather.getRiskLevel) {
      case "Rendah":
        return AppColors.green;
      case "Sedang":
        return AppColors.orange;
      default:
        return AppColors.coral;
    }
  }
}

class EnvStatsColors {
  static Color getAqiAccent(int aqi) {
    if (aqi >= 150) return AppColors.coral;
    if (aqi >= 100) return AppColors.orange;
    return AppColors.green;
  }

  static Color getUvAccent(double uv) {
    if (uv >= 8) return AppColors.coral;
    if (uv >= 4) return AppColors.orange;
    return AppColors.green;
  }

  static Color getTempAccent(double temp) {
    if (temp >= 30) return AppColors.coral;
    if (temp > 27) return AppColors.orange;
    return AppColors.green;
  }
}
