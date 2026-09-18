import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/airquality.dart';
import 'package:lingkungan_sehat/models/weather.dart';

void main() {
  group('AQI estimate', () {
    test('uses current EPA PM2.5 breakpoint boundaries', () {
      expect(pm25AQI(9.0).round(), 50);
      expect(pm25AQI(9.1).round(), 51);
      expect(pm25AQI(35.4).round(), 100);
      expect(pm25AQI(35.5).round(), 101);
    });

    test('selects strongest available particulate reading', () {
      expect(const AirQuality(pm2_5: 9, pm10: 154).aqi, 100);
      expect(const AirQuality().aqi, isNull);
    });
  });

  group('environment risk', () {
    test('all unknown readings stay unknown', () {
      expect(Weather.emptyWeather.riskState, RiskState.unknown);
      expect(Weather.emptyWeather.getRiskLevel, 'Belum diketahui');
    });

    test('strongest known hazard wins when data is partial', () {
      const weather = Weather(aqi: 40, uv: 8);
      expect(weather.riskState, RiskState.incomplete);
      expect(weather.getRiskLevel, 'Tinggi');
      expect(weather.recommendations, isNotEmpty);
    });

    test('weather condition contributes to risk', () {
      const weather = Weather(
        aqi: 20,
        uv: 1,
        temp: 25,
        humidity: 60,
        condition: 'Thunderstorm',
        conditionCode: 1087,
      );
      expect(weather.riskState, RiskState.known);
      expect(weather.getRiskLevel, 'Tinggi');
      expect(
        weather.recommendations,
        contains('Berlindung di dalam saat ada petir.'),
      );
    });
  });
}
