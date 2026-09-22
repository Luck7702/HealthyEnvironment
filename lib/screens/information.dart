import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mengapa bisa bahaya?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: const [
          Text(
            'Kenali faktor lingkungan yang bisa memengaruhi kesehatan saat beraktivitas di luar.',
            style: TextStyle(color: AppColors.muted, fontSize: 17, height: 1.4),
          ),
          SizedBox(height: 20),
          InfoCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Sinar UV',
            description:
                'Paparan sinar matahari dengan indeks UV tinggi dapat menyebabkan kulit terbakar, mata perih, dan risiko kesehatan dalam jangka panjang.',
            color: AppColors.orange,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.air,
            title: 'Polusi udara',
            description:
                'Kualitas udara yang buruk dapat mengganggu pernapasan dan memperburuk kondisi kesehatan tertentu. Gunakan masker bila diperlukan.',
            color: AppColors.green,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.thermostat_outlined,
            title: 'Suhu',
            description:
                'Suhu yang terlalu panas dapat menyebabkan dehidrasi dan heat stress. Minum cukup dan ambil waktu istirahat.',
            color: AppColors.coral,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.favorite_outline,
            title: 'Tujuan aplikasi',
            description:
                'LingkunganSehat membantu pengemudi memahami kondisi sekitar agar dapat bekerja dengan lebih waspada dan menjaga kesehatan.',
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
