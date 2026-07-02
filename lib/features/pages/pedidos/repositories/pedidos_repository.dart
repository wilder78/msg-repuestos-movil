// lib/features/pages/pedidos/repositories/pedidos_repository.dart

import 'package:dio/dio.dart';
import '../../../../config/dio_config.dart';
import '../models/pedido_model.dart';

class PedidosRepository {
  Future<List<PedidoModel>> getPedidos() async {
    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/orders');
      return response.data?.map((json) => PedidoModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        // Fallback for customer/seller to get their history instead of all
        return await getHistoryMe();
      }
      _handleError(error, 'obtener pedidos');
      return [];
    }
  }

  Future<List<PedidoModel>> getHistoryMe() async {
    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/orders/history/me');
      return response.data?.map((json) => PedidoModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      _handleError(error, 'obtener historial de pedidos');
      return [];
    }
  }

  Future<PedidoModel> getPedidoById(int id) async {
    try {
      final response = await DioConfig.dio.get<Map<String, dynamic>>('api/orders/$id');
      return PedidoModel.fromJson(response.data!);
    } on DioException catch (error) {
      _handleError(error, 'obtener pedido');
      throw Exception('Error genérico');
    }
  }

  Future<PedidoModel> createPedido(Map<String, dynamic> data) async {
    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>('api/orders', data: data);
      final body = response.data ?? {};
      if (body['success'] == false) throw Exception(body['message'] ?? 'Error al crear pedido');
      return PedidoModel.fromJson(body['data']);
    } on DioException catch (error) {
      _handleError(error, 'crear pedido');
      throw Exception('Error genérico');
    }
  }

  Future<PedidoModel> updatePedido(int id, Map<String, dynamic> data) async {
    try {
      final response = await DioConfig.dio.put<Map<String, dynamic>>('api/orders/$id', data: data);
      final body = response.data ?? {};
      if (body['success'] == false) throw Exception(body['message'] ?? 'Error al actualizar pedido');
      return PedidoModel.fromJson(body['data'] ?? body);
    } on DioException catch (error) {
      _handleError(error, 'actualizar pedido');
      throw Exception('Error genérico');
    }
  }

  Future<void> anularPedido(int id) async {
    // Para anular, cambiamos el estado a 3 = Cancelado
    return await updatePedido(id, {'id_estado_pedido': 3}).then((_) => null);
  }

  void _handleError(DioException error, String action) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    final msg = responseData is Map ? (responseData['message'] ?? responseData['error']) : null;
    
    if (statusCode == 401) {
      throw Exception('Sesión expirada. Inicie sesión nuevamente.');
    } else {
      throw Exception(msg ?? 'Error inesperado al $action: HTTP $statusCode');
    }
  }
}
