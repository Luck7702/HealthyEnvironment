import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themePreferenceKey = 'lingkungan_sehat.dark_mode';
final _preferences = SharedPreferencesAsync();

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

Future<void> loadThemePreference() async {
  try {
    final darkMode = await _preferences.getBool(_themePreferenceKey);
    appThemeMode.value = darkMode == true ? ThemeMode.dark : ThemeMode.light;
  } on Exception {
    appThemeMode.value = ThemeMode.light;
  }
}

Future<void> setDarkMode(bool enabled) async {
  appThemeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  try {
    await _preferences.setBool(_themePreferenceKey, enabled);
  } on Exception {
    // Keep selected theme for current session when local storage is unavailable.
  }
}
