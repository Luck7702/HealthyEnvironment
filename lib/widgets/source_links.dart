import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_theme.dart';
import '../config/sources.dart';

/// Tappable list of [Source]s that open in the browser.
class SourceLinks extends StatelessWidget {
  final List<Source> sources;

  const SourceLinks({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final source in sources)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => launchUrl(
              Uri.parse(source.url),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: context.appColors.forest,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source.label,
                      style: TextStyle(
                        color: context.appColors.forest,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: context.appColors.forest,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
