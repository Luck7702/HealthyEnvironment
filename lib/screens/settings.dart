import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Tampilan',
            style: TextStyle(
              color: context.appColors.forest,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, child) {
              final darkMode = mode == ThemeMode.dark;
              return _SettingTile(
                icon: darkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'Mode gelap',
                subtitle: darkMode
                    ? 'Lebih nyaman untuk penggunaan malam hari'
                    : 'Gunakan tampilan terang seperti sekarang',
                trailing: Switch.adaptive(
                  value: darkMode,
                  onChanged: setDarkMode,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Lokasi dan bahasa',
            style: TextStyle(
              color: context.appColors.forest,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.language_outlined,
            title: 'Bahasa',
            subtitle: 'Bahasa Indonesia',
            trailing: Icon(Icons.chevron_right, color: context.appColors.muted),
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.location_on_outlined,
            title: 'Lokasi saat ini',
            subtitle: 'Ubah lokasi dari halaman utama',
            trailing: Icon(Icons.chevron_right, color: context.appColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.appColors.greenSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.appColors.forest),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.appColors.ink,
                    fontSize: 16,
                    height: 1.375,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.appColors.muted,
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
