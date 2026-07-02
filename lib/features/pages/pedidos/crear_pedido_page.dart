// lib/features/pages/pedidos/crear_pedido_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import '../../auth/models/user_model.dart';
import '../productos/models/producto_model.dart';
import '../productos/repositories/productos_repository.dart';
import 'models/pedido_model.dart';
import 'repositories/clientes_repository.dart';
import 'repositories/pedidos_repository.dart';

class CrearPedidoPage extends StatefulWidget {
  final UserModel user;
  const CrearPedidoPage({super.key, required this.user});

  @override
  State<CrearPedidoPage> createState() => _CrearPedidoPageState();
}

class _CrearPedidoPageState extends State<CrearPedidoPage> {
  final _clientesRepo = ClientesRepository();
  final _productosRepo = ProductosRepository();
  final _pedidosRepo = PedidosRepository();
  final _currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  ClienteModel? _selectedCliente;
  final List<Map<String, dynamic>> _selectedItems = []; // {producto: ProductoModel, cantidad: int}
  String _tipoPago = 'Efectivo';
  final _notasController = TextEditingController();
  String _searchAddedQuery = '';

  double get _subtotal => _selectedItems.fold(0, (sum, item) {
        final p = item['producto'] as ProductoModel;
        return sum + (p.precioPublico * item['cantidad']);
      });

  List<Map<String, dynamic>> get _filteredAddedItems => _selectedItems.where((item) {
        final p = item['producto'] as ProductoModel;
        final q = _searchAddedQuery.toLowerCase();
        return p.nombreOriginal.toLowerCase().contains(q) || 
               p.referencia.toLowerCase().contains(q);
      }).toList();

  bool get _canSubmit => _selectedCliente != null && _selectedItems.isNotEmpty && !_isSaving;

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Nuevo Pedido', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECCIÓN CLIENTE
                  _buildSectionHeader('Datos del Cliente', Icons.person_add_alt_1),
                  _buildClienteSelector(),
                  const SizedBox(height: 24),

