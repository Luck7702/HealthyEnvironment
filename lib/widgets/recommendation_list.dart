import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/scroll_demo.dart';
import '../models/weather.dart';

class RecommendationSection extends StatelessWidget {
  final Weather weather;
  final bool compact;
  final bool comfortable;
  final bool minimalDashboard;
  final Widget? footer;

  const RecommendationSection({
    super.key,
    required this.weather,
    this.compact = false,
    this.comfortable = false,
    this.minimalDashboard = false,
    this.footer,
  });

  List<_Recommendation> _recommendations(BuildContext context) {
    final values = [
      ...weather.recommendations,
      if (scrollDemoEnabled) ...scrollDemoRecommendations,
    ];
    if (values.isEmpty) {
      return [
        _Recommendation(
          icon: weather.riskState == RiskState.unknown
              ? Icons.hourglass_empty_rounded
              : Icons.favorite_outline,
          color: context.appColors.green,
          background: context.appColors.greenSoft,
          text: weather.riskState == RiskState.unknown
              ? 'Saran belum tersedia sampai data lingkungan diterima.'
              : 'Kondisi relatif aman. Tetap jaga kesehatan.',
        ),
      ];
    }
    return values.map((text) => _recommendationFor(context, text)).toList();
  }

  _Recommendation _recommendationFor(BuildContext context, String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('uv') || normalized.contains('matahari')) {
      return _Recommendation(
        icon: Icons.wb_sunny_outlined,
        color: context.appColors.orange,
        background: context.appColors.orangeSoft,
        text: text,
      );
    }
    if (normalized.contains('hujan') ||
        normalized.contains('petir') ||
        normalized.contains('berkendara')) {
      return _Recommendation(
        icon: Icons.cloudy_snowing,
        color: context.appColors.blue,
        background: context.appColors.blueSoft,
        text: text,
      );
    }
    if (normalized.contains('minum') || normalized.contains('panas')) {
      return _Recommendation(
        icon: Icons.water_drop_outlined,
        color: context.appColors.blue,
        background: context.appColors.blueSoft,
        text: text,
      );
    }
    return _Recommendation(
      icon: Icons.groups_outlined,
      color: context.appColors.green,
      background: context.appColors.greenSoft,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _recommendations(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saran untuk Anda',
          style: TextStyle(
            color: context.appColors.forest,
            fontSize: minimalDashboard
                ? 20
                : compact
                ? comfortable
                      ? 21
                      : 19
                : 26,
            height: 1.05,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: minimalDashboard
              ? 6
              : compact
              ? 2
              : 4,
        ),
        Text(
          weather.riskDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.appColors.muted,
            fontSize: minimalDashboard
                ? 13
                : compact
                ? comfortable
                      ? 12
                      : 11
                : 15,
            height: minimalDashboard ? 1.25 : 1.15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: minimalDashboard
              ? 14
              : compact
              ? 6
              : 9,
        ),
        Column(
          key: const Key('recommendations-list'),
          children: [
            for (var index = 0; index < recommendations.length; index++) ...[
              if (index > 0) SizedBox(height: compact ? 10 : 8),
              _RecommendationTile(
                recommendation: recommendations[index],
                compact: compact,
                comfortable: comfortable,
                minimal: minimalDashboard,
              ),
            ],
          ],
        ),
        if (footer != null) ...[
          SizedBox(height: compact ? (comfortable ? 10 : 6) : 8),
          footer!,
        ],
      ],
    );
  }
}

class _Recommendation {
  final IconData icon;
  final Color color;
  final Color background;
  final String text;

  const _Recommendation({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
  });
}

class _RecommendationTile extends StatelessWidget {
  final _Recommendation recommendation;
  final bool compact;
  final bool comfortable;
  final bool minimal;

  const _RecommendationTile({
    required this.recommendation,
    required this.compact,
    required this.comfortable,
    required this.minimal,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.appColors.line),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () {},
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: compact
                ? minimal
                      ? 72
                      : comfortable
                      ? 60
                      : 52
                : 68,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: minimal
                  ? 14
                  : compact
                  ? comfortable
                        ? 8
                        : 6
                  : 9,
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 40 : 46,
                  height: compact ? 40 : 46,
                  decoration: BoxDecoration(
                    color: recommendation.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recommendation.icon,
                    color: recommendation.color,
                    size: compact ? 25 : 30,
                  ),
                ),
                SizedBox(width: compact ? 12 : 18),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 570),
                    child: Text(
                      compact
                          ? recommendation.text.replaceAll('\n', ' ')
                          : recommendation.text,
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appColors.ink,
                        fontSize: compact ? 14 : 16,
                        height: compact ? 1.35 : 1.15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                if (!minimal)
                  Icon(
                    Icons.chevron_right,
                    color: context.appColors.muted,
                    size: compact ? 20 : 25,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
