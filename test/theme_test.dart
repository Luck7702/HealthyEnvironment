import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/config/app_theme.dart';
import 'package:lingkungan_sehat/config/theme_controller.dart';

class _MemoryThemePreferenceStore implements ThemePreferenceStore {
  bool? darkMode;

  _MemoryThemePreferenceStore([this.darkMode]);

  @override
  Future<bool?> readDarkMode() async => darkMode;

  @override
  Future<void> writeDarkMode(bool enabled) async {
    darkMode = enabled;
  }
}

void main() {
  tearDown(() => appThemeMode.value = ThemeMode.light);

  test('theme preference loads and persists', () async {
    final store = _MemoryThemePreferenceStore(true);

    await loadThemePreference(store: store);
    expect(appThemeMode.value, ThemeMode.dark);

    await setDarkMode(false, store: store);
    expect(appThemeMode.value, ThemeMode.light);
    expect(store.darkMode, isFalse);
  });

  test('light and dark themes expose complete distinct palettes', () {
    final light = AppTheme.light.extension<AppColors>();
    final dark = AppTheme.dark.extension<AppColors>();

    expect(light, isNotNull);
    expect(dark, isNotNull);
    expect(light!.page, isNot(dark!.page));
    expect(light.card, isNot(dark.card));
    expect(light.ink, isNot(dark.ink));
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
