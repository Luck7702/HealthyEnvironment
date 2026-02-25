import 'package:flutter/material.dart';
import 'package:LingkunganSehat/screens/home.dart';
import 'package:LingkunganSehat/config/app_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Outdoor Readiness',
      theme: AppConfig.currentTheme,
      home: const HomeScreen(),
    );
  }
}
