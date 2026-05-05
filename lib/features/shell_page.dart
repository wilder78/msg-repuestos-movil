import 'package:flutter/material.dart';

import '../../shared/widgets/bottom_navbar/msg_bottom_navbar.dart';
import 'auth/models/user_model.dart';
import 'pages/home_page.dart';
import 'pages/cart/cart_page.dart';
import 'pages/categories/categories_page.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      const CategoriesPage(),
      const CartPage(),
      ProfilePage(),
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
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
