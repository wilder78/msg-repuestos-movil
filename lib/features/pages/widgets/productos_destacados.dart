import 'package:flutter/material.dart';

class ProductosDestacados extends StatelessWidget {
  const ProductosDestacados({super.key, required this.onTestConnection});

  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos destacados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: onTestConnection,
          icon: const Icon(Icons.cloud_sync),
          label: const Text('Probar conexion con Backend'),
        ),
      ],
    );
  }
}