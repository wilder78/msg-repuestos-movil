// lib/features/auth/login_page.dart

import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'register_page.dart';
import 'password_recovery_page.dart';
import '../shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  String? _emailError;

  bool get _canLogin => _emailController.text.isNotEmpty && 
                        _passwordController.text.isNotEmpty && 
                        _emailError == null;

  void _validateEmail(String val) {
    setState(() {
      if (val.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
        _emailError = 'Correo electrónico no válido';
      } else {
        _emailError = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result.token);
      await prefs.setString('auth_user', jsonEncode(result.user.toJson()));

      // Persistencia de "Recuérdame"
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      _navigateToHome(result.user);
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(UserModel user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ShellPage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con Gradiente Abstracto
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11244D), Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Círculos abstractos decorativos (opcional para dar profundidad)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const _Logo(),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 6,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '¡Bienvenido!',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF11244D),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Inicia sesión para continuar',
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                                    ),
                                    const SizedBox(height: 32),
                                    const _InputLabel('Correo electrónico'),
                                    const SizedBox(height: 10),
                                    _InputField(
                                      controller: _emailController,
                                      hint: 'ejemplo@correo.com',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      errorText: _emailError,
                                      onChanged: _validateEmail,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const _InputLabel('Contraseña'),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => const PasswordRecoveryPage(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            '¿Olvidaste tu contraseña?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3B82F6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _PasswordField(
                                      controller: _passwordController,
                                      hint: '••••••••',
                                      obscureText: _obscurePassword,
                                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                      onChanged: (_) => setState(() {}), // Para actualizar _canLogin
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            activeColor: const Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Recordarme en este dispositivo',
                                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    if (_errorMessage != null) _ErrorMessage(message: _errorMessage!),
                                    _LoginButton(
                                      isLoading: _isLoading, 
                                      onPressed: _canLogin ? () => _login() : null
                                    ),
                                    const SizedBox(height: 32),
                                    Center(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                                          children: [
                                            const TextSpan(text: '¿Aún no tienes cuenta? '),
                                            TextSpan(
                                              text: 'Crea una aquí',
                                              style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                                                  );
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Botón oculto para Dev
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () {
                          const adminUser = UserModel(
                            idUsuario: 999,
                            nombreUsuario: 'Admin Dev',
                            email: 'admin@dev.local',
                            idEstado: 1,
                            fechaCreacion: '',
                            idRol: 1,
                            idCliente: null,
                          );
                          _navigateToHome(adminUser);
                        },
                        icon: const Icon(Icons.developer_mode, color: Colors.white60, size: 16),
                        label: const Text(
                          'MODO DESARROLLADOR',
                          style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ⬇️ Widgets auxiliares

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'assets/images/logocuadrado.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bienvenido a tu mundo biker',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Encuentra los mejores repuestos para tu moto',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.black54),
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            errorText: errorText,
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscureText,
    required this.onToggle,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF64748B),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Entrar al Sistema',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
