import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/dio_config.dart';
import '../../shared/widgets/navbar/msg_top_navbar.dart';
import '../auth/login_page.dart';
import '../auth/models/user_model.dart';
import 'widgets/home_body.dart';
import 'widgets/home_drawer.dart';
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
      final response = await DioConfig.dio.get<Map<String, dynamic>>('/health');
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
      endDrawer: HomeDrawer(onLogout: _logout),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Builder(
              builder: (context) => MsgTopNavbar(
                cartCount: 0,
                onCartTap: () {},
                userName: widget.user?.nombreUsuario,
                onProfileTap: () => ProfileMenu.show(
                  context: context,
                  user: widget.user,
                  onLogout: _logout,
                ),
                onMenuTap: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
            Expanded(child: HomeBody(onTestConnection: _testConnection)),
          ],
        ),
      ),
    );
  }
}
