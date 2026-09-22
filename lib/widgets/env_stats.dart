import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/colors_theme.dart';
import '../models/weather.dart';
import 'window_dialog.dart';

class EnvStats extends StatefulWidget {
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
  State<EnvStats> createState() => _EnvStatsState();
}

class _EnvStatsState extends State<EnvStats> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Weather get weather => widget.weather;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            accent: EnvStatsColors.getAqiAccent(context, weather.aqi),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
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
              accent: EnvStatsColors.getAqiAccent(context, weather.aqi),
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
            accent: EnvStatsColors.getUvAccent(context, weather.uv),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
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
              accent: EnvStatsColors.getUvAccent(context, weather.uv),
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
              context,
              weather.heatIndex ?? weather.temp,
            ),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
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
                context,
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

        final secondaryCards = [
          _StatCard(
            label: 'Cuaca',
            value: _conditionLabel(widget.weather),
            status: _conditionStatus(widget.weather),
            icon: _conditionIcon(widget.weather),
            accent: _conditionAccent(context, widget.weather),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Kondisi cuaca',
              currentValue: _conditionLabel(widget.weather),
              currentStatus: _conditionStatus(widget.weather),
              definition:
                  'Kondisi cuaca menunjukkan keadaan atmosfer saat ini, seperti cerah, berawan, hujan, atau badai.',
              impact:
                  'Hujan, kabut, dan badai dapat mengurangi jarak pandang serta meningkatkan risiko saat berkendara.',
              guidance: _conditionGuidance(widget.weather),
              icon: _conditionIcon(widget.weather),
              accent: _conditionAccent(context, widget.weather),
              ranges: const [
                InfoRange('Normal', 'Cerah, berawan, atau berkabut ringan'),
                InfoRange('Waspada', 'Hujan, salju, asap, atau kabut tebal'),
                InfoRange('Bahaya', 'Petir atau cuaca ekstrem'),
              ],
              activeRange: _conditionRangeIndex(widget.weather),
            ),
          ),
          _StatCard(
            label: 'Kelembapan',
            value: _humidityValue(widget.weather.humidity),
            status: _humidityStatus(widget.weather.humidity),
            icon: Icons.water_drop_outlined,
            accent: _humidityAccent(context, widget.weather.humidity),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Kelembapan udara',
              currentValue: _humidityValue(
                widget.weather.humidity,
                unavailable: 'Belum tersedia',
              ),
              currentStatus: _humidityStatus(widget.weather.humidity),
              definition:
                  'Kelembapan menunjukkan banyaknya uap air di udara dibandingkan kapasitas maksimum udara pada suhu saat ini.',
              impact:
                  'Udara lembap dapat membuat panas terasa lebih berat. Udara terlalu kering dapat memicu rasa tidak nyaman.',
              guidance: _humidityGuidance(widget.weather.humidity),
              icon: Icons.water_drop_outlined,
              accent: _humidityAccent(context, widget.weather.humidity),
              ranges: const [
                InfoRange('<40%', 'Kering'),
                InfoRange('40-70%', 'Nyaman'),
                InfoRange('>70%', 'Lembap'),
              ],
              activeRange: _humidityRangeIndex(widget.weather.humidity),
            ),
          ),
        ];

        if (!widget.minimalDashboard) {
          return _CardRow(
            cards: [...cards, ...secondaryCards],
            compact: widget.compactDashboard,
          );
        }

        return Column(
          children: [
            SizedBox(
              height: widget.cardHeight,
              child: PageView(
                key: const Key('environment-stats-pager'),
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _CardRow(cards: cards, compact: true, minimal: true),
                  _CardRow(cards: secondaryCards, compact: true, minimal: true),
                ],
              ),
            ),
            const SizedBox(height: 7),
            _PageIndicator(
              currentPage: _currentPage,
              onSelect: (page) => _pageController.animateToPage(
                page,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
              ),
            ),
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

  static String _conditionLabel(Weather weather) {
    final condition = weather.condition?.trim();
    if (condition == null ||
        condition.isEmpty ||
        condition.toLowerCase() == 'not specified') {
      return '-';
    }

    final text = condition.toLowerCase();
    if (RegExp(r'thunder|lightning').hasMatch(text)) return 'Badai petir';
    if (text.contains('blizzard')) return 'Badai salju';
    if (RegExp(r'snow|salju').hasMatch(text)) return 'Salju';
    if (RegExp(r'sleet|ice pellets').hasMatch(text)) return 'Hujan es';
    if (RegExp(r'drizzle|gerimis').hasMatch(text)) return 'Gerimis';
    if (RegExp(r'rain|hujan').hasMatch(text)) return 'Hujan';
    if (RegExp(r'smoke|smoky|haze|asap').hasMatch(text)) return 'Berasap';
    if (RegExp(r'fog|mist|kabut').hasMatch(text)) return 'Berkabut';
    if (RegExp(r'overcast').hasMatch(text)) return 'Mendung';
    if (RegExp(r'cloud|berawan').hasMatch(text)) return 'Berawan';
    if (RegExp(r'clear|sunny|cerah').hasMatch(text)) return 'Cerah';
    return condition;
  }

  static String _conditionStatus(Weather weather) {
    final severity = weather.componentSeverity['Cuaca'];
    if (severity == null) return 'Belum tersedia';
    if (severity >= .75) return 'Bahaya';
    if (severity >= .5) return 'Waspada';
    return 'Normal';
  }

  static int _conditionRangeIndex(Weather weather) {
    final severity = weather.componentSeverity['Cuaca'];
    if (severity == null) return -1;
    if (severity >= .75) return 2;
    if (severity >= .5) return 1;
    return 0;
  }

  static IconData _conditionIcon(Weather weather) {
    final label = _conditionLabel(weather);
    if (label == 'Cerah') return Icons.wb_sunny_outlined;
    if (label == 'Berawan' || label == 'Mendung') return Icons.cloud_outlined;
    if (label == 'Badai petir') return Icons.thunderstorm_outlined;
    if (label == 'Berkabut' || label == 'Berasap') return Icons.foggy;
    if (label == 'Salju') return Icons.ac_unit;
    if (label == '-') return Icons.cloud_off_outlined;
    return Icons.umbrella_outlined;
  }

  static Color _conditionAccent(BuildContext context, Weather weather) {
    final severity = weather.componentSeverity['Cuaca'];
    if (severity == null) return context.appColors.muted;
    if (severity >= .75) return context.appColors.coral;
    if (severity >= .5) return context.appColors.orange;
    return context.appColors.green;
  }

  static String _conditionGuidance(Weather weather) {
    final severity = weather.componentSeverity['Cuaca'];
    if (severity == null) return 'Perbarui data sebelum beraktivitas di luar.';
    if (severity >= .75) return 'Tunda perjalanan dan berlindung di dalam.';
    if (severity >= .5) {
      return 'Kurangi kecepatan dan tingkatkan kewaspadaan saat berkendara.';
    }
    return 'Aktivitas luar dapat dilakukan seperti biasa.';
  }

  static String _humidityStatus(double? humidity) {
    if (humidity == null || humidity < 0 || humidity > 100) {
      return 'Belum tersedia';
    }
    if (humidity < 40) return 'Kering';
    if (humidity <= 70) return 'Nyaman';
    return 'Lembap';
  }

  static String _humidityValue(double? humidity, {String unavailable = '-'}) {
    if (humidity == null || humidity < 0 || humidity > 100) {
      return unavailable;
    }
    return '${humidity.round()}%';
  }

  static int _humidityRangeIndex(double? humidity) {
    if (humidity == null || humidity < 0 || humidity > 100) return -1;
    if (humidity < 40) return 0;
    if (humidity <= 70) return 1;
    return 2;
  }

  static Color _humidityAccent(BuildContext context, double? humidity) {
    final range = _humidityRangeIndex(humidity);
    if (range == -1) return context.appColors.muted;
    if (range == 1) return context.appColors.green;
    return context.appColors.orange;
  }

  static String _humidityGuidance(double? humidity) {
    final range = _humidityRangeIndex(humidity);
    if (range == -1) return 'Perbarui data sebelum beraktivitas di luar.';
    if (range == 0) return 'Minum cukup dan lindungi kulit dari udara kering.';
    if (range == 2) {
      return 'Minum cukup dan beristirahat bila panas terasa berat.';
    }
    return 'Kelembapan berada dalam rentang nyaman.';
  }
}

class _CardRow extends StatelessWidget {
  final List<Widget> cards;
  final bool compact;
  final bool minimal;

  const _CardRow({
    required this.cards,
    this.compact = false,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1)
            SizedBox(
              width: minimal
                  ? 10
                  : compact
                  ? 6
                  : 12,
            ),
        ],
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onSelect;

  const _PageIndicator({required this.currentPage, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Halaman metrik ${currentPage + 1} dari 2',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var page = 0; page < 2; page++)
            InkResponse(
              key: Key('environment-stats-page-$page'),
              onTap: () => onSelect(page),
              radius: 14,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: page == currentPage ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: page == currentPage
                        ? context.appColors.forest
                        : context.appColors.muted.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
      color: context.appColors.card,
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
                            color: context.appColors.ink,
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
                          color: context.appColors.muted,
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
                            color: context.appColors.ink,
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
                          color: context.appColors.muted,
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
