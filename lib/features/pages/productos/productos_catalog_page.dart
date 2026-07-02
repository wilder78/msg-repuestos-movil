// lib/features/pages/productos/productos_catalog_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../cart/providers/cart_provider.dart';
import 'models/producto_model.dart';
import 'repositories/productos_repository.dart';

class ProductosCatalogPage extends StatefulWidget {
  const ProductosCatalogPage({super.key});

  @override
  State<ProductosCatalogPage> createState() => _ProductosCatalogPageState();
}

class _ProductosCatalogPageState extends State<ProductosCatalogPage> {
  final ProductosRepository _repository = ProductosRepository();
  final NumberFormat _currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  List<ProductoModel> _productos = [];
  List<ProductoModel> _filteredProductos = [];
  List<CategoriaModel> _categorias = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryId = 0; // 0 significa 'Todas'
  String _searchQuery = '';
  
  final ScrollController _scrollController = ScrollController();
  int _visibleItemsCount = 8; // Máximo 8 por página al inicio

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_visibleItemsCount < _filteredProductos.length) {
        setState(() {
          _visibleItemsCount += 8;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _repository.getProductos(),
        _repository.getCategorias(),
      ]);

      final allProductos = (futures[0] as List<ProductoModel>).where((p) => p.idEstado == 1).toList(); // Solo activos
      final allCats = futures[1] as List<CategoriaModel>;

      setState(() {
        _productos = allProductos;
        _filteredProductos = allProductos;
        _categorias = [CategoriaModel(idCategoria: 0, nombreCategoria: 'Todas'), ...allCats];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterData({int? categoryId, String? query}) {
    if (categoryId != null) _selectedCategoryId = categoryId;
    if (query != null) _searchQuery = query;

    setState(() {
      _visibleItemsCount = 8; // Resetear la paginación al cambiar filtros
      _filteredProductos = _productos.where((p) {
        final matchCat = _selectedCategoryId == 0 || p.idCategoria == _selectedCategoryId;
        final lowerQuery = _searchQuery.toLowerCase();
        final matchSearch = p.nombreOriginal.toLowerCase().contains(lowerQuery) ||
                            p.marca.toLowerCase().contains(lowerQuery) ||
                            p.referencia.toLowerCase().contains(lowerQuery);
        return matchCat && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      appBar: AppBar(
        title: const Text(
          'Catálogo de Productos',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF3B82F6),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => _filterData(query: val),
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
          ),
          
          // Categorías Horizontal Scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final isSelected = _selectedCategoryId == cat.idCategoria;
                  
                  return ChoiceChip(
                    label: Text(cat.nombreCategoria),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _filterData(categoryId: cat.idCategoria);
                    },
                    selectedColor: const Color(0xFF3B82F6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Grid de Productos
          if (_filteredProductos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.inventory_2_outlined, size: 60, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 16),
                    Text('No se encontraron productos', style: TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = _filteredProductos[index];
                    return _buildProductCard(p);
                  },
                  childCount: _filteredProductos.length < _visibleItemsCount 
                      ? _filteredProductos.length 
                      : _visibleItemsCount,
                ),
              ),
            ),
            
          if (_visibleItemsCount < _filteredProductos.length)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductoModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8), // slate-200
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen y descuento simulado
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // slate-100
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: product.imagenUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.imagenUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imagenUrl.isEmpty
                      ? const Center(child: Icon(Icons.image_not_supported, color: Color(0xFFCBD5E1), size: 40))
                      : null,
                ),
                if (product.stockBuenEstado == 0) // Agotado
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Agotado', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),
          ),
          
          // Información del producto
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.marca,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.nombreOriginal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                         _currencyFmt.format(product.precioPublico),
                        style: const TextStyle(
                          color: Color(0xFF3B82F6), // Azul Bonito
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: product.stockBuenEstado > 0 ? () {
                            Provider.of<CartProvider>(context, listen: false).addItem(CartItemModel(
                              idProducto: product.idProducto,
                              nombre: product.nombreOriginal,
                              precio: product.precioPublico.toDouble(),
                              imagenUrl: product.imagenUrl,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Añadido al carrito')),
                            );
                          } : null,
                          icon: const Icon(Icons.shopping_cart, size: 16, color: Colors.white),
                          label: const Text('Agregar', style: TextStyle(fontSize: 12, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A), // Boton azul
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
