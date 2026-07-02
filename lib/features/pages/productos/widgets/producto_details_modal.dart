import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/producto_model.dart';

class ProductoDetailsModal extends StatelessWidget {
  final ProductoModel producto;

  const ProductoDetailsModal({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      image: (producto.imagenUrl.isNotEmpty) 
                        ? DecorationImage(image: NetworkImage(producto.imagenUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: (producto.imagenUrl.isEmpty)
                      ? const Icon(Icons.image_not_supported, color: Color(0xFFCBD5E1), size: 40)
                      : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ref: ${producto.referencia}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildStockStatus(producto.stockBuenEstado),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Información General'),
              _buildInfoRow('Nombre Original', producto.nombreOriginal),
              _buildInfoRow('Marca/Fabricante', producto.marca),
              _buildInfoRow('Modelo', producto.modelo),
              _buildInfoRow('Categoría', producto.categoria?.nombreCategoria ?? 'General'),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Precios y Costos'),
              _buildPriceItem('Precio Público', currencyFmt.format(producto.precioPublico), Icons.person_outline, const Color(0xFF3B82F6)),
              _buildPriceItem('Precio Mayorista', currencyFmt.format(producto.precioMayorista), Icons.groups_outlined, const Color(0xFF10B981)),
              _buildPriceItem('Precio Minorista', currencyFmt.format(producto.precioMinorista), Icons.store_outlined, const Color(0xFFF59E0B)),
              _buildPriceItem('Costo Compra', currencyFmt.format(producto.precioCompra), Icons.shopping_bag_outlined, const Color(0xFF64748B)),

              const SizedBox(height: 24),
              _buildSectionTitle('Inventario'),
              Row(
                children: [
                  Expanded(
                    child: _buildInventoryBox('Buen Estado', producto.stockBuenEstado.toString(), Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInventoryBox('Defectuoso', producto.stockDefectuoso.toString(), Colors.red),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cerrar Detalle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInventoryBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStockStatus(int stock) {
    final bool isLow = stock < 5;
    final Color color = isLow ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isLow ? 'STOCK BAJO' : 'DISPONIBLE',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
