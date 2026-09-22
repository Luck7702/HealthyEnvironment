import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

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
}
