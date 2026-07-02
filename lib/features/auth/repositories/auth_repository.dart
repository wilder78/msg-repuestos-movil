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
        'api/users/login?source=app',
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data ?? {};
      final token = body['token']?.toString();
      final userMap = body['user'] as Map<String, dynamic>?;

      if (token == null || userMap == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      return (token: token, user: UserModel.fromJson(userMap));
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final requestPath = error.requestOptions.path;
      final baseUrl = error.requestOptions.baseUrl;
      
      if (statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else if (statusCode == 403) {
        final msg = responseData is Map ? (responseData['message'] ?? responseData['error']) : 'Tu cuenta no ha sido activada. Se ha enviado un nuevo enlace de activación a tu correo electrónico.';
        throw Exception(msg);
      } else if (statusCode == 404) {
        throw Exception('Error 404: Ruta no encontrada en el servidor ($baseUrl$requestPath)');
      } else if (statusCode == null) {
        throw Exception('Sin conexión con el servidor: ${error.message}');
      } else {
        throw Exception('Error inesperado: HTTP $statusCode - $responseData');
      }
    }
  }

  Future<void> register({
    required String nombreUsuario,
    required String email,
    required String password,
    required String razonSocial,
    required String numeroDocumento,
    required int idTipoDocumento,
    required String direccion,
    required String telefono,
    required int municipioId,
    String? personaContacto,
  }) async {
    try {
      // 1. Register User
      await DioConfig.dio.post<Map<String, dynamic>>(
        'api/users/register?source=app',
        data: {
          'nombreUsuario': nombreUsuario,
          'email': email,
          'password': password,
        },
      );

      // 2. Register Customer (linking via email)
      await DioConfig.dio.post<Map<String, dynamic>>(
        'api/customers',
        data: {
          'idTipoDocumento': idTipoDocumento,
          'numeroDocumento': numeroDocumento,
          'razonSocial': razonSocial,
          'direccion': direccion,
          'telefono': telefono,
          'email': email,
          'tipoCliente': 'Consumidor final',
          'municipioId': municipioId,
          'activo': 1,
          'personaContacto': personaContacto ?? razonSocial, // Fallback to razonSocial if null
        },
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final requestPath = error.requestOptions.path;
      final baseUrl = error.requestOptions.baseUrl;



      
      if (statusCode == 400 || statusCode == 409) {
        final msg = data is Map ? (data['message'] ?? data['error']) : 'El correo ya está registrado o los datos son inválidos';
        throw Exception(msg);
      } else if (statusCode == 404) {
        throw Exception('Error 404: Ruta no encontrada en el servidor ($baseUrl$requestPath)');
      } else if (statusCode == null) {
        throw Exception('Sin conexión con el servidor: ${error.message}');
      } else {
        throw Exception('Error inesperado: HTTP $statusCode - $data');
      }
    }
  }
}