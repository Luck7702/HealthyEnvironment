import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mengapa bisa bahaya?'),
        backgroundColor: const Color.fromARGB(255, 89, 255, 153),
      ),
      backgroundColor: const Color.fromARGB(255, 58, 58, 58),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          InfoCard(
            icon: Icons.wb_sunny,
            title: 'Sinar UV',
            description:
                'Paparan sinar matahari dengan indeks UV tinggi dapat menyebabkan kulit terbakar, mata perih, dan risiko kesehatan dalam jangka panjang.'
                '\n\nPengemudi ojek online sering bekerja berjam-jam di bawah sinar matahari langsung, sehingga penting untuk mengetahui kapan tingkat UV sedang tinggi agar bisa menggunakan pelindung seperti jaket, masker, atau kacamata.',
            color: Colors.amber,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.air,
            title: 'Polusi Udara',
            description:
                'Kualitas udara yang buruk dapat mengganggu pernapasan, membuat tubuh cepat lelah, dan memperburuk kondisi kesehatan tertentu. '
                '\n\nArea dengan lalu lintas padat biasanya memiliki tingkat polusi yang lebih tinggi. Dengan mengetahui kondisi udara, pengemudi dapat lebih waspada dan mempertimbangkan penggunaan masker atau istirahat sejenak.',
            color: Colors.teal,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.thermostat,
            title: 'Suhu',
            description:
                'Suhu yang terlalu panas dapat menyebabkan dehidrasi, lemas, dan heat stress. Bekerja dalam kondisi panas tanpa istirahat yang cukup dapat memengaruhi konsentrasi dan stamina. '
                '\n\nMemantau suhu membantu pengemudi menentukan kapan perlu minum lebih banyak air atau mengambil waktu istirahat.',
            color: Colors.orange,
          ),
          SizedBox(height: 12),
          InfoCard(
            icon: Icons.info_outline,
            title: 'Tujuan Aplikasi Ini',
            description:
                'Aplikasi ini dibuat untuk membantu pengemudi ojek online lebih sadar terhadap kondisi lingkungan sekitar saat bekerja. '
                '\n\nInformasi yang ditampilkan bersifat sederhana dan mudah dipahami, agar dapat membantu mengambil keputusan yang lebih aman dalam aktivitas sehari-hari. Tujuannya bukan untuk menakut-nakuti, tetapi untuk meningkatkan kewaspadaan dan menjaga kesehatan.',
            color: Colors.green,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
