import 'package:flutter/material.dart';
import 'package:LingkunganSehat/config/colors_theme.dart';
import 'package:LingkunganSehat/models/weather.dart';
import 'package:LingkunganSehat/widgets/window_dialog.dart';

class EnvStats extends StatelessWidget {
  
  final Weather weather;

  const EnvStats({
    super.key,
    required this.weather
  });

  int get aqi => weather.aqi;
  int get uv => weather.uv;
  int get temp =>weather.temp;
  

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    Color? accent,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (accent ?? Colors.grey).withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent ?? Colors.grey),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          child: _statCard(
            label: "AQI",
            value: "$aqi",
            icon: Icons.cloud,
            accent: EnvStatsColors.getAqiAccent(aqi),
          ),
          onTap: () {
            InfoDialog.show(
              context,
              title: "Apa itu AQI?",
              message:
                  "AIR QUALITY INDEX (AQI)\n\nDEFINISI\nIndeks angka yang menunjukkan tingkat kebersihan atau pencemaran udara.\n\nSKALA\n0–50 : Baik\n51–100 : Sedang\n101–150 : Tidak sehat (kelompok sensitif)\n151–200 : Tidak sehat\n201–300 : Sangat tidak sehat\n300+ : Berbahaya\n\n",
              icon: Icons.help_outline,
            );
          },
        ),
        GestureDetector(
          child: _statCard(
            label: "UV",
            value: "$uv",
            icon: Icons.wb_sunny,
            accent: EnvStatsColors.getUvAccent(uv),
          ),
          onTap: () {
            InfoDialog.show(
              context,
              title: "Apa itu UV",
              message: "UV INDEX\n\nDEFINISI\nIndeks angka yang menunjukkan tingkat intensitas radiasi ultraviolet (UV) dari matahari di suatu tempat.\n\nSKALA\n0–2 : Rendah\n3–5 : Sedang\n6–7 : Tinggi\n8–10 : Sangat tinggi\n11+ : Ekstrem\n\nDAMPAK\nPaparan UV tinggi dapat menyebabkan kulit terbakar, penuaan dini, dan meningkatkan risiko kanker kulit.\n\nPRINSIP\nSemakin tinggi angka UV Index, semakin cepat kulit dapat mengalami kerusakan tanpa perlindungan.",
              icon: Icons.help_outline,
            );
          },
        ),
        GestureDetector(
          child: _statCard(
            label: "Suhu",
            value: "$temp°C",
            icon: Icons.thermostat,
            accent: EnvStatsColors.getTempAccent(temp),
          ),
          onTap: () {
            InfoDialog.show(
              context,
              title: "Apa itu Suhu Udara?",
              message: "TEMPERATURE\n\nDEFINISI\nUkuran tingkat panas atau dingin udara di suatu tempat, biasanya dinyatakan dalam derajat Celsius (°C).\n\nKATEGORI UMUM\n< 10°C : Dingin\n10–20°C : Sejuk\n21–30°C : Hangat\n31–35°C : Panas\n> 35°C : Sangat panas\n\nDAMPAK\nSuhu yang terlalu tinggi dapat menyebabkan dehidrasi dan heatstroke, sedangkan suhu terlalu rendah dapat menyebabkan hipotermia.\n\nPRINSIP\nSemakin tinggi suhu, semakin besar energi panas di lingkungan sekitar.",
              icon: Icons.help_outline,
            );
          },
        ),
      ],
    );
  }
}
