import 'package:flutter/material.dart';

import '../config/app_theme.dart';

void showInputPrompt(
  BuildContext context,
  void Function(String value) onSubmit,
) {
  final controller = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Cari lokasi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Nama kota atau area',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            onSubmit(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(context);
              onSubmit(value);
            },
            child: const Text('Cari'),
          ),
        ],
      );
    },
  ).then((_) => controller.dispose());
}

class LocationBar extends StatelessWidget {
  final bool available;
  final String location;
  final String updatedAt;
  final bool loading;
  final VoidCallback onRetry;
  final VoidCallback onTap;

  const LocationBar({
    super.key,
    required this.available,
    required this.location,
    required this.updatedAt,
    required this.loading,
    required this.onRetry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 500;
            final title = available && location.isNotEmpty
                ? location
                : 'Lokasi belum tersedia';
            final subtitle = available && updatedAt.isNotEmpty
                ? narrow
                      ? 'Diperbarui $updatedAt'
                      : 'Diperbarui hari ini, $updatedAt'
                : 'Aktifkan lokasi untuk melihat kondisi sekitar';
            final iconSize = narrow ? 56.0 : 70.0;

            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: narrow ? 92 : 106),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 16 : 20,
                  vertical: narrow ? 12 : 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(
                        color: AppColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.forest,
                        size: narrow ? 32 : 39,
                      ),
                    ),
                    SizedBox(width: narrow ? 12 : 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: narrow ? 22 : 28,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: narrow ? 14 : 18,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: narrow ? 8 : 12),
                    if (narrow)
                      IconButton(
                        onPressed: loading ? null : onRetry,
                        tooltip: 'Perbarui data',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.greenSoft,
                          foregroundColor: AppColors.green,
                        ),
                        icon: loading
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.green,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 32),
                      )
                    else
                      TextButton.icon(
                        onPressed: loading ? null : onRetry,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          minimumSize: const Size(0, 46),
                        ),
                        icon: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.greenSoft,
                            shape: BoxShape.circle,
                          ),
                          child: loading
                              ? const Padding(
                                  padding: EdgeInsets.all(13),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.green,
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  size: 34,
                                  color: AppColors.green,
                                ),
                        ),
                        label: const Text(
                          'Perbarui',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
