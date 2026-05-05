import 'package:flutter/material.dart';

import 'features/shell_page.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSG Repuestos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF11244D)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ShellPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
