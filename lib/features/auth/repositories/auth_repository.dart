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
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data!;
      final token = body['token'] as String;
      final user = UserModel.fromJson(body['user'] as Map<String, dynamic>);

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
}