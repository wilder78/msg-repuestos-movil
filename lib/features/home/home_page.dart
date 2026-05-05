// lib/features/home/home_page.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/dio_config.dart';
import '../../shared/widgets/navbar/msg_top_navbar.dart';
import '../auth/models/user_model.dart';
import '../auth/login_page.dart';
import 'widgets/carousel.dart';

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

    // ✅ Redirigir al LoginPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.menu),
                title: Text('Menu'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Builder(
              builder: (context) => MsgTopNavbar(
                cartCount: 0,
                onCartTap: () {},
                onProfileTap: _logout, // 🔑 también desde el icono de perfil
                onMenuTap: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 12),
                  const HomeCarousel(),
                  const SizedBox(height: 22),
                  const Text(
                    'Productos destacados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.cloud_sync),
                    label: const Text('Probar conexion con Backend'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // lib/features/home/home_page.dart

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// import '../../config/dio_config.dart';
// import '../../shared/widgets/navbar/msg_top_navbar.dart';
// import '../auth/models/user_model.dart';
// import 'widgets/carousel.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key, this.user});

//   final UserModel? user;

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   Future<void> _testConnection() async {
//     final messenger = ScaffoldMessenger.of(context);

//     try {
//       final response = await DioConfig.dio.get<Map<String, dynamic>>('/health');
//       final message = response.data?['message'] ?? 'API disponible';

//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Conexion exitosa: $message'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } on DioException catch (error) {
//       final statusCode = error.response?.statusCode;
//       final detail = statusCode == null
//           ? error.message
//           : 'HTTP $statusCode en ${error.requestOptions.uri}';

//       messenger.showSnackBar(
//         SnackBar(
//           content: Text('Error al conectar: $detail'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       endDrawer: const Drawer(
//         child: SafeArea(
//           child: ListTile(leading: Icon(Icons.menu), title: Text('Menu')),
//         ),
//       ),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             Builder(
//               builder: (context) => MsgTopNavbar(
//                 cartCount: 0,
//                 onCartTap: () {},
//                 onProfileTap: () => Navigator.pushNamed(context, '/login'),
//                 onMenuTap: () => Scaffold.of(context).openEndDrawer(),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(20),
//                 children: [
//                   const SizedBox(height: 12),
//                   const HomeCarousel(),
//                   const SizedBox(height: 22),
//                   const Text(
//                     'Productos destacados',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
//                   ),
//                   const SizedBox(height: 28),
//                   ElevatedButton.icon(
//                     onPressed: _testConnection,
//                     icon: const Icon(Icons.cloud_sync),
//                     label: const Text('Probar conexion con Backend'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
