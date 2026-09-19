import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/colors_theme.dart';
import '../models/weather.dart';
import 'window_dialog.dart';

class EnvStats extends StatelessWidget {
  final Weather weather;
  final bool compactDashboard;
  final bool comfortableDashboard;
  final bool minimalDashboard;
  final double? cardHeight;

  const EnvStats({
    super.key,
    required this.weather,
    this.compactDashboard = false,
    this.comfortableDashboard = false,
    this.minimalDashboard = false,
    this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _StatCard(
            label: 'AQI',
            value: weather.aqi?.toString() ?? '-',
            status: _aqiCardStatus(weather.aqi),
            icon: Icons.cloud,
            accent: EnvStatsColors.getAqiAccent(weather.aqi),
            compact: compactDashboard,
            comfortable: comfortableDashboard,
            minimal: minimalDashboard,
            height: cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Kualitas udara (AQI)',
              currentValue: weather.aqi == null
                  ? 'Belum tersedia'
                  : '${weather.aqi} AQI',
              currentStatus: _aqiStatus(weather.aqi),
              definition:
                  'AQI memperkirakan kualitas udara dari konsentrasi PM2.5 dan PM10 saat ini. Nilai ini bukan AQI harian resmi.',
              impact:
                  'Nilai tinggi dapat mengiritasi mata dan saluran napas. Anak, lansia, dan orang dengan gangguan pernapasan lebih rentan.',
              guidance: _aqiGuidance(weather.aqi),
              icon: Icons.cloud_outlined,
              accent: EnvStatsColors.getAqiAccent(weather.aqi),
              ranges: const [
                InfoRange('0-50', 'Baik'),
                InfoRange('51-100', 'Sedang'),
                InfoRange('101-150', 'Tidak sehat bagi kelompok sensitif'),
                InfoRange('151-200', 'Tidak sehat'),
                InfoRange('201-300', 'Sangat tidak sehat'),
                InfoRange('301+', 'Berbahaya'),
              ],
              activeRange: _aqiRangeIndex(weather.aqi),
            ),
          ),
          _StatCard(
            label: 'UV',
            value: weather.uv?.toStringAsFixed(1) ?? '-',
            status: _uvStatus(weather.uv),
            icon: Icons.wb_sunny_outlined,
            accent: EnvStatsColors.getUvAccent(weather.uv),
            compact: compactDashboard,
            comfortable: comfortableDashboard,
            minimal: minimalDashboard,
            height: cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Indeks UV',
              currentValue: weather.uv == null
                  ? 'Belum tersedia'
                  : weather.uv!.toStringAsFixed(1),
              currentStatus: _uvStatus(weather.uv),
              definition:
                  'Indeks UV menunjukkan intensitas radiasi ultraviolet matahari yang dapat mengenai kulit dan mata.',
              impact:
                  'Paparan tinggi meningkatkan risiko kulit terbakar dan kerusakan mata. Dampak dapat terjadi lebih cepat saat matahari terik.',
              guidance: _uvGuidance(weather.uv),
              icon: Icons.wb_sunny_outlined,
              accent: EnvStatsColors.getUvAccent(weather.uv),
              ranges: const [
                InfoRange('0-2', 'Rendah'),
                InfoRange('3-5', 'Sedang'),
                InfoRange('6-7', 'Tinggi'),
                InfoRange('8-10', 'Sangat tinggi'),
                InfoRange('11+', 'Ekstrem'),
              ],
              activeRange: _uvRangeIndex(weather.uv),
            ),
          ),
          _StatCard(
            label: 'Suhu',
            value: weather.temp == null
                ? '-'
                : '${weather.temp!.toStringAsFixed(1)}°C',
            status: _temperatureCardStatus(weather),
            icon: Icons.thermostat_outlined,
            accent: EnvStatsColors.getTempAccent(
              weather.heatIndex ?? weather.temp,
            ),
            compact: compactDashboard,
            comfortable: comfortableDashboard,
            minimal: minimalDashboard,
            height: cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Suhu udara',
              currentValue: _temperatureDialogValue(weather),
              currentStatus: _temperatureStatus(
                weather.heatIndex ?? weather.temp,
              ),
              definition:
                  'Suhu menunjukkan panas atau dingin udara. Jika kelembapan tersedia, risiko panas memakai indeks panas atau suhu yang terasa oleh tubuh.',
              impact:
                  'Suhu tinggi dapat memicu dehidrasi dan kelelahan panas. Suhu rendah dapat menyebabkan tubuh kehilangan panas lebih cepat.',
              guidance: _temperatureGuidance(weather.temp, weather.heatIndex),
              icon: Icons.thermostat_outlined,
              accent: EnvStatsColors.getTempAccent(
                weather.heatIndex ?? weather.temp,
              ),
              ranges: const [
                InfoRange('<10°C', 'Dingin'),
                InfoRange('10-20°C', 'Sejuk'),
                InfoRange('21-30°C', 'Hangat'),
                InfoRange('31-35°C', 'Panas'),
                InfoRange('>35°C', 'Sangat panas'),
              ],
              activeRange: _temperatureRangeIndex(
                weather.heatIndex ?? weather.temp,
              ),
            ),
          ),
        ];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1)
                SizedBox(
                  width: minimalDashboard
                      ? 10
                      : compactDashboard
                      ? 6
                      : 12,
                ),
            ],
          ],
        );
      },
    );
  }

  static String _aqiCardStatus(int? value) {
    if (value == null) return 'Belum tersedia';
    if (value <= 50) return 'Baik';
    if (value <= 100) return 'Sedang';
    if (value <= 150) return 'Sensitif';
    if (value <= 200) return 'Tidak sehat';
    if (value <= 300) return 'Sangat buruk';
    return 'Berbahaya';
  }

  static String _aqiStatus(int? value) {
    if (value == null) return 'Data belum tersedia';
    if (value <= 50) return 'Baik';
    if (value <= 100) return 'Sedang';
    if (value <= 150) return 'Tidak sehat bagi kelompok sensitif';
    if (value <= 200) return 'Tidak sehat';
    if (value <= 300) return 'Sangat tidak sehat';
    return 'Berbahaya';
  }

  static String _uvStatus(double? value) {
    if (value == null) return 'Belum tersedia';
    if (value <= 2) return 'Rendah';
    if (value <= 5) return 'Sedang';
    if (value <= 7) return 'Tinggi';
    if (value <= 10) return 'Sangat tinggi';
    return 'Ekstrem';
  }

  static String _temperatureStatus(double? value) {
    if (value == null) return 'Belum tersedia';
    if (value < 10) return 'Dingin';
    if (value <= 20) return 'Sejuk';
    if (value <= 30) return 'Hangat';
    if (value <= 35) return 'Panas';
    return 'Sangat panas';
  }

  static String _temperatureCardStatus(Weather weather) {
    final actual = _temperatureStatus(weather.temp);
    final heatIndex = weather.heatIndex;
    if (weather.temp == null ||
        heatIndex == null ||
        heatIndex < weather.temp! + 1) {
      return actual;
    }
    return 'Terasa ${_temperatureStatus(heatIndex).toLowerCase()}';
  }

  static String _temperatureDialogValue(Weather weather) {
    if (weather.temp == null) return 'Belum tersedia';
    final actual = '${weather.temp!.toStringAsFixed(1)}°C';
    final heatIndex = weather.heatIndex;
    if (heatIndex == null) return actual;
    return '$actual · terasa ${heatIndex.toStringAsFixed(1)}°C';
  }

  static int _aqiRangeIndex(int? value) {
    if (value == null) return -1;
    if (value <= 50) return 0;
    if (value <= 100) return 1;
    if (value <= 150) return 2;
    if (value <= 200) return 3;
    if (value <= 300) return 4;
    return 5;
  }

  static int _uvRangeIndex(double? value) {
    if (value == null) return -1;
    if (value <= 2) return 0;
    if (value <= 5) return 1;
    if (value <= 7) return 2;
    if (value <= 10) return 3;
    return 4;
  }

  static int _temperatureRangeIndex(double? value) {
    if (value == null) return -1;
    if (value < 10) return 0;
    if (value <= 20) return 1;
    if (value <= 30) return 2;
    if (value <= 35) return 3;
    return 4;
  }

  static String _aqiGuidance(int? value) {
    if (value == null) return 'Perbarui data sebelum merencanakan aktivitas.';
    if (value <= 50) return 'Aktivitas luar dapat dilakukan seperti biasa.';
    if (value <= 100) {
      return 'Pantau gejala dan kurangi aktivitas berat bila terasa tidak nyaman.';
    }
    if (value <= 150) {
      return 'Kelompok sensitif sebaiknya mengurangi aktivitas berat di luar.';
    }
    return 'Batasi aktivitas luar dan gunakan masker yang sesuai.';
  }

  static String _uvGuidance(double? value) {
    if (value == null) return 'Perbarui data sebelum beraktivitas di luar.';
    if (value <= 2) {
      return 'Gunakan jaket atau pakaian lengan panjang. Pakai tabir surya jika berkendara lama.';
    }
    if (value <= 5) {
      return 'Gunakan jaket lengan panjang dan tabir surya. Istirahat di tempat teduh saat menunggu order.';
    }
    if (value <= 7) {
      return 'Gunakan jaket lengan panjang dan tabir surya. Kurangi waktu di bawah matahari langsung.';
    }
    return 'Cari tempat teduh saat menunggu order. Gunakan jaket lengan panjang dan tabir surya.';
  }

  static String _temperatureGuidance(double? temperature, double? heatIndex) {
    if (temperature == null) {
      return 'Perbarui data sebelum beraktivitas di luar.';
    }
    if (temperature < 10) {
      return 'Gunakan pakaian hangat dan batasi paparan lama.';
    }
    final perceivedHeat = heatIndex ?? temperature;
    if (perceivedHeat <= 30) return 'Sesuaikan pakaian dan tetap cukup minum.';
    if (perceivedHeat <= 35) return 'Minum cukup dan beristirahat dari panas.';
    return 'Cari tempat teduh dan kurangi aktivitas fisik berat.';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final IconData icon;
  final Color accent;
  final bool compact;
  final bool comfortable;
  final bool minimal;
  final double? height;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.status,
    required this.icon,
    required this.accent,
    this.compact = false,
    this.comfortable = false,
    this.minimal = false,
    this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 16 : 20);
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: minimal
            ? BorderSide(color: accent.withValues(alpha: .36))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          height: height ?? (compact ? 108 : 126),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? (comfortable ? 6 : 4) : 10,
              compact ? (comfortable ? 9 : 7) : 10,
              compact ? (comfortable ? 6 : 4) : 10,
              compact ? (comfortable ? 8 : 6) : 9,
            ),
            child: minimal
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: accent, size: comfortable ? 27 : 24),
                      SizedBox(height: comfortable ? 9 : 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: comfortable ? 31 : 27,
                            height: .95,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: comfortable ? 5 : 3),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: comfortable ? 12 : 11,
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: accent,
                        size: compact
                            ? comfortable
                                  ? 27
                                  : 22
                            : 29,
                      ),
                      SizedBox(height: compact ? (comfortable ? 5 : 3) : 5),
                      Container(
                        constraints: BoxConstraints(
                          minWidth: compact ? 0 : 90,
                          maxWidth: compact ? 90 : 150,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? (comfortable ? 8 : 6) : 9,
                          vertical: compact ? (comfortable ? 4 : 3) : 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          status,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: compact
                                ? comfortable
                                      ? 11
                                      : 10
                                : 12,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? (comfortable ? 5 : 3) : 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: compact
                                ? comfortable
                                      ? 30
                                      : 25
                                : 31,
                            height: .98,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 1 : 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: compact
                              ? comfortable
                                    ? 12
                                    : 11
                              : 14,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
