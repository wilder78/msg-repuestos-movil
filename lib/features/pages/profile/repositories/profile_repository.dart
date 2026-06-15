// lib/features/pages/profile/repositories/profile_repository.dart

import 'package:dio/dio.dart';
import '../../../../config/dio_config.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  Future<({String role, List<String> permisos, ProfileModel profile})> getProfile() async {
    try {
      final response = await DioConfig.dio.get<Map<String, dynamic>>('api/users/profile');
      final body = response.data ?? {};
      final status = body['status'] as String?;
      
      if (status != 'success') {
        throw Exception(body['error'] ?? 'Error al obtener perfil');
      }

      final role = body['role'] as String? ?? 'cliente';
      final permisos = List<String>.from(body['permisos'] as List? ?? []);
      final profileData = body['data'] as Map<String, dynamic>? ?? {};

      return (
        role: role,
        permisos: permisos,
        profile: ProfileModel.fromJson(profileData),
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final msg = responseData is Map ? (responseData['error'] ?? responseData['message']) : null;
      
      if (statusCode == 401) {
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else {
        throw Exception(msg ?? 'Error inesperado al obtener perfil: HTTP $statusCode');
      }
    }
  }

  Future<void> updateProfile({
    required String nombre,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final response = await DioConfig.dio.put<Map<String, dynamic>>(
        'api/users/profile',
        data: {
          'nombre': nombre,
          'telefono': telefono,
          'direccion': direccion,
        },
      );

      final body = response.data ?? {};
      final status = body['status'] as String?;

      if (status != 'success') {
        throw Exception(body['error'] ?? 'Error al actualizar perfil');
      }
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      final msg = responseData is Map ? (responseData['error'] ?? responseData['message']) : null;

      if (statusCode == 401) {
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else {
        throw Exception(msg ?? 'Error inesperado al actualizar perfil: HTTP $statusCode');
      }
    }
  }
}
