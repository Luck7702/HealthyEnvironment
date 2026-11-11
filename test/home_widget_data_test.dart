import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/services/environment.dart';
import 'package:lingkungan_sehat/services/home_widget_data.dart';

void main() {
  test('widget values summarise the current reading', () {
    const data = EnvData(
      location: 'Jakarta',
      localTime: '21:04',
      weather: Weather(ispu: 173, uv: 0, temp: 33),
      status: EnvironmentStatus.success,
    );
    expect(homeWidgetValues(data), {
      'location': 'Jakarta',
      'risk_level': 'Tinggi',
      'risk_color': '#D93F39',
      'details': 'ISPU 173 · UV 0 · 33°C',
      'updated': 'Diperbarui 21:04',
    });
  });

  test('no widget values without a successful reading', () {
    const data = EnvData(
      location: '',
      weather: Weather.emptyWeather,
      status: EnvironmentStatus.networkError,
    );
    expect(homeWidgetValues(data), isNull);
  });
}
