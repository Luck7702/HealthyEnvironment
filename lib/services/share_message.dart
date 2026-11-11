import '../models/weather.dart';
import 'environment.dart';

const appUrl = 'https://app.lingkungansehat.my.id';

/// Text for the share button. With current readings it shares the actual
/// risk, so the message is useful to the recipient; otherwise a generic
/// invitation.
String shareMessage(EnvData data) {
  final weather = data.weather;
  if (data.status != EnvironmentStatus.success ||
      weather.riskState == RiskState.unknown) {
    return 'Cek risiko kesehatan di luar ruangan di lokasimu dengan '
        'LingkunganSehat.\n$appUrl';
  }

  final details = <String>[
    if (weather.ispu != null) 'ISPU ${weather.ispu}',
    if (weather.uv != null) 'UV ${weather.uv!.toStringAsFixed(0)}',
    if ((weather.heatIndex ?? weather.temp) != null)
      'terasa ${(weather.heatIndex ?? weather.temp)!.toStringAsFixed(0)}°C',
  ];
  final place = data.location.trim().isEmpty ? '' : ' di ${data.location}';
  final detailText = details.isEmpty ? '' : ' (${details.join(', ')})';
  return 'Risiko di luar ruangan$place sekarang: '
      '${weather.getRiskLevel}$detailText.\n'
      'Cek lokasimu di LingkunganSehat: $appUrl';
}
