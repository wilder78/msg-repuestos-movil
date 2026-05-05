import 'package:flutter/material.dart';

import 'carousel.dart';
import 'productos_destacados.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.onTestConnection});

  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        const HomeCarousel(),
        const SizedBox(height: 22),
        ProductosDestacados(onTestConnection: onTestConnection),
      ],
    );
  }
}