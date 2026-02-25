import 'package:flutter/material.dart';

 void showInputPrompt(
    BuildContext context,
    void Function(String value) onSubmit,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masukkan Lokasi"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text;

              Navigator.pop(context); // close dialog
              onSubmit(text); // call your function
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

class LocationBar extends StatelessWidget {
  final bool available;
  final String location;
  final VoidCallback onRetry;

  const LocationBar({
    super.key,
    required this.available,
    required this.location,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              available ? location : "Lokasi gagal didapatkan",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (!available)
            TextButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
