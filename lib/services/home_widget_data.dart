import '../models/weather.dart';
import 'environment.dart';

/// Colours matching the app's Rendah / Sedang / Tinggi palette.
const _riskColors = {
  'Rendah': '#1F9964',
  'Sedang': '#D96F00',
  'Tinggi': '#D93F39',
};

/// Values read by the Android widget (RiskWidgetProvider.kt), or null when
/// there is no successful reading to show.
Map<String, String>? homeWidgetValues(EnvData data) {
  final weather = data.weather;
  if (data.status != EnvironmentStatus.success ||
      weather.riskState == RiskState.unknown) {
    return null;
  }
  final level = weather.getRiskLevel;
  final feltTemperature = weather.heatIndex ?? weather.temp;
  final details = [
    if (weather.ispu != null) 'ISPU ${weather.ispu}',
    if (weather.uv != null) 'UV ${weather.uv!.toStringAsFixed(0)}',
    if (feltTemperature != null) '${feltTemperature.toStringAsFixed(0)}°C',
  ].join(' · ');
  return {
    'location': data.location,
    'risk_level': level,
    'risk_color': _riskColors[level] ?? '#527069',
    'details': details,
    'updated': data.localTime.isEmpty ? '' : 'Diperbarui ${data.localTime}',
  };
}
