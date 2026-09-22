import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lingkungan_sehat/config/app_theme.dart';
import 'package:lingkungan_sehat/config/env.dart';
import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/screens/information.dart';
import 'package:lingkungan_sehat/screens/settings.dart';
import 'package:lingkungan_sehat/services/environment.dart';
import 'package:lingkungan_sehat/widgets/brand_mark.dart';
import 'package:lingkungan_sehat/widgets/env_stats.dart';
import 'package:lingkungan_sehat/widgets/location_bar.dart';
import 'package:lingkungan_sehat/widgets/recommendation_list.dart';
import 'package:lingkungan_sehat/widgets/risk_meter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  EnvData envData = EnvData.preview;
  Timer? _refreshTimer;
  bool loading = false;
  bool locationAvailable = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    if (Env.openWeatherKey.trim().isNotEmpty) {
      loading = true;
      initializeEnvironment(showLoading: false);
      _refreshTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => initializeEnvironment(showLoading: false),
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> initializeEnvironment({
    String? query,
    bool showLoading = true,
  }) async {
    if (Env.openWeatherKey.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        envData = EnvData.preview;
        loading = false;
        locationAvailable = true;
        errorMessage = null;
      });
      return;
    }

    if (showLoading && mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    final freshData = await loadEnvironment(query: query);
    if (!mounted) return;

    if (freshData.status == 'Success') {
      setState(() {
        envData = freshData;
        loading = false;
        locationAvailable = true;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      loading = false;
      locationAvailable = false;
      errorMessage = _errorMessageFor(freshData.status);
    });
  }

  String _errorMessageFor(String status) {
    switch (status) {
      case 'Location unavailable':
        return 'Lokasi tidak tersedia. Periksa izin lokasi lalu coba lagi.';
      case 'Failed to Connect':
        return 'Koneksi gagal. Periksa internet lalu coba lagi.';
      default:
        return 'Data lingkungan belum tersedia. Coba lagi.';
    }
  }

  void _openLocationSearch() {
    showInputPrompt(context, (value) {
      if (value.trim().isNotEmpty) {
        initializeEnvironment(query: value.trim());
      }
    });
  }

  void _openInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InformationScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _share() async {
    await Share.share(
      'Cek kondisi lingkungan sekitar di LingkunganSehat.\nhttps://app.lingkungansehat.my.id',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.page, Color(0xFFEEFCF6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.green,
            backgroundColor: AppColors.card,
            onRefresh: () => initializeEnvironment(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 1200
                    ? (constraints.maxWidth - 1120) / 2
                    : constraints.maxWidth >= 760
                    ? 44.0
                    : constraints.maxWidth >= 520
                    ? 28.0
                    : 18.0;
                final narrow = constraints.maxWidth < 520;

                if (loading && envData.status != 'Preview') {
                  return _LoadingView(horizontalPadding: horizontalPadding);
                }

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    16,
                  ),
                  children: [
                    _PageHeader(
                      compact: constraints.maxWidth < 760,
                      narrow: narrow,
                      stacked: constraints.maxWidth < 380,
                      onShare: _share,
                      onInformation: _openInformation,
                      onSettings: _openSettings,
                    ),
                    SizedBox(height: narrow ? 18 : 29),
                    LocationBar(
                      available: locationAvailable,
                      location: envData.location,
                      updatedAt: envData.localTime,
                      loading: loading,
                      onRetry: () => initializeEnvironment(),
                      onTap: _openLocationSearch,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      _InlineError(
                        message: errorMessage!,
                        onRetry: () => initializeEnvironment(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _RiskPanel(
                      weather: envData.weather,
                      maxWidth: constraints.maxWidth - (horizontalPadding * 2),
                    ),
                    const SizedBox(height: 31),
                    _SectionHeading(
                      title: 'Kondisi Lingkungan Saat Ini',
                      actionLabel: 'Lihat detail',
                      onAction: _openInformation,
                    ),
                    const SizedBox(height: 14),
                    EnvStats(weather: envData.weather),
                    const SizedBox(height: 28),
                    RecommendationSection(weather: envData.weather),
                    const SizedBox(height: 2),
                    const _ReassuranceBanner(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final bool compact;
  final bool narrow;
  final bool stacked;
  final VoidCallback onShare;
  final VoidCallback onInformation;
  final VoidCallback onSettings;

  const _PageHeader({
    required this.compact,
    required this.narrow,
    required this.stacked,
    required this.onShare,
    required this.onInformation,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final markSize = narrow
        ? 46.0
        : compact
        ? 58.0
        : 82.0;
    final titleSize = narrow
        ? 18.0
        : compact
        ? 22.0
        : 36.0;
    final subtitleSize = narrow
        ? 11.0
        : compact
        ? 13.0
        : 20.0;
    final buttonSize = narrow
        ? 44.0
        : compact
        ? 50.0
        : 70.0;
    final iconSize = narrow
        ? 21.0
        : compact
        ? 24.0
        : 32.0;
    final actionGap = narrow
        ? 5.0
        : compact
        ? 7.0
        : 19.0;

    final brand = Row(
      children: [
        BrandMark(size: markSize),
        SizedBox(width: narrow ? 8 : 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LingkunganSehat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.forest,
                  fontSize: titleSize,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: narrow ? 4 : 6),
              Text(
                narrow
                    ? 'Lingkungan lebih sehat'
                    : 'Lingkungan lebih sehat, hidup lebih baik',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: subtitleSize,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderAction(
          tooltip: 'Bagikan',
          icon: Icons.share_outlined,
          size: buttonSize,
          iconSize: iconSize,
          onPressed: onShare,
        ),
        SizedBox(width: actionGap),
        _HeaderAction(
          tooltip: 'Informasi',
          icon: Icons.info_outline,
          size: buttonSize,
          iconSize: iconSize,
          onPressed: onInformation,
        ),
        SizedBox(width: actionGap),
        _HeaderAction(
          tooltip: 'Pengaturan',
          icon: Icons.settings_outlined,
          size: buttonSize,
          iconSize: iconSize,
          onPressed: onSettings,
        ),
      ],
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          brand,
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: brand),
        SizedBox(width: narrow ? 8 : 12),
        actions,
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.card,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: AppColors.forest, size: iconSize),
          ),
        ),
      ),
    );
  }
}

class _RiskPanel extends StatelessWidget {
  final Weather weather;
  final double maxWidth;

  const _RiskPanel({required this.weather, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final narrow = maxWidth < 520;
    final panelHeight = narrow
        ? (maxWidth * .88).clamp(328.0, 350.0).toDouble()
        : (maxWidth * .465).clamp(370.0, 408.0).toDouble();
    final meterSize = narrow
        ? (maxWidth * .5).clamp(188.0, 210.0).toDouble()
        : (maxWidth * .32).clamp(215.0, 285.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: Container(
        height: panelHeight,
        color: AppColors.card,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/illustrations/risk-landscape.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: narrow ? 13 : 18),
                child: RiskMeter(weather: weather, size: meterSize),
              ),
            ),
            Positioned(
              left: narrow ? 16 : 26,
              right: narrow ? 16 : 26,
              bottom: narrow ? 17 : 24,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 570),
                  child: Text(
                    _riskDescription(weather),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: narrow ? 17.5 : 23,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _riskDescription(Weather weather) {
    switch (weather.getRiskLevel) {
      case 'Rendah':
        return 'Kondisi cukup baik, tetap perhatikan perubahan cuaca.';
      case 'Tinggi':
        return 'Batasi aktivitas luar dan lindungi diri dari paparan berlebih.';
      default:
        return 'Kondisi cukup aman, tetap batasi\npaparan panas dan UV.';
    }
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.forest,
                  fontSize: 26,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forest,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const SizedBox.shrink(),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.chevron_right, size: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.forest,
                  fontSize: 31,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.forest,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 40),
              ),
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 29),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.coralSoft,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.coral),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final double horizontalPadding;

  const _LoadingView({required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        24,
      ),
      children: [
        Row(
          children: [
            const _Skeleton(width: 67, height: 67, circle: true),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Skeleton(width: 210, height: 25),
                  SizedBox(height: 8),
                  _Skeleton(width: 250, height: 16),
                ],
              ),
            ),
            const SizedBox(width: 15),
            _Skeleton(
              width: horizontalPadding < 28 ? 50 : 70,
              height: horizontalPadding < 28 ? 50 : 70,
              circle: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _Skeleton(width: double.infinity, height: 106),
        const SizedBox(height: 16),
        const _Skeleton(width: double.infinity, height: 390),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final bool circle;

  const _Skeleton({
    required this.width,
    required this.height,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(circle ? height / 2 : 25),
      ),
    );
  }
}

class _ReassuranceBanner extends StatelessWidget {
  const _ReassuranceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.greenBorder),
      ),
      child: Row(
        children: [
          const BrandMark(size: 39),
          const SizedBox(width: 21),
          const Expanded(
            child: Text(
              'Lingkungan sehat dimulai dari kesadaran kita',
              style: TextStyle(
                color: AppColors.forest,
                fontSize: 18,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.green, size: 29),
        ],
      ),
    );
  }
}
