import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lingkungan_sehat/config/app_theme.dart';
import 'package:lingkungan_sehat/models/weather.dart';
import 'package:lingkungan_sehat/screens/information.dart';
import 'package:lingkungan_sehat/screens/settings.dart';
import 'package:lingkungan_sehat/services/environment.dart';
import 'package:lingkungan_sehat/services/location_preferences.dart';
import 'package:lingkungan_sehat/widgets/brand_mark.dart';
import 'package:lingkungan_sehat/widgets/env_stats.dart';
import 'package:lingkungan_sehat/widgets/location_bar.dart';
import 'package:lingkungan_sehat/widgets/recommendation_list.dart';
import 'package:lingkungan_sehat/widgets/risk_meter.dart';

class HomeScreen extends StatefulWidget {
  final EnvironmentLoader? environmentLoader;

  const HomeScreen({super.key, this.environmentLoader});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  EnvData envData = const EnvData(
    location: '',
    weather: Weather.emptyWeather,
    status: EnvironmentStatus.empty,
  );
  Timer? _refreshTimer;
  bool loading = true;
  bool refreshing = false;
  String? errorStatus;
  String? _activeQuery;
  String? _locationHint;
  int _environmentRequestId = 0;

  @override
  void initState() {
    super.initState();

    _activeQuery = readSavedLocation();
    initializeEnvironment(query: _activeQuery);
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => initializeEnvironment(showLoading: false),
    );
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
    final trimmedQuery = query?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      _activeQuery = trimmedQuery;
    }
    final effectiveQuery = _activeQuery;
    final requestId = ++_environmentRequestId;
    final hasData = envData.status == EnvironmentStatus.success;
    if (showLoading && !hasData && mounted) {
      setState(() {
        loading = true;
        refreshing = false;
        errorStatus = null;
      });
    } else if (mounted) {
      setState(() => refreshing = true);
    }

    late final EnvData freshData;
    try {
      freshData = await (widget.environmentLoader ?? loadEnvironment)(
        query: effectiveQuery,
      );
    } catch (_) {
      freshData = EnvData(
        location: effectiveQuery ?? '',
        weather: Weather.emptyWeather,
        status: EnvironmentStatus.networkError,
      );
    }
    if (!mounted || requestId != _environmentRequestId) return;

    if (freshData.status == EnvironmentStatus.success) {
      if (effectiveQuery != null && effectiveQuery.isNotEmpty) {
        saveLocation(effectiveQuery);
      }
      setState(() {
        envData = freshData;
        loading = false;
        refreshing = false;
        errorStatus = null;
        _locationHint = null;
      });
      return;
    }

    setState(() {
      loading = false;
      refreshing = false;
      errorStatus = freshData.status;
      _locationHint = freshData.location.trim().isNotEmpty
          ? freshData.location.trim()
          : effectiveQuery;
    });
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
      backgroundColor: context.appColors.page,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.appColors.page, context.appColors.pageEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final phone = constraints.maxWidth < 600;
              final compact = constraints.maxWidth < 900;
              final shortPhone = phone && constraints.maxHeight < 740;
              final tallPhone = phone && constraints.maxHeight >= 860;
              final horizontalPadding = constraints.maxWidth >= 1200
                  ? (constraints.maxWidth - 1120) / 2
                  : constraints.maxWidth >= 760
                  ? 44.0
                  : constraints.maxWidth >= 520
                  ? 28.0
                  : 16.0;
              final verticalPadding = phone
                  ? shortPhone
                        ? 6.0
                        : tallPhone
                        ? 12.0
                        : 8.0
                  : 12.0;
              final gap = phone
                  ? shortPhone
                        ? 8.0
                        : tallPhone
                        ? 12.0
                        : 12.0
                  : 10.0;
              final riskHeight = phone
                  ? shortPhone
                        ? 145.0
                        : tallPhone
                        ? 230.0
                        : 190.0
                  : constraints.maxHeight < 800
                  ? 195.0
                  : 235.0;
              final statsHeight = phone
                  ? shortPhone
                        ? 96.0
                        : tallPhone
                        ? 132.0
                        : 116.0
                  : constraints.maxHeight < 800
                  ? 110.0
                  : 126.0;

              final mobileRiskSize = shortPhone
                  ? 148.0
                  : tallPhone
                  ? 204.0
                  : 176.0;
              final mobileStatsHeight = shortPhone
                  ? 88.0
                  : tallPhone
                  ? 108.0
                  : 98.0;
              final hasData = envData.status == EnvironmentStatus.success;
              final failureMessage = errorStatus == null
                  ? null
                  : environmentErrorMessage(errorStatus!);
              final displayLocation = hasData
                  ? envData.location
                  : (_locationHint ?? '');
              final locationKnown = displayLocation.isNotEmpty;
              final retryable =
                  errorStatus == null ||
                  environmentErrorIsRetryable(errorStatus!);

              if (loading && envData.status != EnvironmentStatus.success) {
                return _LoadingView(
                  horizontalPadding: horizontalPadding,
                  verticalPadding: verticalPadding,
                  compact: phone,
                  riskHeight: riskHeight,
                );
              }

              final content = Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Column(
                  children: [
                    _PageHeader(
                      compact: compact,
                      narrow: phone,
                      comfortable: tallPhone,
                      onShare: _share,
                      onInformation: _openInformation,
                      onSettings: _openSettings,
                    ),
                    SizedBox(height: gap),
                    LocationBar(
                      compact: phone,
                      comfortable: tallPhone,
                      minimal: phone,
                      available: locationKnown,
                      location: displayLocation,
                      updatedAt: envData.localTime,
                      statusMessage: hasData && failureMessage != null
                          ? 'Data terakhir ${envData.localTime} · $failureMessage'
                          : null,
                      loading: loading || refreshing,
                      retryEnabled: retryable,
                      onRetry: () => initializeEnvironment(),
                      onTap: _openLocationSearch,
                    ),
                    if (!hasData && errorStatus != null) ...[
                      SizedBox(height: gap),
                      Expanded(
                        child: _EnvironmentUnavailable(
                          compact: phone,
                          status: errorStatus!,
                          message: failureMessage!,
                          onRetry: () => initializeEnvironment(),
                          onChooseLocation: _openLocationSearch,
                        ),
                      ),
                    ] else if (phone) ...[
                      SizedBox(height: shortPhone ? 8 : 16),
                      SizedBox(
                        height: mobileRiskSize,
                        child: Center(
                          child: RiskMeter(
                            weather: envData.weather,
                            size: mobileRiskSize,
                            label: 'Risiko',
                            showIcon: false,
                          ),
                        ),
                      ),
                      SizedBox(height: shortPhone ? 12 : 20),
                      SizedBox(
                        height: mobileStatsHeight + 13,
                        child: EnvStats(
                          weather: envData.weather,
                          compactDashboard: true,
                          comfortableDashboard: tallPhone,
                          minimalDashboard: true,
                          cardHeight: mobileStatsHeight,
                        ),
                      ),
                      SizedBox(height: shortPhone ? 16 : 24),
                      RecommendationSection(
                        weather: envData.weather,
                        compact: true,
                        comfortable: tallPhone,
                        minimalDashboard: true,
                      ),
                    ] else ...[
                      SizedBox(height: gap),
                      _RiskPanel(
                        weather: envData.weather,
                        height: riskHeight,
                        compact: false,
                        comfortable: false,
                      ),
                      const SizedBox(height: 12),
                      _SectionHeading(
                        compact: false,
                        comfortable: false,
                        title: 'Kondisi Lingkungan Saat Ini',
                        actionLabel: 'Lihat detail',
                        onAction: _openInformation,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: statsHeight,
                        child: EnvStats(
                          weather: envData.weather,
                          compactDashboard:
                              statsHeight < 120 || constraints.maxWidth < 900,
                          cardHeight: statsHeight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RecommendationSection(weather: envData.weather),
                    ],
                  ],
                ),
              );
              return hasData ? SingleChildScrollView(child: content) : content;
            },
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final bool compact;
  final bool narrow;
  final bool comfortable;
  final VoidCallback onShare;
  final VoidCallback onInformation;
  final VoidCallback onSettings;

  const _PageHeader({
    required this.compact,
    required this.narrow,
    required this.comfortable,
    required this.onShare,
    required this.onInformation,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final markSize = narrow
        ? comfortable
              ? 36.0
              : 32.0
        : compact
        ? 44.0
        : 62.0;
    final titleSize = narrow
        ? comfortable
              ? 18.0
              : 17.0
        : compact
        ? 20.0
        : 30.0;
    final subtitleSize = narrow
        ? 10.0
        : compact
        ? 12.0
        : 16.0;
    final buttonSize = narrow
        ? 44.0
        : compact
        ? 44.0
        : 56.0;
    final iconSize = narrow
        ? 21.0
        : compact
        ? 21.0
        : 27.0;
    final actionGap = narrow
        ? 3.0
        : compact
        ? 5.0
        : 12.0;

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
                  color: context.appColors.forest,
                  fontSize: titleSize,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  'Lingkungan lebih sehat, hidup lebih baik',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appColors.muted,
                    fontSize: subtitleSize,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
        color: context.appColors.card,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: context.appColors.forest, size: iconSize),
          ),
        ),
      ),
    );
  }
}

