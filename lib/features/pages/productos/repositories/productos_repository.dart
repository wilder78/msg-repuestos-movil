// lib/features/pages/productos/repositories/productos_repository.dart

import 'package:dio/dio.dart';
import '../../../../config/dio_config.dart';
import '../models/producto_model.dart';

class ProductosRepository {
  Future<List<ProductoModel>> getProductos() async {
    try {
      final response = await DioConfig.dio.get<Map<String, dynamic>>('api/products?limit=500');
      final data = response.data?['products'] as List<dynamic>?;
      return data?.map((json) => ProductoModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      _handleError(error, 'obtener productos');
      return [];
    }
  }

  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/categories');
      return response.data?.map((json) => CategoriaModel.fromJson(json)).toList() ?? [];
    } on DioException catch (error) {
      _handleError(error, 'obtener categorias');
      return [];
    }
  }

  Future<ProductoModel> getProductoById(int id) async {
    try {
      final response = await DioConfig.dio.get<Map<String, dynamic>>('api/products/$id');
      return ProductoModel.fromJson(response.data!);
    } on DioException catch (error) {
      _handleError(error, 'obtener producto');
      throw Exception('Error genérico');
    }
  }

  Future<ProductoModel> createProducto(Map<String, dynamic> data) async {
    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>('api/products', data: data);
      final body = response.data ?? {};
      if (body['status'] != 'success') throw Exception(body['message'] ?? 'Error al crear producto');
      return ProductoModel.fromJson(body['data']);
    } on DioException catch (error) {
      _handleError(error, 'crear producto');
      throw Exception('Error genérico');
    }
  }

  Future<ProductoModel> updateProducto(int id, Map<String, dynamic> data) async {
    try {
      final response = await DioConfig.dio.put<Map<String, dynamic>>('api/products/$id', data: data);
      final body = response.data ?? {};
      if (body['status'] != 'success') throw Exception(body['message'] ?? 'Error al actualizar producto');
      return ProductoModel.fromJson(body['data']);
    } on DioException catch (error) {
      _handleError(error, 'actualizar producto');
      throw Exception('Error genérico');
    }
  }

  Future<void> deleteProducto(int id) async {
    try {
      final response = await DioConfig.dio.delete<Map<String, dynamic>>('api/products/$id');
      final body = response.data ?? {};
      if (body['status'] != 'success') throw Exception(body['message'] ?? 'Error al eliminar producto');
    } on DioException catch (error) {
      _handleError(error, 'eliminar producto');
    }
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
