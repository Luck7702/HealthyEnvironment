import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/colors_theme.dart';
import '../config/sources.dart';
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
            accent: EnvStatsColors.forSeverity(
              context,
              weather.componentSeverity['AQI'],
            ),
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
                  'AQI memperkirakan kualitas udara dari konsentrasi PM2.5 dan PM10 saat ini, memakai skala US EPA. Nilai ini perkiraan sesaat, bukan AQI harian atau ISPU resmi.',
              impact:
                  'Nilai tinggi dapat mengiritasi mata dan saluran napas. Anak, lansia, dan orang dengan gangguan pernapasan lebih rentan.',
              guidance: _aqiGuidance(weather.aqi),
              icon: Icons.cloud_outlined,
              accent: EnvStatsColors.forSeverity(
              context,
              weather.componentSeverity['AQI'],
            ),
              ranges: const [
                InfoRange('0-50', 'Baik · risiko Rendah'),
                InfoRange('51-100', 'Sedang · risiko Sedang'),
                InfoRange(
                  '101-150',
                  'Tidak sehat bagi kelompok sensitif · risiko Sedang',
                ),
                InfoRange('151-200', 'Tidak sehat · risiko Tinggi'),
                InfoRange('201-300', 'Sangat tidak sehat · risiko Tinggi'),
                InfoRange('301+', 'Berbahaya · risiko Tinggi'),
              ],
              activeRange: _aqiRangeIndex(weather.aqi),
              sources: const [Sources.epaAqi, Sources.weatherApi],
            ),
          ),
          _StatCard(
            label: 'UV',
            value: weather.uv?.toStringAsFixed(1) ?? '-',
            status: _uvStatus(weather.uv),
            icon: Icons.wb_sunny_outlined,
            accent: EnvStatsColors.forSeverity(
              context,
              weather.componentSeverity['UV'],
            ),
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
                  'Indeks UV menunjukkan intensitas radiasi ultraviolet matahari yang dapat mengenai kulit dan mata. Nama kategori mengikuti skala WHO; tingkat risiko mengikuti tiga tingkat tindakan WHO (0–2, 3–7, 8+).',
              impact:
                  'Paparan tinggi meningkatkan risiko kulit terbakar dan kerusakan mata. Dampak dapat terjadi lebih cepat saat matahari terik.',
              guidance: _uvGuidance(weather.uv),
              icon: Icons.wb_sunny_outlined,
              accent: EnvStatsColors.forSeverity(
              context,
              weather.componentSeverity['UV'],
            ),
              ranges: const [
                InfoRange('0-2', 'Rendah · risiko Rendah'),
                InfoRange('3-5', 'Sedang · risiko Sedang'),
                InfoRange('6-7', 'Tinggi · risiko Sedang'),
                InfoRange('8-10', 'Sangat tinggi · risiko Tinggi'),
                InfoRange('11+', 'Ekstrem · risiko Tinggi'),
              ],
              activeRange: _uvRangeIndex(weather.uv),
              sources: const [Sources.whoUv, Sources.icnirpUv],
            ),
          ),
          _StatCard(
            label: 'Suhu',
            value: weather.temp == null
                ? '-'
                : '${weather.temp!.toStringAsFixed(1)}°C',
            status: _heatLabel(weather.heatRiskCategory),
            icon: Icons.thermostat_outlined,
            accent: EnvStatsColors.forSeverity(context, weather.heatSeverity),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Suhu & indeks panas',
              currentValue: _temperatureDialogValue(weather),
              currentStatus: _heatDialogStatus(weather),
              definition:
                  'Indeks panas menggabungkan suhu dan kelembapan untuk memperkirakan panas yang terasa oleh tubuh di tempat teduh. Di bawah terik matahari nilainya bisa naik hingga 8°C, jadi saat siang cerah risiko dinaikkan satu tingkat.',
              impact:
                  'Paparan lama atau aktivitas fisik saat indeks panas tinggi dapat menyebabkan kelelahan, kram panas, kelelahan panas (heat exhaustion), hingga sengatan panas (heat stroke).',
              guidance: _heatGuidance(weather.heatRiskCategory),
              icon: Icons.thermostat_outlined,
              accent: EnvStatsColors.forSeverity(context, weather.heatSeverity),
              ranges: const [
                InfoRange('<26,7°C', 'Normal · risiko Rendah'),
                InfoRange(
                  '26,7–32,2°C',
                  'Hati-hati · Rendah (Sedang di bawah terik)',
                ),
                InfoRange(
                  '32,2–39,4°C',
                  'Ekstra hati-hati · Sedang (Tinggi di bawah terik)',
                ),
                InfoRange('39,4–51,7°C', 'Bahaya · Tinggi'),
                InfoRange('≥51,7°C', 'Bahaya ekstrem · Tinggi'),
              ],
              activeRange: weather.heatCategory ?? -1,
              sources: const [Sources.nwsHeatIndex, Sources.oshaHeatIndex],
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
                InfoRange('Normal', 'Cerah, berawan, atau kabut tipis (mist)'),
                InfoRange('Waspada', 'Hujan, salju, asap, atau kabut (fog)'),
                InfoRange('Bahaya', 'Petir atau cuaca ekstrem'),
              ],
              activeRange: _conditionRangeIndex(widget.weather),
              sources: const [Sources.nwsLightning, Sources.weatherApi],
            ),
          ),
          _StatCard(
            label: 'Kelembapan',
            value: _humidityValue(widget.weather.humidity),
            status: _comfortLabel(widget.weather.dewPointComfort),
            icon: Icons.water_drop_outlined,
            accent: _humidityAccent(context, widget.weather),
            compact: widget.compactDashboard,
            comfortable: widget.comfortableDashboard,
            minimal: widget.minimalDashboard,
            height: widget.cardHeight,
            onTap: () => InfoDialog.showMetric(
              context,
              title: 'Kelembapan udara',
              currentValue: _humidityDialogValue(widget.weather),
              currentStatus: _comfortLabel(widget.weather.dewPointComfort),
              definition:
                  'Kelembapan relatif menunjukkan banyaknya uap air di udara. Rasa gerah lebih tepat diukur dengan titik embun, yaitu suhu saat udara jenuh uap air. Kategori di bawah memakai titik embun.',
              impact:
                  'Udara lembap membuat keringat sulit menguap, sehingga panas terasa lebih berat. Pengaruh ini sudah dihitung dalam indeks panas, jadi kelembapan hanya informasi dan tidak dinilai sebagai risiko tersendiri.',
              guidance: _humidityGuidance(widget.weather.dewPointComfort),
              icon: Icons.water_drop_outlined,
              accent: _humidityAccent(context, widget.weather),
              ranges: const [
                InfoRange('≤12,8°C', 'Kering dan nyaman'),
                InfoRange('12,8–18,3°C', 'Lengket'),
                InfoRange('≥18,3°C', 'Gerah'),
              ],
              activeRange: widget.weather.dewPointComfort ?? -1,
              sources: const [Sources.nwsDewPoint],
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

  /// Indonesian names for the NWS heat index classifications.
  static String _heatLabel(int? category) => switch (category) {
    null => 'Belum tersedia',
    0 => 'Normal',
    1 => 'Hati-hati',
    2 => 'Ekstra hati-hati',
    3 => 'Bahaya',
    _ => 'Bahaya ekstrem',
  };

  static String _heatDialogStatus(Weather weather) {
    final shade = _heatLabel(weather.heatCategory);
    if (weather.heatCategory == null ||
        weather.heatRiskCategory == weather.heatCategory) {
      return shade;
    }
    final sun = _heatLabel(weather.heatRiskCategory).toLowerCase();
    return '$shade · $sun di bawah terik';
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

  static String _heatGuidance(int? category) => switch (category) {
    null => 'Perbarui data sebelum beraktivitas di luar.',
    0 => 'Tetap minum air secara teratur.',
    1 => 'Minum air secara teratur dan kenali tanda kelelahan panas.',
    2 => 'Minum cukup dan istirahat di tempat teduh secara berkala.',
    _ => 'Cari tempat teduh, minum cukup, dan kurangi aktivitas berat.',
  };

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
    if (RegExp(r'fog|kabut').hasMatch(text)) return 'Berkabut';
    if (text.contains('mist')) return 'Kabut tipis';
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
    if (label == 'Berkabut' || label == 'Kabut tipis' || label == 'Berasap') {
      return Icons.foggy;
    }
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

  /// NWS dew point comfort level names.
  static String _comfortLabel(int? comfort) => switch (comfort) {
    null => 'Belum tersedia',
    0 => 'Nyaman',
    1 => 'Lengket',
    _ => 'Gerah',
  };

  static String _humidityValue(double? humidity, {String unavailable = '-'}) {
    if (humidity == null || humidity < 0 || humidity > 100) {
      return unavailable;
    }
    return '${humidity.round()}%';
  }

  static String _humidityDialogValue(Weather weather) {
    final value = _humidityValue(weather.humidity, unavailable: 'Belum tersedia');
    final dewPoint = weather.dewPoint;
    if (dewPoint == null) return value;
    return '$value · titik embun ${dewPoint.toStringAsFixed(1)}°C';
  }

  /// Humidity is information only, so it uses a neutral colour.
  static Color _humidityAccent(BuildContext context, Weather weather) =>
      weather.dewPointComfort == null
      ? context.appColors.muted
      : context.appColors.blue;

  static String _humidityGuidance(int? comfort) => switch (comfort) {
    null => 'Perbarui data sebelum beraktivitas di luar.',
    0 => 'Tidak perlu tindakan khusus untuk kelembapan.',
    _ => 'Minum air secara teratur; risiko panas dihitung lewat indeks panas.',
  };
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
    final radius = BorderRadius.circular(16);
    final tight = compact && (height ?? 108) < 96;
    return Material(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.appColors.line),
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
                      SizedBox(height: tight ? 5 : (comfortable ? 9 : 6)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: accent,
                            fontSize: tight ? 27 : (comfortable ? 30 : 28),
                            height: 1,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      SizedBox(height: comfortable ? 5 : 3),
                      Text(
                        label,
                        style: TextStyle(
                          color: context.appColors.muted,
                          fontSize: tight ? 11 : 12,
                          height: tight ? 1.2 : 1.33,
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
                            color: accent,
                            fontSize: compact
                                ? comfortable
                                      ? 30
                                      : 25
                                : 31,
                            height: .98,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
                              : 12,
                          height: 1.33,
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
