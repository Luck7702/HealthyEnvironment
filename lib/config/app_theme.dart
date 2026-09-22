import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color page;
  final Color pageEnd;
  final Color card;
  final Color ink;
  final Color forest;
  final Color muted;
  final Color green;
  final Color greenSoft;
  final Color greenBorder;
  final Color orange;
  final Color orangeSoft;
  final Color coral;
  final Color coralSoft;
  final Color blue;
  final Color blueSoft;
  final Color line;
  final Color meterTrack;
  final Color illustrationOverlay;

  const AppColors({
    required this.page,
    required this.pageEnd,
    required this.card,
    required this.ink,
    required this.forest,
    required this.muted,
    required this.green,
    required this.greenSoft,
    required this.greenBorder,
    required this.orange,
    required this.orangeSoft,
    required this.coral,
    required this.coralSoft,
    required this.blue,
    required this.blueSoft,
    required this.line,
    required this.meterTrack,
    required this.illustrationOverlay,
  });

  static const light = AppColors(
    page: Color(0xFFE8F9F1),
    pageEnd: Color(0xFFEEFCF6),
    card: Color(0xFFFFFEFC),
    ink: Color(0xFF0B3048),
    forest: Color(0xFF0B4B42),
    muted: Color(0xFF5D7896),
    green: Color(0xFF278653),
    greenSoft: Color(0xFFE1F6EC),
    greenBorder: Color(0xFFACDEC7),
    orange: Color(0xFFD96F00),
    orangeSoft: Color(0xFFFFF4DF),
    coral: Color(0xFFD93F39),
    coralSoft: Color(0xFFFFE9E8),
    blue: Color(0xFF267FC4),
    blueSoft: Color(0xFFE8F4FF),
    line: Color(0xFFD7EEE4),
    meterTrack: Color(0xFFDCE8E4),
    illustrationOverlay: Color(0x00FFFFFF),
  );

  static const dark = AppColors(
    page: Color(0xFF0C1B19),
    pageEnd: Color(0xFF122824),
    card: Color(0xFF172D29),
    ink: Color(0xFFE4F1ED),
    forest: Color(0xFFA4E4C0),
    muted: Color(0xFFA9BDB7),
    green: Color(0xFF7BD39B),
    greenSoft: Color(0xFF1E4436),
    greenBorder: Color(0xFF356B55),
    orange: Color(0xFFFFB45C),
    orangeSoft: Color(0xFF4A351B),
    coral: Color(0xFFFF8A84),
    coralSoft: Color(0xFF4B2929),
    blue: Color(0xFF82C5FF),
    blueSoft: Color(0xFF203C52),
    line: Color(0xFF2C4841),
    meterTrack: Color(0xFF30443F),
    illustrationOverlay: Color(0x66102723),
  );

  @override
  AppColors copyWith({
    Color? page,
    Color? pageEnd,
    Color? card,
    Color? ink,
    Color? forest,
    Color? muted,
    Color? green,
    Color? greenSoft,
    Color? greenBorder,
    Color? orange,
    Color? orangeSoft,
    Color? coral,
    Color? coralSoft,
    Color? blue,
    Color? blueSoft,
    Color? line,
    Color? meterTrack,
    Color? illustrationOverlay,
  }) {
    return AppColors(
      page: page ?? this.page,
      pageEnd: pageEnd ?? this.pageEnd,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      forest: forest ?? this.forest,
      muted: muted ?? this.muted,
      green: green ?? this.green,
      greenSoft: greenSoft ?? this.greenSoft,
      greenBorder: greenBorder ?? this.greenBorder,
      orange: orange ?? this.orange,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      coral: coral ?? this.coral,
      coralSoft: coralSoft ?? this.coralSoft,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      line: line ?? this.line,
      meterTrack: meterTrack ?? this.meterTrack,
      illustrationOverlay: illustrationOverlay ?? this.illustrationOverlay,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      page: Color.lerp(page, other.page, t)!,
      pageEnd: Color.lerp(pageEnd, other.pageEnd, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      forest: Color.lerp(forest, other.forest, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenSoft: Color.lerp(greenSoft, other.greenSoft, t)!,
      greenBorder: Color.lerp(greenBorder, other.greenBorder, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      orangeSoft: Color.lerp(orangeSoft, other.orangeSoft, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      line: Color.lerp(line, other.line, t)!,
      meterTrack: Color.lerp(meterTrack, other.meterTrack, t)!,
      illustrationOverlay: Color.lerp(
        illustrationOverlay,
        other.illustrationOverlay,
        t,
      )!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors {
    final theme = Theme.of(this);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
  }
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.light);

  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.green,
          brightness: brightness,
          surface: colors.card,
          error: colors.coral,
        ).copyWith(
          primary: colors.forest,
          onPrimary: brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF052019),
          secondary: colors.green,
          onSecondary: brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF082016),
          surface: colors.card,
          onSurface: colors.ink,
          onSurfaceVariant: colors.muted,
          outline: colors.greenBorder,
          outlineVariant: colors.line,
          error: colors.coral,
          errorContainer: colors.coralSoft,
          onErrorContainer: colors.ink,
        );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.page,
      canvasColor: colors.page,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: colors.line),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        labelStyle: TextStyle(color: colors.muted),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.greenBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.green, width: 2),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: colors.ink,
        displayColor: colors.ink,
        fontFamily: 'Roboto',
      ),
    );
  }
}
