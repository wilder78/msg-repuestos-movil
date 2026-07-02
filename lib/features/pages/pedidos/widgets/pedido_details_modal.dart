import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pedido_model.dart';

class PedidoDetailsModal extends StatelessWidget {
  final PedidoModel pedido;

  const PedidoDetailsModal({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final DateTime? fechaObj = DateTime.tryParse(pedido.fechaPedido);
    final String fechaStr = fechaObj != null ? dateFmt.format(fechaObj) : pedido.fechaPedido;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.idPedido}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaStr,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
                _buildStatusBadge(pedido.idEstadoPedido, pedido.estadoDespacho),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            const Text('Resumen del Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pedido.detalles.length,
                itemBuilder: (context, index) {
                  final detalle = pedido.detalles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            image: (detalle.producto?.imagenUrl != null && detalle.producto!.imagenUrl.isNotEmpty) 
                              ? DecorationImage(image: NetworkImage(detalle.producto!.imagenUrl), fit: BoxFit.cover)
                              : null,
                          ),
                          child: (detalle.producto?.imagenUrl == null || detalle.producto!.imagenUrl.isEmpty)
                            ? const Icon(Icons.image_not_supported, color: Color(0xFFCBD5E1), size: 20)
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(detalle.producto?.nombreOriginal ?? 'Producto desconocido', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                              Text('Cantidad: ${detalle.cantidadSolicitada}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(currencyFmt.format(detalle.subtotalLinea), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            _buildInfoRow('Tipo de Pago', pedido.tipoPago),
            const SizedBox(height: 8),
            _buildInfoRow('Subtotal Base', currencyFmt.format(pedido.totalNeto / 1.19)),
            const SizedBox(height: 8),
            _buildInfoRow('IVA (19%)', currencyFmt.format(pedido.totalNeto - (pedido.totalNeto / 1.19))),
            const SizedBox(height: 8),
            _buildInfoRow('Descuento (0%)', '- ${currencyFmt.format(pedido.descuentos)}', color: const Color(0xFF10B981)),
            const SizedBox(height: 16),
            _buildInfoRow('Total Neto', currencyFmt.format(pedido.totalNeto), isTotal: true),
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
    );
  }

  Widget _buildStatusBadge(int statusId, String label) {
    Color color;
    switch(statusId) {
      case 1: color = const Color(0xFF6366F1); break; // Indigo - Cotización
      case 2: color = const Color(0xFFF59E0B); break; // Amber - Separación
      case 3: color = const Color(0xFFEF4444); break; // Red - Cancelado
      case 4: color = const Color(0xFF10B981); break; // Emerald - Entregado
      case 5: color = const Color(0xFF0EA5E9); break; // Sky - Pagado
      default: color = const Color(0xFF64748B); // Slate
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 15, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF64748B))),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 15, fontWeight: FontWeight.bold, color: color ?? (isTotal ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B)))),
      ],
    );
  }
}
