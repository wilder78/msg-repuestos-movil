import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../config/dio_config.dart';
import '../../shared/widgets/navbar/msg_top_navbar.dart';
import '../auth/login_page.dart';
import '../auth/models/user_model.dart';
import 'cart/providers/cart_provider.dart';
import 'cart/cart_page.dart';
import 'widgets/home_body.dart';
import 'widgets/profile_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user});

  final UserModel? user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _testConnection() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await DioConfig.dio.get<Map<String, dynamic>>('api/health');
      final message = response.data?['message'] ?? 'API disponible';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Conexion exitosa: $message'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final detail = statusCode == null
          ? error.message
          : 'HTTP $statusCode en ${error.requestOptions.uri}';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al conectar: $detail'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');

    if (!mounted) return;

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Builder(
              builder: (context) => MsgTopNavbar(
                cartCount: Provider.of<CartProvider>(context).itemCount,
                onCartTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CartPage(user: widget.user)),
                  );
                },
                userName: widget.user?.nombreUsuario,
                onProfileTap: () {
                  if (widget.user == null) {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    ProfileMenu.show(
                      context: context,
                      user: widget.user,
                      onLogout: _logout,
                    );
                  }
                },
                onLogoutTap: _logout,
              ),
            ),
            Expanded(child: HomeBody(onTestConnection: _testConnection)),
          ],
        ),
      ),
    );
  }
}
