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
    this.userName,
  });

  final int cartCount;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onMenuTap;
  final String? userName;

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
            _ProfileButton(userName: userName, onTap: onProfileTap),
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

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.userName, required this.onTap});

  final String? userName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = userName?.trim();

    if (name == null || name.isEmpty) {
      return NavbarIconButton(
        icon: Icons.person_outline,
        tooltip: 'Perfil',
        onTap: onTap,
      );
    }

    return Tooltip(
      message: 'Perfil',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF11244D),
            shape: BoxShape.circle,
          ),
          child: Text(
            _initialsFrom(name),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  String _initialsFrom(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
