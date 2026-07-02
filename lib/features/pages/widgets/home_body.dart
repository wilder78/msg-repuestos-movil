import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../cart/providers/cart_provider.dart';
import '../productos/models/producto_model.dart';
import '../productos/repositories/productos_repository.dart';

// Datos estáticos copiados del frontend

final List<Map<String, dynamic>> _marcas = [
  {"id": 1, "name": "Honda", "logo": "https://upload.wikimedia.org/wikipedia/commons/3/38/Honda.svg"},
  {"id": 2, "name": "Yamaha", "logo": "https://upload.wikimedia.org/wikipedia/commons/e/e9/Yamaha_logo.svg"},
  {"id": 3, "name": "Suzuki", "logo": "https://upload.wikimedia.org/wikipedia/commons/1/12/Suzuki_logo_2.svg"},
  {"id": 4, "name": "Kawasaki", "logo": "https://upload.wikimedia.org/wikipedia/commons/3/3f/Kawasaki_logo.svg"},
  {"id": 5, "name": "Bajaj", "logo": "https://upload.wikimedia.org/wikipedia/commons/b/b8/Bajaj_Auto_Logo.svg"},
  {"id": 6, "name": "Motul", "logo": "https://upload.wikimedia.org/wikipedia/commons/8/87/Motul_logo.svg"},
];

class HomeBody extends StatefulWidget {
  const HomeBody({super.key, required this.onTestConnection});

  final VoidCallback onTestConnection;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final ProductosRepository _repository = ProductosRepository();
  List<ProductoModel> _nuevosIngresos = [];
  List<ProductoModel> _masVendidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    try {
      final allProducts = await _repository.getProductos();
      
      // Simulación de lógica de negocio (normalmente esto vendría ordenado del backend)
      // Nuevos Ingresos: Los últimos 8 por ID descendente
      final sortedNew = List<ProductoModel>.from(allProducts)
        ..sort((a, b) => b.idProducto.compareTo(a.idProducto));
      
      // Más Vendidos: Simulado si no hay métrica de ventas (tomamos una muestra diferente)
      final sortedSold = List<ProductoModel>.from(allProducts)
        ..sort((a, b) => b.stockBuenEstado.compareTo(a.stockBuenEstado)); // Simulado con stock o aleatorio por ahora

      if (mounted) {
        setState(() {
          _nuevosIngresos = sortedNew.take(8).toList();
          _masVendidos = sortedSold.take(8).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silently fail or log
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // slate-50
      child: RefreshIndicator(
        onRefresh: _loadHomeData,
        color: const Color(0xFF3B82F6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHero(context),
            const SizedBox(height: 48),
            _buildSectionTitle('🆕', 'Nuevos Ingresos'),
            _buildProductCarousel(_nuevosIngresos),
            const SizedBox(height: 40),
            _buildSectionTitle('🏆', 'Productos más vendidos'),
            _buildProductCarousel(_masVendidos),
            const SizedBox(height: 40),
            _buildBrandsSection(),
            const SizedBox(height: 40),
            TextButton(
              onPressed: widget.onTestConnection,
              child: const Text('Test Connection (Debug)', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], // slate-900 to blue-900
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
              children: [
                TextSpan(text: 'Bienvenido a\n'),
                TextSpan(text: 'tu mundo biker', style: TextStyle(color: Color(0xFF60A5FA))), // blue-400
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encuentra los mejores repuestos para tu moto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20, 
              color: Colors.white, 
              fontWeight: FontWeight.w800, // Más negrita
              letterSpacing: 0.5,
              shadows: [
                Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Simular clic a repuestos. Idealmente navegaríamos aquí, 
              // pero como estamos en Shell, solo informamos.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegando a catálogo...')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6), // blue-500
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Ver Catálogo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title, {bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          if (showViewAll)
            const Text('Ver todas', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductCarousel(List<ProductoModel> items) {
    if (_isLoading) {
      return const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Cargando productos...', style: TextStyle(color: Colors.grey))),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = items[index];
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: p.imagenUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(p.imagenUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: p.imagenUrl.isEmpty
                            ? const Center(child: Icon(Icons.image_not_supported, color: Color(0xFFE2E8F0), size: 48))
                            : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.nombreOriginal, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0).format(p.precioPublico), 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2563EB))
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final provider = Provider.of<CartProvider>(context, listen: false);
                                  provider.addItem(CartItemModel(
                                    idProducto: p.idProducto,
                                    nombre: p.nombreOriginal,
                                    precio: p.precioPublico.toDouble(),
                                    imagenUrl: p.imagenUrl,
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añadido al Carrito'), duration: Duration(seconds: 1)));
                                },
                                icon: const Icon(Icons.shopping_cart, size: 16, color: Colors.white),
                                label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text('Marcas que Comercializamos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Repuestos y accesorios para motos de las mejores marcas del mercado.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _marcas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 32),
              itemBuilder: (context, index) {
                final m = _marcas[index];
                return Column(
                  children: [
                    // A placeholder icon when network image fails to load inline (e.g SVG)
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(m['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF64748B))),
                    ),
                    const SizedBox(height: 8),
                    Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)))
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}