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

    test('core readings are complete without humidity or condition', () {
      const weather = Weather(aqi: 40, uv: 1, temp: 25);
      expect(weather.riskState, RiskState.known);
      expect(weather.getRiskLevel, 'Rendah');
    });

    test('humidity raises heat risk through heat index', () {
      const humid = Weather(aqi: 20, uv: 1, temp: 32, humidity: 80);
      const dry = Weather(aqi: 20, uv: 1, temp: 32, humidity: 35);

      expect(humid.heatIndex, closeTo(44.4, 0.1));
      expect(dry.heatIndex, closeTo(31.5, 0.1));
      expect(humid.heatCategory, 3);
      expect(dry.heatCategory, 1);
      expect(humid.getRiskLevel, 'Tinggi');
      expect(dry.getRiskLevel, 'Rendah');
    });

    test('heat uses NWS heat index classification boundaries', () {
      // 80, 90, 103 and 125 °F without humidity, so heat index is air temp.
      expect(const Weather(temp: 26.6).heatCategory, 0);
      expect(const Weather(temp: 26.7).heatCategory, 1);
      expect(const Weather(temp: 32.3).heatCategory, 2);
      expect(const Weather(temp: 39.5).heatCategory, 3);
      expect(const Weather(temp: 51.7).heatCategory, 4);
      expect(const Weather(temp: 32.3).heatSeverity, 0.5);
      expect(const Weather(temp: 39.5).heatSeverity, 0.75);
    });

    test('direct sun raises heat risk one level', () {
      const shade = Weather(aqi: 20, uv: 1, temp: 30, humidity: 60);
      const sunny = Weather(
        aqi: 20,
        uv: 9,
        temp: 30,
        humidity: 60,
        condition: 'Sunny',
        conditionCode: 1000,
        isDay: true,
      );
      expect(shade.heatRiskCategory, 2);
      expect(shade.componentSeverity['Suhu'], 0.5);
      expect(sunny.inDirectSun, isTrue);
      expect(sunny.heatRiskCategory, 3);
      expect(sunny.componentSeverity['Suhu'], 0.75);
      expect(
        sunny.recommendations,
        contains('Cari tempat teduh, minum cukup, dan kurangi aktivitas berat.'),
      );
    });

    test('caution heat becomes moderate only in direct sun', () {
      const night = Weather(
        temp: 28,
        humidity: 75,
        condition: 'Clear',
        conditionCode: 1000,
        isDay: false,
      );
      const overcastDay = Weather(
        temp: 28,
        humidity: 75,
        condition: 'Overcast',
        conditionCode: 1009,
        isDay: true,
      );
      const sunnyDay = Weather(
        temp: 28,
        humidity: 75,
        condition: 'Partly cloudy',
        conditionCode: 1003,
        isDay: true,
      );
      expect(night.componentSeverity['Suhu'], 0);
      expect(overcastDay.componentSeverity['Suhu'], 0);
      expect(sunnyDay.componentSeverity['Suhu'], 0.5);
    });

    test('cold air does not raise risk', () {
      const weather = Weather(aqi: 20, uv: 1, temp: -5);
      expect(weather.componentSeverity['Suhu'], 0);
      expect(weather.getRiskLevel, 'Rendah');
      expect(weather.recommendations, isEmpty);
    });

    test('temperature risk falls back to air temperature without humidity', () {
      const weather = Weather(aqi: 20, uv: 1, temp: 33);
      expect(weather.heatIndex, isNull);
      expect(weather.getRiskLevel, 'Sedang');
    });

    test('invalid humidity does not distort temperature risk', () {
      const weather = Weather(aqi: 20, uv: 1, temp: 33, humidity: 101);
      expect(weather.heatIndex, isNull);
      expect(weather.getRiskLevel, 'Sedang');
    });

    test('unsupported condition does not downgrade complete core readings', () {
      const weather = Weather(
        aqi: 40,
        uv: 1,
        temp: 25,
        humidity: 60,
        condition: 'New upstream condition',
        conditionCode: 9999,
      );
      expect(weather.riskState, RiskState.known);
      expect(weather.getRiskLevel, 'Rendah');
    });

    test('smoky haze is classified without duplicating high AQI advice', () {
      const weather = Weather(
        aqi: 156,
        uv: 0,
        temp: 28.6,
        humidity: 66,
        condition: 'Smoky haze',
        conditionCode: 1036,
      );
      expect(weather.riskState, RiskState.known);
      expect(weather.getRiskLevel, 'Tinggi');
      expect(
        weather.recommendations,
        contains('Kurangi aktivitas luar; gunakan masker yang sesuai.'),
      );
      expect(
        weather.recommendations,
        isNot(
          contains(
            'Kurangi aktivitas luar dan gunakan masker saat udara berasap.',
          ),
        ),
      );
    });

    test('smoky haze contributes risk and advice when AQI is unavailable', () {
      const weather = Weather(
        uv: 0,
        temp: 28.6,
        humidity: 66,
        condition: 'Smoky haze',
        conditionCode: 1036,
      );
      expect(weather.riskState, RiskState.incomplete);
      expect(weather.getRiskLevel, 'Sedang');
      expect(
        weather.recommendations,
        contains(
          'Kurangi aktivitas luar dan gunakan masker saat udara berasap.',
        ),
      );
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

    test('severe non-thunder weather does not produce lightning advice', () {
      const weather = Weather(
        aqi: 20,
        uv: 1,
        temp: 25,
        condition: 'Blizzard',
        conditionCode: 1117,
      );
      expect(weather.getRiskLevel, 'Tinggi');
      expect(
        weather.recommendations,
        contains('Waspadai cuaca buruk; berhati-hati saat berkendara.'),
      );
      expect(
        weather.recommendations,
        isNot(contains('Berlindung di dalam saat ada petir.')),
      );
    });
  });
}
