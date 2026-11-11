import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../services/pwa_install.dart';

const _iosSteps = 'Ketuk tombol Bagikan, lalu pilih "Tambah ke Layar Utama".';

/// Installs the web app: the browser's install dialog where supported, or
/// the manual steps on iPhone/iPad. Used by the banner and the header button.
Future<void> installApp(BuildContext context, PwaInstallMode mode) async {
  if (mode == PwaInstallMode.prompt) {
    await promptPwaInstall();
    return;
  }
  if (mode == PwaInstallMode.iosHint) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pasang di layar utama'),
        content: const Text(_iosSteps),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

/// Invites browser users to add the app to their home screen. Renders
/// nothing when installing is not possible, already done, or dismissed.
class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  bool _dismissed = pwaBannerDismissed();

  void _dismiss() {
    dismissPwaBanner();
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PwaInstallMode>(
      valueListenable: pwaInstallMode,
      builder: (context, mode, _) {
        if (_dismissed || mode == PwaInstallMode.none) {
          return const SizedBox.shrink();
        }
        final colors = context.appColors;
        final ios = mode == PwaInstallMode.iosHint;
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
                          ? _iosSteps
                          : 'Buka LingkunganSehat langsung dari ikon, seperti aplikasi.',
                      style: TextStyle(color: colors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!ios)
                FilledButton(
                  onPressed: () => installApp(context, mode),
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
      },
    );
  }
}
