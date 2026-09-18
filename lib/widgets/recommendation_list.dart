import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/weather.dart';

class RecommendationSection extends StatelessWidget {
  final Weather weather;

  const RecommendationSection({super.key, required this.weather});

  List<_Recommendation> get _recommendations {
    final values = weather.recommendations;
    if (values.isEmpty) {
      return [
        _Recommendation(
          icon: weather.riskState == RiskState.unknown
              ? Icons.hourglass_empty_rounded
              : Icons.favorite_outline,
          color: AppColors.green,
          background: AppColors.greenSoft,
          text: weather.riskState == RiskState.unknown
              ? 'Saran belum tersedia sampai data lingkungan diterima.'
              : 'Kondisi relatif aman. Tetap jaga kesehatan.',
        ),
      ];
    }
    return values.map(_recommendationFor).toList();
  }

  _Recommendation _recommendationFor(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('uv') || normalized.contains('matahari')) {
      return _Recommendation(
        icon: Icons.wb_sunny_outlined,
        color: AppColors.orange,
        background: AppColors.orangeSoft,
        text: text,
      );
    }
    if (normalized.contains('hujan') ||
        normalized.contains('petir') ||
        normalized.contains('berkendara')) {
      return _Recommendation(
        icon: Icons.cloudy_snowing,
        color: AppColors.blue,
        background: AppColors.blueSoft,
        text: text,
      );
    }
    if (normalized.contains('minum') || normalized.contains('panas')) {
      return _Recommendation(
        icon: Icons.water_drop_outlined,
        color: AppColors.blue,
        background: AppColors.blueSoft,
        text: text,
      );
    }
    return _Recommendation(
      icon: Icons.groups_outlined,
      color: AppColors.green,
      background: AppColors.greenSoft,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saran untuk Anda',
              style: TextStyle(
                color: AppColors.forest,
                fontSize: narrow ? 26 : 31,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              weather.riskDescription,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: narrow ? 16 : 19,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            ..._recommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecommendationTile(
                  recommendation: recommendation,
                  narrow: narrow,
                ),
              ),
            ),
          ],
        );
      },
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
  final bool narrow;

  const _RecommendationTile({
    required this.recommendation,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {},
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: narrow ? 72 : 88),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 14 : 23,
              vertical: narrow ? 12 : 14,
            ),
            child: Row(
              children: [
                Container(
                  width: narrow ? 48 : 57,
                  height: narrow ? 48 : 57,
                  decoration: BoxDecoration(
                    color: recommendation.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recommendation.icon,
                    color: recommendation.color,
                    size: narrow ? 31 : 38,
                  ),
                ),
                SizedBox(width: narrow ? 14 : 52),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 570),
                    child: Text(
                      narrow
                          ? recommendation.text.replaceAll('\n', ' ')
                          : recommendation.text,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: narrow ? 17 : 22,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: narrow ? 8 : 12),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                  size: 29,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
