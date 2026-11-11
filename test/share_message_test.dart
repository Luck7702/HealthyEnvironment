import 'package:flutter_test/flutter_test.dart';

import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/services/environment.dart';
import 'package:lingkungan_sehat/services/share_message.dart';

void main() {
  test('shares current risk and readings when data is available', () {
    const data = EnvData(
      location: 'Jakarta',
      weather: Weather(ispu: 173, uv: 0, temp: 33),
      status: EnvironmentStatus.success,
    );
    expect(
      shareMessage(data),
      'Risiko di luar ruangan di Jakarta sekarang: Tinggi '
      '(ISPU 173, UV 0, terasa 33°C).\n'
      'Cek lokasimu di LingkunganSehat: https://app.lingkungansehat.my.id',
    );
  });

  test('falls back to a generic invitation without data', () {
    const data = EnvData(
      location: '',
      weather: Weather.emptyWeather,
      status: EnvironmentStatus.networkError,
    );
    expect(shareMessage(data), contains('di lokasimu'));
    expect(shareMessage(data), endsWith('https://app.lingkungansehat.my.id'));
  });
}
