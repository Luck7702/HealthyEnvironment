import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../services/pwa_install.dart';

/// Invites browser users to add the app to their home screen. Renders
/// nothing when installing is not possible, already done, or dismissed.
class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  PwaInstallMode _mode = pwaInstallMode();

  @override
  void initState() {
    super.initState();
    onPwaInstallChange(() {
      if (mounted) setState(() => _mode = pwaInstallMode());
    });
  }

  Future<void> _install() async {
    await promptPwaInstall();
    if (mounted) setState(() => _mode = pwaInstallMode());
  }

  void _dismiss() {
    dismissPwaInstall();
    setState(() => _mode = PwaInstallMode.none);
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == PwaInstallMode.none) return const SizedBox.shrink();
    final colors = context.appColors;
    final ios = _mode == PwaInstallMode.iosHint;
    return Container(
      key: const Key('install-banner'),
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.add_to_home_screen, color: colors.forest, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pasang di layar utama',
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ios
                      ? 'Ketuk tombol Bagikan, lalu pilih "Tambah ke Layar Utama".'
                      : 'Buka LingkunganSehat langsung dari ikon, seperti aplikasi.',
                  style: TextStyle(color: colors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          if (!ios)
            FilledButton(
              onPressed: _install,
              style: FilledButton.styleFrom(
                backgroundColor: colors.forest,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Pasang'),
            ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: _dismiss,
            icon: Icon(Icons.close, color: colors.muted, size: 20),
          ),
        ],
      ),
    );
  }
}
