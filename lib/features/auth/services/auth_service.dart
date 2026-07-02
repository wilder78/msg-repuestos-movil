// lib/features/auth/services/auth_service.dart

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('El email y la contraseña son obligatorios');
    }

    if (!email.contains('@')) {
      throw Exception('El email no es válido');
    }

    final result = await _repository.login(
      email: email.trim(),
      password: password,
    );

    if (!result.user.hasAppAccess) {
      throw Exception(
        'El rol "${result.user.rolNombre}" no tiene acceso a la aplicación',
      );
    }

    return result;
  }

  Future<void> register({
    required String nombreUsuario,
    required String email,
    required String password,
    // Billing info
    required String razonSocial,
    required String numeroDocumento,
    required int idTipoDocumento,
    required String direccion,
    required String telefono,
    required int municipioId,
    String? personaContacto, // Optional field from UI
  }) async {
    if (nombreUsuario.isEmpty || email.isEmpty || password.isEmpty || 
        razonSocial.isEmpty || numeroDocumento.isEmpty || direccion.isEmpty || telefono.isEmpty) {
      throw Exception('Todos los campos son obligatorios');
    }

    if (!email.contains('@')) {
      throw Exception('El email no es válido');
    }

    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    await _repository.register(
      nombreUsuario: nombreUsuario.trim(),
      email: email.trim(),
      password: password,
      razonSocial: razonSocial.trim(),
      numeroDocumento: numeroDocumento.trim(),
      idTipoDocumento: idTipoDocumento,
      direccion: direccion.trim(),
      telefono: telefono.trim(),
      municipioId: municipioId,
      personaContacto: personaContacto?.trim(),
    );
  }
}