                  // SECCIÓN PRODUCTOS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Productos (${_selectedItems.length})', Icons.shopping_bag_outlined),
                      TextButton.icon(
                        onPressed: _showProductSelector,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Añadir'),
                      ),
                    ],
                  ),
                  
                  if (_selectedItems.isNotEmpty) ...[
                    // Buscador interno para productos ya agregados
                    TextField(
                      onChanged: (val) => setState(() => _searchAddedQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Filtrar entre los ${_selectedItems.length} agregados...',
                        prefixIcon: const Icon(Icons.filter_list, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildProductsList(),
                  const SizedBox(height: 24),

                  // SECCIÓN PAGO Y NOTAS
                  _buildSectionHeader('Detalles de Venta', Icons.payments_outlined),
                  _buildPaymentAndNotes(),
                  const SizedBox(height: 24),

                  // RESUMEN
                  _buildSummaryCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // BOTÓN FIJO AL FINAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildClienteSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: _selectedCliente == null
          ? ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.search, color: Color(0xFF3B82F6))),
              title: const Text('Seleccionar Cliente', style: TextStyle(color: Color(0xFF64748B))),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClienteSearch,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedCliente!.razonSocial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                    IconButton(onPressed: () => setState(() => _selectedCliente = null), icon: const Icon(Icons.edit, size: 18, color: Colors.grey)),
                  ],
                ),
                Text('NIT/CC: ${_selectedCliente!.numeroDocumento}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                Text('Dir: ${_selectedCliente!.direccion}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
    );
  }

  bool _isSaving = false;

  Widget _buildProductsList() {
    if (_selectedItems.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
        ),
        child: const Center(child: Text('No hay productos añadidos', style: TextStyle(color: Colors.black26))),
      );
    }

    final items = _filteredAddedItems;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final p = item['producto'] as ProductoModel;
              final realIndex = _selectedItems.indexOf(item);
        
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nombreOriginal, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(p.referencia, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          Text(_currencyFmt.format(p.precioPublico), style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         IconButton(onPressed: () => _updateQty(realIndex, -1), icon: const Icon(Icons.remove_circle, size: 22, color: Colors.redAccent)),
                         Text('${item['cantidad']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                         IconButton(onPressed: () => _updateQty(realIndex, 1), icon: const Icon(Icons.add_circle, size: 22, color: Colors.green)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAndNotes() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoPago,
              isExpanded: true,
              items: ['Efectivo', 'Transferencia', 'Crédito', 'Tarjeta'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _tipoPago = val!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notasController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Notas adicionales o instrucciones de entrega...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', _currencyFmt.format(_subtotal), Colors.white70),
          _summaryRow('IVA (19%)', _currencyFmt.format(_subtotal * 0.19), Colors.white70),
          const Divider(color: Colors.white24, height: 24),
          _summaryRow('TOTAL A PAGAR', _currencyFmt.format(_subtotal * 1.19), Colors.white, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: color, fontSize: isTotal ? 20 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _canSubmit;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: canSubmit 
            ? [const Color(0xFF3B82F6), const Color(0xFF1E3A8A)]
            : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        boxShadow: canSubmit ? [
          BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? _savePedido : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                canSubmit ? 'CONFIRMAR PEDIDO' : 'FALTA CLIENTE O PRODUCTOS',
                style: TextStyle(
                  color: canSubmit ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: canSubmit ? 16 : 13,
                  letterSpacing: 1.1,
                ),
              ),
      ),
    );
  }

  // --- LÓGICA ---

  void _updateQty(int index, int delta) {
    final item = _selectedItems[index];
    final producto = item['producto'] as ProductoModel;
    final currentQty = item['cantidad'] as int;
    final int newQty = currentQty + delta;

    if (newQty > producto.stockBuenEstado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay más stock disponible (${producto.stockBuenEstado} máx.)'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      if (newQty <= 0) {
        _selectedItems.removeAt(index);
      } else {
        _selectedItems[index]['cantidad'] = newQty;
      }
    });
  }

  void _showClienteSearch() async {
    final List<ClienteModel> todosLosClientes = await _clientesRepo.getClientes();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          List<ClienteModel> filtrados = todosLosClientes;

          void filter(String val) {
            setModalState(() {
              filtrados = todosLosClientes.where((c) => 
                c.razonSocial.toLowerCase().contains(val.toLowerCase()) || 
                c.numeroDocumento.contains(val)).toList();
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text('Seleccionar Cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  onChanged: filter,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o NIT...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtrados.isEmpty 
                    ? const Center(child: Text('No se encontraron clientes', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (context, i) => ListTile(
                          title: Text(filtrados[i].razonSocial, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('ID: ${filtrados[i].numeroDocumento}'),
                          onTap: () {
                            setState(() => _selectedCliente = filtrados[i]);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showProductSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          List<ProductoModel> filtrados = [];
          List<ProductoModel> todos = [];
          bool loadingLocal = true;

          void load() async {
            try {
              final data = await _productosRepo.getProductos();
              if (context.mounted) {
                setModalState(() {
                  todos = data;
                  filtrados = data;
                  loadingLocal = false;
                });
              }
            } catch (e) {
              if (context.mounted) setModalState(() => loadingLocal = false);
            }
          }

          if (loadingLocal && todos.isEmpty) load();

          void filter(String val) {
            setModalState(() {
              final q = val.toLowerCase();
              filtrados = todos.where((p) => 
                p.nombreOriginal.toLowerCase().contains(q) || 
                p.marca.toLowerCase().contains(q) ||
                p.referencia.toLowerCase().contains(q)).toList();
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text('Añadir Producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  onChanged: filter,
                  decoration: InputDecoration(
                    hintText: 'Nombre, marca o referencia...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: loadingLocal 
                    ? _buildShimmerList()
                    : filtrados.isEmpty 
                      ? const Center(child: Text('No hay productos que coincidan', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: filtrados.length,
                          itemBuilder: (context, i) {
                            final p = filtrados[i];
                            final bool hasStock = p.stockBuenEstado > 0;

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), 
                                side: BorderSide(color: hasStock ? const Color(0xFFF1F5F9) : Colors.red.withValues(alpha: 0.2))
                              ),
                              child: Opacity(
                                opacity: hasStock ? 1.0 : 0.6,
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: p.imagenUrl.isNotEmpty 
                                      ? Image.network(p.imagenUrl, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 44, height: 44, color: Colors.grey[200], child: const Icon(Icons.error_outline, size: 20)))
                                      : Container(width: 44, height: 44, color: const Color(0xFFF1F5F9), child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
                                  ),
                                  title: Text(p.nombreOriginal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${p.marca} - ${_currencyFmt.format(p.precioPublico)}', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w500)),
                                      Text(
                                        hasStock ? 'Stock: ${p.stockBuenEstado} unidades' : 'AGOTADO / SIN STOCK',
                                        style: TextStyle(color: hasStock ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    hasStock ? Icons.add_circle_outline : Icons.block, 
                                    color: hasStock ? const Color(0xFF3B82F6) : Colors.red
                                  ),
                                  onTap: hasStock ? () {
                                    setState(() {
                                      _selectedItems.add({'producto': p, 'cantidad': 1});
                                    });
                                    Navigator.pop(context);
                                  } : null
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _savePedido() async {
    setState(() => _isSaving = true);
    try {
      final orderData = {
        'id_cliente': _selectedCliente!.idCliente,
        'id_vendedor': widget.user.idUsuario,
        'id_origen_pedido': 2, // 2 = Mobile
        'tipo_pago': _tipoPago,
        'notas': _notasController.text,
        'detalles': _selectedItems.map((item) {
          final p = item['producto'] as ProductoModel;
          return {
            'id_producto': p.idProducto,
            'cantidad_solicitada': item['cantidad'],
            'precio_venta': p.precioPublico,
          };
        }).toList(),
      };

      await _pedidosRepo.createPedido(orderData);
      
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_awSQu9.json', // Check animado
              width: 150,
              height: 150,
              repeat: false,
              errorBuilder: (c, e, s) => const Icon(Icons.check_circle, color: Colors.green, size: 100),
            ),
            const SizedBox(height: 16),
            const Text('¡Pedido Creado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 8),
            const Text('El pedido se ha registrado correctamente en el sistema.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar Dialog
                  Navigator.pop(context, true); // Regresar a la lista
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('ENTENDIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 70,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
