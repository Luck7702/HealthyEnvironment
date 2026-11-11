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
  /// Colour for a component severity from [Weather.componentSeverity]:
  /// green Rendah, orange Sedang, coral Tinggi.
  static Color forSeverity(BuildContext context, double? severity) {
    if (severity == null) return context.appColors.muted;
    if (severity >= 0.75) return context.appColors.coral;
    if (severity >= 0.5) return context.appColors.orange;
    return context.appColors.green;
  }
}
