// lib/features/auth/repositories/auth_repository.dart

import 'package:dio/dio.dart';

import '../../../config/dio_config.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>(
        'api/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data ?? {};
      final token = body['token']?.toString();
      final userMap = body['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        throw Exception('El servidor no retornó un token válido');
      }

      if (userMap == null) {
        throw Exception('El servidor no retornó los datos del usuario');
      }

      final user = UserModel.fromJson(userMap);

      return (token: token, user: user);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else if (statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (statusCode == null) {
        throw Exception('Sin conexión con el servidor');
      } else {
        throw Exception('Error inesperado: HTTP $statusCode');
      }
    }
  }

  Future<void> register({
    required String nombreUsuario,
    required String email,
    required String password,
  }) async {
    try {
      await DioConfig.dio.post<Map<String, dynamic>>(
        'api/users/register',
        data: {
          'nombreUsuario': nombreUsuario,
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      
      if (statusCode == 400 || statusCode == 409) {
        // Asumiendo que el backend envía un mensaje de error
        final msg = data is Map ? data['message'] : 'El correo ya está registrado o los datos son inválidos';
        throw Exception(msg);
      } else if (statusCode == null) {
        throw Exception('Sin conexión con el servidor');
      } else {
        throw Exception('Error inesperado: HTTP $statusCode');
      }
    }
  }
}