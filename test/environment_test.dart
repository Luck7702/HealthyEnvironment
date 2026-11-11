import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:lingkungan_sehat/models/airquality.dart';
import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/services/environment.dart';

void main() {
  test('failure statuses have actionable messages', () {
    expect(
      environmentErrorMessage(EnvironmentStatus.locationUnavailable),
      contains('lokasi'),
    );
    expect(
      environmentErrorMessage(EnvironmentStatus.networkError),
      contains('Koneksi'),
    );
    expect(
      environmentErrorMessage(EnvironmentStatus.empty),
      contains('Data lingkungan'),
    );
    expect(
      environmentErrorIsRetryable(EnvironmentStatus.serverMisconfigured),
      isFalse,
    );
    expect(environmentErrorIsRetryable(EnvironmentStatus.networkError), isTrue);
    expect(
      environmentErrorNeedsLocationChoice(EnvironmentStatus.locationNotFound),
      isTrue,
    );
  });

  test('empty weather explicitly represents unavailable readings', () {
    const data = EnvData(
      location: '',
      weather: Weather.emptyWeather,
      status: EnvironmentStatus.locationUnavailable,
    );
    expect(data.status, EnvironmentStatus.locationUnavailable);
    expect(data.location, isEmpty);
    expect(data.weather.riskState, RiskState.unknown);
  });

  test('malformed API payload is rejected instead of creating readings', () {
    expect(EnvironmentService.parseEnvironmentPayload({}), {
      'status': EnvironmentStatus.invalidResponse,
    });
    expect(EnvironmentService.parseEnvironmentPayload(null), {
      'status': EnvironmentStatus.invalidResponse,
    });
  });

  test('valid payload maps numeric readings and condition code', () {
    final result = EnvironmentService.parseEnvironmentPayload({
      'location': {'name': 'Jakarta', 'localtime': '2026-09-20 17:00'},
      'current': {
        'temp_c': 30.4,
        'humidity': 70,
        'uv': 5.2,
        'condition': {'text': 'Sunny', 'code': 1000},
        'air_quality': {'pm2_5': 10.0, 'pm10': 20.0},
      },
    });
    expect(result['status'], EnvironmentStatus.success);
    expect(result['temp'], 30.4);
    expect(result['condition'], 'Sunny');
    expect(result['conditionCode'], 1000);
    expect(result.containsKey('isDay'), isFalse);
    expect(result['ispu'], pm25ISPU(10.0));
    expect(result['aqi'], isNotNull);
  });

  test('day/night flag maps to isDay and ignores invalid values', () {
    Map<String, dynamic> parse(dynamic isDay) =>
        EnvironmentService.parseEnvironmentPayload({
          'location': {'name': 'Jakarta', 'localtime': '2026-11-11 12:00'},
          'current': {
            'temp_c': 31.0,
            'is_day': isDay,
            'condition': {'text': 'Sunny', 'code': 1000},
          },
        });

    expect(parse(1)['isDay'], isTrue);
    expect(parse(0)['isDay'], isFalse);
    expect(parse('1').containsKey('isDay'), isFalse);
  });

  test('partial payload preserves valid readings', () {
    final result = EnvironmentService.parseEnvironmentPayload({
      'location': {'name': 'Jakarta', 'localtime': '2026-09-20 17:00'},
      'current': {
        'temp_c': 30.4,
        'condition': <String, dynamic>{},
        'air_quality': <String, dynamic>{},
      },
    });
    expect(result['status'], EnvironmentStatus.success);
    expect(result['temp'], 30.4);
    expect(result['aqi'], isNull);
  });

  test('proxy error codes map to actionable statuses', () async {
    final result = await EnvironmentService.fetchEnvironment(
      'Jakarta',
      httpGet: (_) async => http.Response(
        '{"error":{"code":"location_not_found","message":"missing"}}',
        404,
      ),
    );
    expect(result?['status'], EnvironmentStatus.locationNotFound);
  });

  test('failed manual request preserves requested location', () async {
    final data = await loadEnvironment(
      query: 'Bandung',
      fetcher: (_) async => {'status': EnvironmentStatus.serverMisconfigured},
    );

    expect(data.status, EnvironmentStatus.serverMisconfigured);
    expect(data.location, 'Bandung');
  });

  test('GPS position is rounded to two decimals before requesting', () async {
    String? requested;
    await loadEnvironment(
      locationResolver: () async => Position(
        latitude: -6.200412,
        longitude: 106.816633,
        timestamp: DateTime(2026),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      ),
      fetcher: (query) async {
        requested = query;
        return {'status': EnvironmentStatus.networkError};
      },
    );
    expect(requested, '-6.20,106.82');
  });
}
