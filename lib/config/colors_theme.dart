import 'package:flutter/material.dart';

import '../models/weather.dart';

class RiskLevelColors {
  static Color getRiskColor(Weather weather) {
    // Color for RiskMeter and RiskCard
    switch (weather.getRiskLevel) {
      case "Rendah":
        return Colors.green;
      case "Sedang":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

class EnvStatsColors {
  static Color getAqiAccent(int aqi) {
    if (aqi >= 150) {return Colors.red;} 
    else if (aqi >= 100) {return Colors.orange; }
    return Colors.green;
  }

  static Color getUvAccent(int uv) {
    if (uv >= 8) {return Colors.red;} 
    else if (uv >= 4) {return Colors.orange;}
    return Colors.green;
  }

  static Color getTempAccent(int temp){
    if(temp >= 30){return Colors.red;}
    else if(temp > 27){return Colors.orange;};
    return Colors.green;
  }
}

final ThemeData whiteTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFEAF7EF),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Color.fromARGB(255, 6, 29, 15),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
);
