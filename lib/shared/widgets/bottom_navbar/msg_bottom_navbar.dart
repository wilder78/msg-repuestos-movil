import 'package:flutter/material.dart';

class MsgBottomNavbar extends StatelessWidget {
  const MsgBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.canViewManagement = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool canViewManagement;

  @override
  Widget build(BuildContext context) {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.grid_view_outlined),
        activeIcon: Icon(Icons.grid_view_rounded),
        label: 'Catálogo',
      ),
      if (canViewManagement)
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Gestión',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_outlined),
        activeIcon: Icon(Icons.shopping_cart),
        label: 'Carrito',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF11244D),
      unselectedItemColor: Colors.black38,
      showSelectedLabels: true, // Habilitar etiquetas para que se distingan los módulos
      showUnselectedLabels: true,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      elevation: 12,
      items: items,
    );
  }
}