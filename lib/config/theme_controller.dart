import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themePreferenceKey = 'lingkungan_sehat.dark_mode';

abstract interface class ThemePreferenceStore {
  Future<bool?> readDarkMode();

  Future<void> writeDarkMode(bool enabled);
}

class LocalThemePreferenceStore implements ThemePreferenceStore {
  final SharedPreferencesAsync _preferences;

  LocalThemePreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<bool?> readDarkMode() => _preferences.getBool(_themePreferenceKey);

  @override
  Future<void> writeDarkMode(bool enabled) =>
      _preferences.setBool(_themePreferenceKey, enabled);
}

final ThemePreferenceStore _localThemePreferences = LocalThemePreferenceStore();

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

Future<void> loadThemePreference({ThemePreferenceStore? store}) async {
  try {
    final darkMode = await (store ?? _localThemePreferences).readDarkMode();
    appThemeMode.value = darkMode == true ? ThemeMode.dark : ThemeMode.light;
  } on Exception {
    appThemeMode.value = ThemeMode.light;
  }
}

Future<void> setDarkMode(bool enabled, {ThemePreferenceStore? store}) async {
  appThemeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  try {
    await (store ?? _localThemePreferences).writeDarkMode(enabled);
  } on Exception {
    // Keep selected theme for current session when local storage is unavailable.
  }
}
