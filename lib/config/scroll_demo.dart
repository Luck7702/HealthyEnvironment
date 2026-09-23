import 'package:flutter/foundation.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/services/environment.dart';

const scrollDemoEnabled = kDebugMode && bool.fromEnvironment('SCROLL_DEMO');

const scrollDemoRecommendations = [
  'Saran uji 1: Perhatikan kondisi udara sebelum beraktivitas di luar.',
  'Saran uji 2: Gunakan pelindung saat indeks UV sedang tinggi.',
  'Saran uji 3: Minum cukup air saat cuaca terasa panas.',
  'Saran uji 4: Cari tempat teduh saat matahari terik.',
  'Saran uji 5: Siapkan payung jika hujan mulai turun.',
  'Saran uji 6: Periksa kondisi jalan sebelum berkendara.',
  'Saran uji 7: Kurangi aktivitas berat saat udara kurang baik.',
  'Saran uji 8: Pantau perubahan cuaca sepanjang hari.',
];

Future<EnvData> loadScrollDemoEnvironment({String? query}) async =>
    const EnvData(
      location: 'Lokasi uji',
      localTime: 'Demo',
      weather: Weather(
        aqi: 134,
        uv: 6.1,
        temp: 32.9,
        humidity: 68,
        condition: 'Light rain',
        conditionCode: 1183,
      ),
      status: EnvironmentStatus.success,
    );
