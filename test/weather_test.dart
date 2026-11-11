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

  group('ISPU estimate', () {
    test('matches the regulation worked example', () {
      // Permen LHK P.14/2020 Lampiran I: PM2.5 31.4 µg/m³ -> ISPU 70.
      expect(pm25ISPU(31.4), 70);
      // Same example's PM10 row: 35 µg/m³ -> ISPU 35.
      expect(pm10ISPU(35), 35);
    });

    test('uses official category boundaries', () {
      expect(pm25ISPU(15.5), 50);
      expect(pm25ISPU(55.4), 100);
      expect(pm25ISPU(150.4), 200);
      expect(pm25ISPU(250.4), 300);
      expect(pm25ISPU(56), 101);
      expect(pm10ISPU(50), 50);
      expect(pm10ISPU(150), 100);
      expect(pm10ISPU(350), 200);
      expect(pm10ISPU(420), 300);
      expect(pm25ISPU(900), 500);
    });

    test('selects strongest available particulate reading', () {
      expect(const AirQuality(pm2_5: 10, pm10: 160).ispu, pm10ISPU(160));
      expect(const AirQuality(pm2_5: 163, pm10: 163.4).ispu, 213);
      expect(const AirQuality().ispu, isNull);
    });
  });

  group('environment risk', () {
    test('air quality risk follows ISPU categories with official advice', () {
      expect(const Weather(ispu: 50).componentSeverity['ISPU'], 0);
      expect(const Weather(ispu: 51).componentSeverity['ISPU'], 0.5);
      expect(const Weather(ispu: 101).componentSeverity['ISPU'], 0.75);
      expect(const Weather(ispu: 301).componentSeverity['ISPU'], 1);
      expect(
        const Weather(ispu: 70).recommendations,
        contains(
          'Kelompok sensitif: kurangi aktivitas fisik yang terlalu lama atau berat.',
        ),
      );
      expect(
        const Weather(ispu: 250).recommendations,
        contains('Hindari aktivitas fisik yang terlalu lama di luar ruangan.'),
      );
      expect(
        const Weather(ispu: 320).recommendations,
        contains('Hindari semua aktivitas di luar.'),
      );
    });

    test('each advice is tagged with the hazard it addresses', () {
      const weather = Weather(
        ispu: 120,
        uv: 5,
        temp: 33,
        condition: 'Thunderstorm',
        conditionCode: 1087,
      );
      expect([for (final a in weather.advice) a.hazard], [
        Hazard.air,
        Hazard.uv,
        Hazard.heat,
        Hazard.weather,
      ]);
    });

    test('US AQI alone does not drive the risk score', () {
      const weather = Weather(aqi: 180, uv: 1, temp: 25);
      expect(weather.componentSeverity.containsKey('ISPU'), isFalse);
      expect(weather.riskState, RiskState.incomplete);
    });

    test('all unknown readings stay unknown', () {
      expect(Weather.emptyWeather.riskState, RiskState.unknown);
      expect(Weather.emptyWeather.getRiskLevel, 'Belum diketahui');
    });

    test('strongest known hazard wins when data is partial', () {
      const weather = Weather(ispu: 40, uv: 8);
      expect(weather.riskState, RiskState.incomplete);
      expect(weather.getRiskLevel, 'Tinggi');
      expect(weather.recommendations, isNotEmpty);
    });

    test('core readings are complete without humidity or condition', () {
      const weather = Weather(ispu: 40, uv: 1, temp: 25);
      expect(weather.riskState, RiskState.known);
      expect(weather.getRiskLevel, 'Rendah');
    });

    test('humidity raises heat risk through heat index', () {
      const humid = Weather(ispu: 20, uv: 1, temp: 32, humidity: 80);
      const dry = Weather(ispu: 20, uv: 1, temp: 32, humidity: 35);

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
      const shade = Weather(ispu: 20, uv: 1, temp: 30, humidity: 60);
      const sunny = Weather(
        ispu: 20,
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

    test('dew point comfort follows NWS scale and is not scored', () {
      const humid = Weather(ispu: 20, uv: 1, temp: 25, humidity: 85);
      const mild = Weather(temp: 25, humidity: 50);
      const dry = Weather(temp: 25, humidity: 30);
      expect(humid.dewPoint, closeTo(22.3, 0.2));
      expect(humid.dewPointComfort, 2);
      expect(mild.dewPointComfort, 1);
      expect(dry.dewPointComfort, 0);
      expect(humid.componentSeverity.containsKey('Kelembapan'), isFalse);
      expect(humid.getRiskLevel, 'Rendah');
      expect(dry.recommendations, isEmpty);
    });

    test('cold air does not raise risk', () {
      const weather = Weather(ispu: 20, uv: 1, temp: -5);
      expect(weather.componentSeverity['Suhu'], 0);
      expect(weather.getRiskLevel, 'Rendah');
      expect(weather.recommendations, isEmpty);
    });

    test('temperature risk falls back to air temperature without humidity', () {
      const weather = Weather(ispu: 20, uv: 1, temp: 33);
      expect(weather.heatIndex, isNull);
      expect(weather.getRiskLevel, 'Sedang');
    });

    test('invalid humidity does not distort temperature risk', () {
      const weather = Weather(ispu: 20, uv: 1, temp: 33, humidity: 101);
      expect(weather.heatIndex, isNull);
      expect(weather.getRiskLevel, 'Sedang');
    });

    test('unsupported condition does not downgrade complete core readings', () {
      const weather = Weather(
        ispu: 40,
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
        ispu: 156,
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
        contains('Kurangi aktivitas fisik yang terlalu lama di luar ruangan.'),
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
        ispu: 20,
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

    test('fog is moderate weather risk but mist is not', () {
      const fog = Weather(condition: 'Fog', conditionCode: 1135);
      const freezingFog = Weather(condition: 'Freezing fog', conditionCode: 1147);
      const mist = Weather(condition: 'Mist', conditionCode: 1030);
      const fogText = Weather(condition: 'Kabut');
      expect(fog.componentSeverity['Cuaca'], 0.5);
      expect(freezingFog.componentSeverity['Cuaca'], 0.5);
      expect(fogText.componentSeverity['Cuaca'], 0.5);
      expect(mist.componentSeverity['Cuaca'], 0);
      expect(
        fog.recommendations,
        contains('Waspadai cuaca buruk; berhati-hati saat berkendara.'),
      );
    });

    test('severe non-thunder weather does not produce lightning advice', () {
      const weather = Weather(
        ispu: 20,
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
