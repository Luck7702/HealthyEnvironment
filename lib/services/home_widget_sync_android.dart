import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'environment.dart';
import 'home_widget_data.dart';

/// Android provider class name (android/app/src/main/kotlin/.../RiskWidgetProvider.kt).
const _androidProvider = 'RiskWidgetProvider';

/// Saves the latest reading for the Android home-screen widget and asks it to
/// redraw. The widget only shows what the app last loaded; it does not fetch
/// data on its own.
Future<void> syncHomeWidget(EnvData data) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final values = homeWidgetValues(data);
  if (values == null) return;
  try {
    for (final entry in values.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }
    await HomeWidget.updateWidget(androidName: _androidProvider);
  } catch (_) {
    // Widget support is optional; never let it break the app.
  }
}
