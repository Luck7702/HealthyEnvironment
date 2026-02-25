import 'package:flutter/material.dart';
import '../models/weather.dart';

class RecommendationSection extends StatelessWidget {
  final Weather weather;

  const RecommendationSection({super.key, required this.weather});

  List<String> get getRecommendations {
    List<String> recs = [];

    if (weather.aqi > 150) {
      recs.add("Kualitas udara tidak sehat, pastikan menggunakan masker ");
    } else if (weather.aqi > 120) {
      recs.add("Kualitas udara sedikit kurang baik");
    }

    if (weather.uv > 7) {
      recs.add("Gunakan pelindung dari sinar matahari");
    }
    if (weather.uv > 4) {
      recs.add("Hindari paparan matahari langsung");
    }

    if (weather.temp >= 30) {
      recs.add("Perbanyak minum air (cuaca panas)");
    } else if (weather.temp < 15) {
      recs.add("Suhu udara cukup dingin, gunakan pakaian hangat");
    }
    if (weather.humidity < 40) {
      recs.add("Perbanyak minum air (udara kering)");
    }

    if (weather.getRiskLevel == "Tinggi") {
      recs.add("Risiko cuaca tinggi, pastikan jaga kesehatan");
    }

    if (recs.isEmpty) {
      recs.add("Kondisi relatif aman, tetap jaga kesehatan");
    }

    return recs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saran untuk Anda",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          "Berdasarkan kondisi lingkungan saat ini",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...getRecommendations.map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(child: Text(r)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
