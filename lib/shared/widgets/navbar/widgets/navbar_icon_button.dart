// lib/shared/widgets/navbar/widgets/navbar_icon_button.dart

import 'package:flutter/material.dart';

class NavbarIconButton extends StatelessWidget {
  const NavbarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, color: const Color(0xFF12233E), size: 25),
    );
  }
}