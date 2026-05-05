// lib/shared/widgets/navbar/widgets/cart_button.dart

import 'package:flutter/material.dart';

import 'navbar_icon_button.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: NavbarIconButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Carrito',
              onTap: onTap,
            ),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2161FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
