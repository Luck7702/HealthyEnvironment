import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/colors_theme.dart';
import '../models/weather.dart';
import 'window_dialog.dart';

class EnvStats extends StatelessWidget {
  final Weather weather;

  const EnvStats({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final compact = constraints.maxWidth < 680;
        final cards = [
          _StatCard(
            label: 'AQI',
            value: weather.aqi?.toString() ?? '—',
            status: _aqiStatus(weather.aqi),
            description: weather.aqi == null
                ? 'Data kualitas udara\nbelum tersedia.'
                : weather.aqi! >= 100
                ? 'Kualitas udara\nperlu diperhatikan.'
                : 'Kualitas udara\ntergolong baik.',
            icon: Icons.cloud,
            accent: EnvStatsColors.getAqiAccent(weather.aqi),
            dense: narrow,
            onTap: () => InfoDialog.show(
              context,
              title: 'Apa itu AQI?',
              message:
                  'AQI adalah perkiraan kualitas udara dari konsentrasi PM saat ini, bukan AQI harian resmi. Semakin tinggi angkanya, semakin besar perhatian yang dibutuhkan.',
              icon: Icons.cloud_outlined,
            ),
          ),
          _StatCard(
            label: 'UV',
            value: weather.uv?.toStringAsFixed(1) ?? '—',
            status: _uvStatus(weather.uv),
            description: weather.uv == null
                ? 'Data paparan UV\nbelum tersedia.'
                : weather.uv! >= 6
                ? 'Risiko paparan\nUV tinggi.'
                : 'Risiko paparan\nUV rendah.',
            icon: Icons.wb_sunny_outlined,
            accent: EnvStatsColors.getUvAccent(weather.uv),
            dense: narrow,
            onTap: () => InfoDialog.show(
              context,
              title: 'Apa itu UV?',
              message:
                  'UV Index menunjukkan intensitas radiasi ultraviolet dari matahari. Gunakan pelindung saat indeks UV tinggi.',
              icon: Icons.wb_sunny_outlined,
            ),
          ),
          _StatCard(
            label: 'Suhu',
            value: weather.temp == null
                ? '—'
                : '${weather.temp!.toStringAsFixed(1)}°C',
            status: _temperatureStatus(weather.temp),
            description: weather.temp == null
                ? 'Data suhu udara\nbelum tersedia.'
                : weather.temp! >= 30
                ? 'Cuaca panas,\njaga hidrasi.'
                : 'Suhu terasa\nnyaman.',
            icon: Icons.thermostat_outlined,
            accent: EnvStatsColors.getTempAccent(weather.temp),
            dense: narrow,
            onTap: () => InfoDialog.show(
              context,
              title: 'Suhu udara',
              message:
                  'Suhu membantu memperkirakan kebutuhan cairan, waktu istirahat, dan perlindungan saat beraktivitas di luar.',
              icon: Icons.thermostat_outlined,
            ),
          ),
        ];

        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                SizedBox(width: constraints.maxWidth, child: cards[i]),
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        if (compact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }

  static String _aqiStatus(int? value) {
    if (value == null) return 'Belum tersedia';
    if (value >= 150) return 'Tidak sehat';
    if (value >= 100) return 'Sedang';
    return 'Baik';
  }

  static String _uvStatus(double? value) {
    if (value == null) return 'Belum tersedia';
    if (value >= 8) return 'Sangat tinggi';
    if (value >= 6) return 'Tinggi';
    if (value >= 3) return 'Sedang';
    return 'Rendah';
  }

  static String _temperatureStatus(double? value) {
    if (value == null) return 'Belum tersedia';
    if (value >= 30) return 'Panas';
    if (value >= 24) return 'Hangat';
    return 'Sejuk';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final String description;
  final IconData icon;
  final Color accent;
  final bool dense;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.status,
    required this.description,
    required this.icon,
    required this.accent,
    this.dense = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: dense ? 264 : 356,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              dense ? 18 : 12,
              dense ? 18 : 25,
              dense ? 18 : 12,
              dense ? 17 : 21,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, color: accent, size: dense ? 48 : 59),
                SizedBox(height: dense ? 10 : 17),
                Container(
                  constraints: BoxConstraints(minWidth: dense ? 132 : 137),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: dense ? 16 : 18,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: dense ? 10 : 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: dense ? 42 : 48,
                      height: .98,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: dense ? 21 : 25,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: dense ? 16 : 18,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
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