class _RiskPanel extends StatelessWidget {
  final Weather weather;
  final double height;
  final bool compact;
  final bool comfortable;

  const _RiskPanel({
    required this.weather,
    required this.height,
    required this.compact,
    required this.comfortable,
  });

  @override
  Widget build(BuildContext context) {
    final meterSize = compact
        ? (height * .62).clamp(100.0, comfortable ? 148.0 : 126.0).toDouble()
        : (height * .72).clamp(138.0, 170.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: Container(
        height: height,
        color: context.appColors.card,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/illustrations/risk-landscape.png',
              fit: compact ? BoxFit.fill : BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
            ColoredBox(color: context.appColors.illustrationOverlay),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 5 : 8),
                child: RiskMeter(weather: weather, size: meterSize),
              ),
            ),
            Positioned(
              left: compact ? 10 : 20,
              right: compact ? 10 : 20,
              bottom: compact ? 8 : 12,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 570),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.appColors.card.withValues(
                        alpha: compact ? .78 : .6,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 8 : 12,
                        vertical: compact ? (comfortable ? 5 : 3) : 4,
                      ),
                      child: Text(
                        _riskDescription(weather),
                        textAlign: TextAlign.center,
                        maxLines: compact ? 2 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.appColors.ink,
                          fontSize: compact
                              ? comfortable
                                    ? 13
                                    : 11.5
                              : 15,
                          height: 1.15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
    if (weather.riskState != RiskState.known) {
      return weather.riskDescription;
    }
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
  final bool compact;
  final bool comfortable;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.compact,
    required this.comfortable,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.appColors.forest,
              fontSize: compact
                  ? comfortable
                        ? 20
                        : 17
                  : 27,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: context.appColors.forest,
            padding: EdgeInsets.zero,
            minimumSize: Size(0, compact ? 30 : 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const SizedBox.shrink(),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                compact ? 'Detail' : actionLabel,
                style: TextStyle(
                  color: context.appColors.forest,
                  fontSize: compact
                      ? comfortable
                            ? 13
                            : 12
                      : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: compact ? 1 : 3),
              Icon(Icons.chevron_right, size: compact ? 18 : 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnvironmentUnavailable extends StatelessWidget {
  final bool compact;
  final String status;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onChooseLocation;

  const _EnvironmentUnavailable({
    required this.compact,
    required this.status,
    required this.message,
    required this.onRetry,
    required this.onChooseLocation,
  });

  @override
  Widget build(BuildContext context) {
    final retryable = environmentErrorIsRetryable(status);
    final needsLocationChoice = environmentErrorNeedsLocationChoice(status);
    final title = status == EnvironmentStatus.serverMisconfigured
        ? 'Layanan belum dikonfigurasi'
        : needsLocationChoice
        ? 'Lokasi perlu diperbarui'
        : 'Data lingkungan tidak tersedia';

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 520 : 680),
          child: Material(
            color: context.appColors.card,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 22 : 36,
                vertical: compact ? 24 : 34,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 58 : 68,
                    height: compact ? 58 : 68,
                    decoration: BoxDecoration(
                      color: context.appColors.coralSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      color: context.appColors.coral,
                      size: compact ? 30 : 36,
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appColors.ink,
                      fontSize: compact ? 20 : 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appColors.muted,
                      fontSize: compact ? 14 : 16,
                      height: 1.35,
                    ),
                  ),
                  if (retryable || needsLocationChoice) ...[
                    SizedBox(height: compact ? 18 : 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (retryable)
                          FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba lagi'),
                          ),
                        if (needsLocationChoice)
                          OutlinedButton.icon(
                            onPressed: onChooseLocation,
                            icon: const Icon(Icons.location_on_outlined),
                            label: const Text('Pilih lokasi'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final bool compact;
  final double riskHeight;

  const _LoadingView({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.compact,
    required this.riskHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        verticalPadding,
      ),
      child: Column(
        children: [
          SizedBox(
            height: compact ? 40 : 62,
            child: Row(
              children: [
                _Skeleton(
                  width: compact ? 36 : 62,
                  height: compact ? 36 : 62,
                  circle: true,
                ),
                const SizedBox(width: 10),
                const Expanded(child: _Skeleton(width: 210, height: 22)),
                const SizedBox(width: 10),
                _Skeleton(
                  width: compact ? 38 : 56,
                  height: compact ? 38 : 56,
                  circle: true,
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
          _Skeleton(width: double.infinity, height: compact ? 64 : 82),
          SizedBox(height: compact ? 6 : 10),
          _Skeleton(width: double.infinity, height: riskHeight),
          SizedBox(height: compact ? 8 : 12),
          Expanded(
            child: _Skeleton(width: double.infinity, height: double.infinity),
          ),
        ],
      ),
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
        color: context.appColors.card.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(circle ? height / 2 : 25),
      ),
    );
  }
}
