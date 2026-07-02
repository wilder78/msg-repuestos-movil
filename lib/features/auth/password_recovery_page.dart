// lib/features/auth/password_recovery_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/dio_config.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  int _step = 1; // 1: Email, 2: Token & Password
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestToken() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo electrónico');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>(
        'api/users/forgot-password',
        data: {'email': email},
      );

      final body = response.data ?? {};
      if (body['status'] == 'success') {
        setState(() {
          _step = 2; // Avanzar al paso del token
          _successMessage = body['message'] ?? 'Código enviado a tu correo.';
        });
      } else {
        throw Exception(body['message'] ?? 'Hubo un error al procesar la solicitud.');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['error']) : null;
      setState(() => _errorMessage = msg ?? 'Error de conexión: HTTP ${e.response?.statusCode}');
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (token.isEmpty || newPassword.isEmpty) {
      setState(() => _errorMessage = 'Completa todos los campos');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>(
        'api/users/reset-password',
        data: {
          'email': email,
          'token': token,
          'newPassword': newPassword,
        },
      );

      final body = response.data ?? {};
      if (body['status'] == 'success') {
        setState(() {
          _successMessage = 'Contraseña actualizada con éxito.';
          _step = 3; // Finalizado
        });
      } else {
        throw Exception(body['message'] ?? 'Código incorrecto o expirado.');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['error']) : null;
      setState(() => _errorMessage = msg ?? 'Error de validación: Verifique el código.');
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
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
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.lock_reset_rounded, size: 48, color: Color(0xFF3B82F6)),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          const Center(
                                            child: Text(
                                              'Recuperar Clave',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF11244D),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Center(
                                            child: Text(
                                              _step == 1 
                                                ? 'Ingresa tu correo para recibir un código de seguridad.'
                                                : _step == 2
                                                  ? 'Ingresa el código enviado y tu nueva contraseña.'
                                                  : '¡Todo listo! Tu contraseña ha sido actualizada.',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                                            ),
                                          ),
                                          const SizedBox(height: 32),

                                          if (_successMessage != null && _step != 3)
                                            _buildSuccessBanner(_successMessage!),
                                          if (_errorMessage != null)
                                            _buildErrorBanner(_errorMessage!),

                                          if (_step == 1) ...[
                                            const Text('Correo electrónico', style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            _buildInputField(
                                              controller: _emailController,
                                              hint: 'ejemplo@correo.com',
                                              icon: Icons.email_outlined,
                                              keyboardType: TextInputType.emailAddress,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                            const SizedBox(height: 32),
                                            _buildActionButton(
                                              label: 'Enviar Código',
                                              onPressed: (_emailController.text.isNotEmpty && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) 
                                                ? _requestToken 
                                                : null,
                                              isLoading: _isLoading,
                                            ),
                                          ],

                                          if (_step == 2) ...[
                                            const Text('Código de seguridad', style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            _buildInputField(
                                              controller: _tokenController,
                                              hint: '1234',
                                              icon: Icons.pin_outlined,
                                              keyboardType: TextInputType.number,
                                              onChanged: (_) => setState(() {}),
                                              maxLength: 4,
                                              textAlign: TextAlign.center,
                                              letterSpacing: 8,
                                            ),
                                            const SizedBox(height: 20),
                                            const Text('Nueva contraseña', style: TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            _buildPasswordField(),
                                            const SizedBox(height: 32),
                                            _buildActionButton(
                                              label: 'Restablecer Clave',
                                              onPressed: (_tokenController.text.length == 4 && _passwordController.text.length >= 6) 
                                                ? _resetPassword 
                                                : null,
                                              isLoading: _isLoading,
                                            ),
                                          ],

                                          if (_step == 3) ...[
                                            const SizedBox(height: 16),
                                            _buildActionButton(
                                              label: 'Volver al Inicio',
                                              onPressed: () => Navigator.pop(context),
                                              isLoading: false,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF15803D), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    double? letterSpacing,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(color: const Color(0xFF1E293B), letterSpacing: letterSpacing, fontWeight: letterSpacing != null ? FontWeight.bold : null),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), letterSpacing: 0),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      onChanged: (_) => setState(() {}),
      obscureText: _obscurePassword,
      style: const TextStyle(color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF64748B), size: 20),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback? onPressed, required bool isLoading}) {
    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.6 : 1.0,
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
            if (onPressed != null) 
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onPressed == null ? Colors.white70 : Colors.white)),
        ),
      ),
    );
  }
}
