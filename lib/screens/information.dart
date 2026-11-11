import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/sources.dart';
import '../widgets/source_links.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mengapa bisa bahaya?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Kenali faktor lingkungan yang bisa memengaruhi kesehatan saat beraktivitas di luar.',
            style: TextStyle(
              color: context.appColors.muted,
              fontSize: 17,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          InfoCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Sinar UV',
            description:
                'Paparan sinar matahari dengan indeks UV tinggi dapat menyebabkan kulit terbakar, mata perih, dan risiko kesehatan dalam jangka panjang.',
            color: context.appColors.orange,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.air,
            title: 'Polusi udara',
            description:
                'Kualitas udara yang buruk dapat mengganggu pernapasan dan memperburuk kondisi kesehatan tertentu. Gunakan masker bila diperlukan.',
            color: context.appColors.green,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.thermostat_outlined,
            title: 'Suhu',
            description:
                'Suhu yang terlalu panas dapat menyebabkan dehidrasi dan heat stress. Minum cukup dan ambil waktu istirahat.',
            color: context.appColors.coral,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.favorite_outline,
            title: 'Tujuan aplikasi',
            description:
                'LingkunganSehat membantu pengemudi memahami kondisi sekitar agar dapat bekerja dengan lebih waspada dan menjaga kesehatan.',
            color: context.appColors.blue,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.info_outline,
            title: 'Bukan saran medis',
            description:
                'Penilaian risiko bersifat indikatif. Data berasal dari model WeatherAPI.com, bukan pengukuran resmi. Untuk peringatan resmi, ikuti BMKG (cuaca) dan ISPU dari Kementerian Lingkungan Hidup (kualitas udara).',
            color: context.appColors.orange,
          ),
          SizedBox(height: 24),
          Text(
            'Sumber & metode',
            style: TextStyle(
              color: context.appColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Risiko keseluruhan memakai bahaya tertinggi dari kualitas udara (skala AQI US EPA), UV (WHO), panas (indeks panas NWS, naik satu tingkat saat siang cerah sesuai OSHA), dan cuaca (petir dan hujan lebat). Kelembapan hanya ditampilkan sebagai informasi.',
            style: TextStyle(
              color: context.appColors.muted,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8),
          SourceLinks(sources: Sources.all),
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
                  style: TextStyle(
                    color: context.appColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    color: context.appColors.muted,
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
