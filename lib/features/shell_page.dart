import 'package:flutter/material.dart';

import '../../shared/widgets/bottom_navbar/msg_bottom_navbar.dart';
import 'auth/models/user_model.dart';
import 'pages/home_page.dart';
import 'pages/cart/cart_page.dart';
import 'pages/productos/productos_catalog_page.dart';
import 'pages/productos/productos_page.dart';
import 'pages/profile/profile_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, this.user});

  final UserModel? user;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final bool _canViewProductos;

  @override
  void initState() {
    super.initState();
    _canViewProductos = widget.user?.canViewProductos ?? false;

    _pages = [
      HomePage(user: widget.user),
      const ProductosCatalogPage(), // Visible para todos para comprar
      if (_canViewProductos) 
         ProductosPage(role: widget.user?.rolNombre.toLowerCase() ?? 'vendedor'), // Módulo de gestión
      CartPage(user: widget.user),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: MsgBottomNavbar(
        currentIndex: _currentIndex,
        canViewManagement: _canViewProductos,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
