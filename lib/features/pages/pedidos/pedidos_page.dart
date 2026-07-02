// lib/features/pages/pedidos/pedidos_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../auth/models/user_model.dart';
import 'crear_pedido_page.dart';
import 'models/pedido_model.dart';
import 'repositories/pedidos_repository.dart';
import 'widgets/pedido_details_modal.dart';

class PedidosPage extends StatefulWidget {
  final UserModel user;
  
  const PedidosPage({super.key, required this.user});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final PedidosRepository _repository = PedidosRepository();
  List<PedidoModel> _pedidos = [];
  List<PedidoModel> _filteredPedidos = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.getHistoryMe();
      setState(() {
        _pedidos = data;
        _filteredPedidos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterPedidos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPedidos = _pedidos;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredPedidos = _pedidos.where((p) {
          final isIdMatch = p.idPedido.toString().contains(lowerQuery);
          final isClientMatch = (p.cliente?.razonSocial ?? '').toLowerCase().contains(lowerQuery);
          return isIdMatch || isClientMatch;
        }).toList();
      }
    });
  }

  void _openCreateModal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearPedidoPage(user: widget.user),
      ),
    );

    if (result == true) {
      _loadPedidos(); // Recargar lista si se creó un pedido
    }
  }

  void _openDetailsModal(PedidoModel pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => PedidoDetailsModal(pedido: pedido),
    );
  }

  Color _getStatusColor(int statusId) {
    switch(statusId) {
      case 1: return const Color(0xFF6366F1); // Indigo - Cotización
      case 2: return const Color(0xFFF59E0B); // Amber - Separación
      case 3: return const Color(0xFFEF4444); // Red - Cancelado
      case 4: return const Color(0xFF10B981); // Emerald - Entregado
      case 5: return const Color(0xFF0EA5E9); // Sky - Pagado
      default: return const Color(0xFF64748B); // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canCreate = widget.user.isVendedor || widget.user.isMaster || widget.user.isCliente;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)), 
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (canCreate)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: _openCreateModal,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Comprar'),
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
        onRefresh: _loadPedidos,
        color: const Color(0xFF00A63E),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                onChanged: _filterPedidos,
                decoration: InputDecoration(
                  hintText: 'Buscar por ID o Cliente...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            
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
      return _buildShimmerLoading();
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
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: _loadPedidos,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A63E)),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      );
    }

    if (_filteredPedidos.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text(
            'No hay pedidos disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      );
    }

    final currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPedidos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pedido = _filteredPedidos[index];
        final stateColor = _getStatusColor(pedido.idEstadoPedido);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openDetailsModal(pedido),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PED-${pedido.idPedido.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: stateColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pedido.estadoDespacho,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: stateColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pedido.cliente?.razonSocial ?? 'Cliente Desconocido',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              currencyFmt.format(pedido.totalNeto),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A63E),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
