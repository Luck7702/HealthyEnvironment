import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class InfoRange {
  final String range;
  final String category;

  const InfoRange(this.range, this.category);
}

class InfoDialog {
  static Future<void> showMetric(
    BuildContext context, {
    required String title,
    required String currentValue,
    required String currentStatus,
    required String definition,
    required String impact,
    required String guidance,
    required IconData icon,
    required Color accent,
    required List<InfoRange> ranges,
    required int activeRange,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * .84;
        return Dialog(
          backgroundColor: context.appColors.card,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 430, maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricHeader(
                          title: title,
                          currentValue: currentValue,
                          currentStatus: currentStatus,
                          icon: icon,
                          accent: accent,
                        ),
                        const SizedBox(height: 20),
                        _InfoBlock(title: 'Tentang', body: definition),
                        const SizedBox(height: 18),
                        Text(
                          'Rentang kategori',
                          style: TextStyle(
                            color: context.appColors.forest,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var index = 0; index < ranges.length; index++) ...[
                          _RangeRow(
                            item: ranges[index],
                            active: index == activeRange,
                            accent: accent,
                          ),
                          if (index != ranges.length - 1)
                            const SizedBox(height: 6),
                        ],
                        const SizedBox(height: 18),
                        _InfoBlock(title: 'Dampak', body: impact),
                        const SizedBox(height: 14),
                        _InfoBlock(
                          title: 'Yang dapat dilakukan',
                          body: guidance,
                          accent: accent,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.appColors.forest,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricHeader extends StatelessWidget {
  final String title;
  final String currentValue;
  final String currentStatus;
  final IconData icon;
  final Color accent;

  const _MetricHeader({
    required this.title,
    required this.currentValue,
    required this.currentStatus,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.appColors.forest,
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: currentValue,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: '  $currentStatus'),
                  ],
                ),
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RangeRow extends StatelessWidget {
  final InfoRange item;
  final bool active;
  final Color accent;

  const _RangeRow({
    required this.item,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: .11) : context.appColors.page,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: .55)
              : context.appColors.line,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              item.range,
              style: TextStyle(
                color: active ? accent : context.appColors.ink,
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.category,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: active ? accent : context.appColors.muted,
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(width: 7),
            Icon(Icons.check_circle, color: accent, size: 17),
          ],
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;
  final Color? accent;

  const _InfoBlock({required this.title, required this.body, this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: accent == null
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: accent == null
          ? null
          : BoxDecoration(
              color: accent!.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.appColors.forest,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              color: context.appColors.ink,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
