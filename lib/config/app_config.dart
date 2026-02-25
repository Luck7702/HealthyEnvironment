import 'package:flutter/material.dart';
import 'package:LingkunganSehat/config/colors_theme.dart';

class AppConfig {
  
  static ThemeData currentTheme = whiteTheme;
  

  // API endpoints
  static const weatherBaseUrl = "https://api.openweathermap.org/data/2.5";

  static const geoBaseUrl = "https://api.openweathermap.org/geo/1.0";

  // Default behavior
  static const units = "metric";
  static const requestTimeoutSeconds = 10;
}
