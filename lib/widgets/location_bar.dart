import 'package:flutter/material.dart';

import '../config/app_theme.dart';

Future<void> showInputPrompt(
  BuildContext context,
  void Function(String value) onSubmit,
) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => const _LocationInputDialog(),
  );
  if (value != null && context.mounted) onSubmit(value);
}

class _LocationInputDialog extends StatefulWidget {
  const _LocationInputDialog();

  @override
  State<_LocationInputDialog> createState() => _LocationInputDialogState();
}

class _LocationInputDialogState extends State<_LocationInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cari lokasi'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          labelText: 'Nama kota atau area',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Cari')),
      ],
    );
  }
}

class LocationBar extends StatelessWidget {
  final bool compact;
  final bool comfortable;
  final bool minimal;
  final bool available;
  final String location;
  final String updatedAt;
  final bool loading;
  final VoidCallback onRetry;
  final VoidCallback onTap;

  const LocationBar({
    super.key,
    this.compact = false,
    this.comfortable = false,
    this.minimal = false,
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
            final narrow = compact || constraints.maxWidth < 500;
            final title = available && location.isNotEmpty
                ? location
                : narrow
                ? 'Pilih lokasi'
                : 'Lokasi belum tersedia';
            final subtitle = available && updatedAt.isNotEmpty
                ? narrow
                      ? 'Diperbarui $updatedAt'
                      : 'Diperbarui hari ini, $updatedAt'
                : narrow
                ? 'Cari kota atau gunakan lokasi'
                : 'Aktifkan lokasi untuk melihat kondisi sekitar';
            final iconSize = narrow
                ? comfortable
                      ? 46.0
                      : 42.0
                : 58.0;

            if (minimal) {
              return SizedBox(
                height: comfortable ? 58 : 54,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.forest,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: comfortable ? 17 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (loading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.green,
                          ),
                        )
                      else
                        Text(
                          available && updatedAt.isNotEmpty
                              ? updatedAt
                              : 'Pilih lokasi',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: comfortable ? 14 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: narrow
                  ? comfortable
                        ? 72
                        : 64
                  : 82,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 10 : 18,
                  vertical: narrow ? 8 : 12,
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
                        size: narrow ? 25 : 33,
                      ),
                    ),
                    SizedBox(width: narrow ? 9 : 14),
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
                              fontSize: narrow
                                  ? comfortable
                                        ? 18
                                        : 16
                                  : 23,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: narrow ? 2 : 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: narrow
                                  ? comfortable
                                        ? 12
                                        : 11
                                  : 15,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: narrow ? 5 : 12),
                    if (narrow)
                      IconButton(
                        onPressed: loading ? null : onRetry,
                        tooltip: 'Perbarui data',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: comfortable ? 44 : 40,
                          height: comfortable ? 44 : 40,
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
                            : const Icon(Icons.refresh_rounded, size: 25),
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
