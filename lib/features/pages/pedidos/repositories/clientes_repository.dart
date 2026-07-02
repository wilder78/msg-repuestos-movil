// lib/features/pages/pedidos/repositories/clientes_repository.dart

import 'package:dio/dio.dart';
import '../../../../config/dio_config.dart';
import '../models/pedido_model.dart'; // Reutilizamos ClienteModel definido aquí

class ClientesRepository {
  Future<List<ClienteModel>> getClientes() async {
    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/clientes');
      return response.data?.map((json) => ClienteModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final msg = responseData is Map ? (responseData['message'] ?? responseData['error']) : null;
      throw Exception(msg ?? 'Error al obtener lista de clientes');
    }
  }

  Future<List<ClienteModel>> searchClientes(String query) async {
    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/clientes/search?q=$query');
      return response.data?.map((json) => ClienteModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final msg = responseData is Map ? (responseData['message'] ?? responseData['error']) : null;
      throw Exception(msg ?? 'Error al buscar clientes');
    }
  }
}
