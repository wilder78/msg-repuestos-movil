import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'features/pages/cart/providers/cart_provider.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MSG Repuestos',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF11244D),
            primary: const Color(0xFF11244D),
            secondary: const Color(0xFF3B82F6),
          ),
          textTheme: GoogleFonts.outfitTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
