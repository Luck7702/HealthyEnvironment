import 'dart:io';

import 'package:flutter/material.dart';
import 'package:LingkunganSehat/models/weather.dart';
import 'package:LingkunganSehat/screens/information.dart';
import 'package:LingkunganSehat/screens/settings.dart';
import 'package:LingkunganSehat/services/environment.dart';
import 'package:LingkunganSehat/widgets/env_stats.dart';
import 'package:LingkunganSehat/widgets/location_bar.dart';
import 'package:LingkunganSehat/widgets/recommendation_list.dart';
import 'package:LingkunganSehat/widgets/risk_meter.dart';
import 'package:LingkunganSehat/widgets/window_dialog.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  bool locationAvailable = true;

  EnvData envData = EnvData(
    location: "Mengambil lokasi...",
    weather: emptyWeather(),
    status: 'Awaiting...',
  );

  @override
  void initState() {
    super.initState();
    dataRefresh();
  }

  void setHomeState(EnvData envDataFresh) {
    setState(() {
      envData = envDataFresh;
      loading = false;
      locationAvailable = true;
    });
  }

  void handleError(String status) async {
    switch (envData.status) {
      case "Data is Empty":
        setState(() {
          loading = false;
        });
        break;

      case "Failed to Connect":
        await InfoDialog.show(
          context,
          title: "Gagal Mendapatkan Lokasi",
          message: "Mohon cek kembali koneksi internet",
        );
        loadEnvironment(response: handleError);

      default:
        break;
    }

    return;
  }

  Future<void> initializeEnvironment({String? query, bool? something}) async {
    final envData = await loadEnvironment(query: query);
    if (envData.status != "Success") {
      handleError(envData.status);
    } else {
      setHomeState(envData);
    }
  }

  void dataRefresh() async {
    while (true) {
      initializeEnvironment();
      debugPrint("Environment Fetched");
      await Future.delayed(const Duration(minutes: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 100, 255, 105),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "Enviroment App",
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share("Cek Aplikasi Ini", subject: 'Share');
            },
          ),

          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InformationScreen()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => initializeEnvironment(),
              child: GestureDetector(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    GestureDetector(
                      child: LocationBar(
                        available: locationAvailable,
                        location: envData.location,
                        onRetry: () => initializeEnvironment(),
                      ),
                      onTap: () {
                        showInputPrompt(context, (value) {
                          if (value.isNotEmpty &&
                              !value.contains(RegExp(r'\d'))) {
                            initializeEnvironment(query: value);
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    Center(child: RiskMeter(weather: envData.weather)),

                    // Center(child: Text("Risk Score: ${w.riskScore}")), // Debug
                    const SizedBox(height: 16),
                    EnvStats(weather: envData.weather),
                    const SizedBox(height: 24),
                    RecommendationSection(weather: envData.weather),
                    const SizedBox(height: 24),
                  ],
                ),
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InformationScreen()),
                    );
                  }
                },
              ),
            ),
    );
  }
}
