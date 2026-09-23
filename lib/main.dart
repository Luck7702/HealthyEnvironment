import 'package:flutter/material.dart';
import 'package:lingkungan_sehat/config/app_theme.dart';
import 'package:lingkungan_sehat/config/scroll_demo.dart';
import 'package:lingkungan_sehat/config/theme_controller.dart';
import 'package:lingkungan_sehat/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemePreference();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lingkungan Sehat',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: HomeScreen(
            environmentLoader: scrollDemoEnabled
                ? loadScrollDemoEnvironment
                : null,
          ),
        );
      },
    );
  }
}
