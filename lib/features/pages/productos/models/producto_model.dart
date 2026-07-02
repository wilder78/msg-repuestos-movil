// lib/features/pages/productos/models/producto_model.dart

class CategoriaModel {
  final int idCategoria;
  final String nombreCategoria;

  CategoriaModel({required this.idCategoria, required this.nombreCategoria});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: int.tryParse(json['id_categoria']?.toString() ?? '0') ?? 0,
      nombreCategoria: json['nombre_categoria'] ?? 'Sin Categoría',
    );
  }
}

class ProductoModel {
  final int idProducto;
  final String referencia;
  final String nombre;
  final String descripcion;
  final String marca;
  final String modelo;
  final String imagenUrl;
  final double precioCompra;
  final double precioPublico;
  final double precioMayorista;
  final double precioMinorista;
  final int stockBuenEstado;
  final int stockDefectuoso;
  final String fechaRegistro;
  final int idCategoria;
  final int idEstado;
  final CategoriaModel? categoria;
  final String nombreOriginal;

  ProductoModel({
    required this.idProducto,
    required this.referencia,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    required this.modelo,
    required this.imagenUrl,
    required this.precioCompra,
    required this.precioPublico,
    required this.precioMayorista,
    required this.precioMinorista,
    required this.stockBuenEstado,
    required this.stockDefectuoso,
    required this.fechaRegistro,
    required this.idCategoria,
    required this.idEstado,
    this.categoria,
    required this.nombreOriginal,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      idProducto: json['id_producto'] is int ? json['id_producto'] : int.tryParse(json['id_producto'].toString()) ?? 0,
      referencia: json['referencia'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      imagenUrl: json['imagen_url'] ?? '',
      precioCompra: double.tryParse(json['precio_compra'].toString()) ?? 0.0,
      precioPublico: double.tryParse(json['precio_publico'].toString()) ?? 0.0,
      precioMayorista: double.tryParse(json['precio_mayorista'].toString()) ?? 0.0,
      precioMinorista: double.tryParse(json['precio_minorista'].toString()) ?? 0.0,
      stockBuenEstado: int.tryParse(json['stock_buen_estado'].toString()) ?? 0,
      stockDefectuoso: int.tryParse(json['stock_defectuoso'].toString()) ?? 0,
      fechaRegistro: json['fecha_registro'] ?? '',
      idCategoria: int.tryParse(json['id_categoria'].toString()) ?? 0,
      idEstado: int.tryParse(json['id_estado'].toString()) ?? 1,
      categoria: json['categoria'] != null ? CategoriaModel.fromJson(json['categoria']) : null,
      nombreOriginal: json['nombre_original'] ?? json['nombre'] ?? '',
    );
  }
}
