import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../models/weather.dart';

class RiskLevelColors {
  static Color getRiskColor(BuildContext context, Weather weather) {
    switch (weather.getRiskLevel) {
      case "Rendah":
        return context.appColors.green;
      case "Belum diketahui":
        return context.appColors.muted;
      case "Sedang":
        return context.appColors.orange;
      default:
        return context.appColors.coral;
    }
  }
}

class EnvStatsColors {
  static Color getAqiAccent(BuildContext context, int? aqi) {
    if (aqi == null) return context.appColors.muted;
    if (aqi >= 150) return context.appColors.coral;
    if (aqi >= 100) return context.appColors.orange;
    return context.appColors.green;
  }

  static Color getUvAccent(BuildContext context, double? uv) {
    if (uv == null) return context.appColors.muted;
    if (uv >= 8) return context.appColors.coral;
    if (uv >= 4) return context.appColors.orange;
    return context.appColors.green;
  }

  static Color getTempAccent(BuildContext context, double? temp) {
    if (temp == null) return context.appColors.muted;
    if (temp >= 30) return context.appColors.coral;
    if (temp > 27) return context.appColors.orange;
    return context.appColors.green;
  }
}
