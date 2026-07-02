// lib/features/pages/productos/productos_page.dart

import 'package:flutter/material.dart';
import 'models/producto_model.dart';
import 'repositories/productos_repository.dart';
import 'producto_create_modal.dart';
import 'widgets/producto_details_modal.dart';

class ProductosPage extends StatefulWidget {
  final String role; // 'administrador', 'asistente administrativo', 'asistente de bodega'
  
  const ProductosPage({super.key, required this.role});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductosRepository _repository = ProductosRepository();
  List<ProductoModel> _productos = [];
  List<ProductoModel> _filteredProductos = [];
  
  List<CategoriaModel> _categorias = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _repository.getProductos(),
        _repository.getCategorias(),
      ]);
      
      setState(() {
        _productos = futures[0] as List<ProductoModel>;
        _filteredProductos = _productos;
        _categorias = futures[1] as List<CategoriaModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterProductos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProductos = _productos;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredProductos = _productos.where((p) {
          return p.nombre.toLowerCase().contains(lowerQuery) ||
                 p.referencia.toLowerCase().contains(lowerQuery) ||
                 p.marca.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  void _openCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductoCreateModal(
        categorias: _categorias,
        onProductCreated: _loadProductos,
      ),
    );
  }

  void _openDetailsModal(ProductoModel producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProductoDetailsModal(producto: producto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), //slate-50
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)), //slate-900
        title: const Text(
          'Gestión de Productos',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _openCreateModal,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Registrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A63E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProductos,
        color: const Color(0xFF00A63E),
        child: Column(
          children: [
            // Búsqueda
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                onChanged: _filterProductos,
                decoration: InputDecoration(
                  hintText: 'Buscar por referencia, nombre o marca...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)), //slate-400
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)), //slate-500
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9), //slate-100
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00A63E)));
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF475569)), //slate-600
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _loadProductos,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A63E)),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      );
    }

    if (_filteredProductos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFFCBD5E1)), //slate-300
          SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16), //slate-500
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProductos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final prod = _filteredProductos[index];
        final isActive = prod.idEstado == 1;
        
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)), //slate-200
          ),
          child: InkWell(
            onTap: () => _openDetailsModal(prod),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagen miniatura
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), //slate-100
                      borderRadius: BorderRadius.circular(8),
                      image: prod.imagenUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(prod.imagenUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: prod.imagenUrl.isEmpty
                        ? const Icon(Icons.image_not_supported, color: Color(0xFF94A3B8))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Detalles
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.nombreOriginal,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${prod.referencia} • ${prod.marca}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? const Color(0xFFDCFCE7) //green-100
                                    : const Color(0xFFFEE2E2), //red-100
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isActive 
                                      ? const Color(0xFF166534) //green-800
                                      : const Color(0xFF991B1B), //red-800
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Stock: ${prod.stockBuenEstado}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: prod.stockBuenEstado > 5 ? const Color(0xFF475569) : const Color(0xFFEA580C)
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
