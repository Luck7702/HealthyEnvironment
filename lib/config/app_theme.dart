import 'package:flutter/material.dart';

class AppColors {
  static const page = Color(0xFFE8F9F1);
  static const card = Color(0xFFFFFEFC);
  static const ink = Color(0xFF0B3048);
  static const forest = Color(0xFF0B4B42);
  static const muted = Color(0xFF6B86A5);
  static const green = Color(0xFF41A968);
  static const greenSoft = Color(0xFFE1F6EC);
  static const greenBorder = Color(0xFFACDEC7);
  static const orange = Color(0xFFFF8B0A);
  static const orangeSoft = Color(0xFFFFF4DF);
  static const coral = Color(0xFFF2554D);
  static const coralSoft = Color(0xFFFFE9E8);
  static const blue = Color(0xFF54A9F4);
  static const blueSoft = Color(0xFFE8F4FF);
  static const line = Color(0xFFD7EEE4);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.forest,
          onPrimary: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.ink,
          secondary: AppColors.green,
          onSecondary: Colors.white,
          error: AppColors.coral,
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.page,
      canvasColor: AppColors.page,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
        fontFamily: 'Roboto',
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.green,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFF7BD39B),
            secondary: const Color(0xFF7BD39B),
            error: const Color(0xFFFF827B),
          ),
      scaffoldBackgroundColor: const Color(0xFF102522),
      canvasColor: const Color(0xFF102522),
      textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    );
  }
}
