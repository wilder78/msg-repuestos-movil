// lib/shared/widgets/navbar/msg_top_navbar.dart

import 'package:flutter/material.dart';

import 'widgets/cart_button.dart';
import 'widgets/navbar_icon_button.dart';

class MsgTopNavbar extends StatelessWidget {
  const MsgTopNavbar({
    super.key,
    required this.cartCount,
    required this.onCartTap,
    required this.onProfileTap,
    required this.onMenuTap,
  });

  final int cartCount;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 54,
                height: 54,
                child: Transform.scale(
                  scale: 1.35,
                  child: Image.asset(
                    'assets/images/logocuadrado.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Spacer(),
            CartButton(count: cartCount, onTap: onCartTap),
            const SizedBox(width: 10),
            NavbarIconButton(
              icon: Icons.person_outline,
              tooltip: 'Perfil',
              onTap: onProfileTap,
            ),
            const SizedBox(width: 10),
            NavbarIconButton(
              icon: Icons.menu,
              tooltip: 'Menu',
              onTap: onMenuTap,
            ),
          ],
        ),
      ),
    );
  }
}
