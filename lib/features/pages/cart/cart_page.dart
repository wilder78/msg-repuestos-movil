import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'providers/cart_provider.dart';
import '../pedidos/repositories/pedidos_repository.dart';
import '../../auth/models/user_model.dart';
import '../profile/repositories/profile_repository.dart';

class CartPage extends StatefulWidget {
  final UserModel? user;
  const CartPage({super.key, this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final _docController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _metodoPago = 'Efectivo';
  String _tipoDoc = '1';
  bool _isProfileComplete = false;
  

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() async {
    if (widget.user == null) {
      if (mounted) setState(() {});
      return;
    }

    if (widget.user!.isCliente) {
       try {
         final result = await ProfileRepository().getProfile();
         final profile = result.profile;
         
         _nameController.text = profile.nombre;
         _docController.text = profile.numeroDocumento ?? '';
         _phoneController.text = profile.telefono;
         _emailController.text = widget.user!.email;
         _addressController.text = profile.direccion;
         
         if (profile.idTipoDocumento != null) {
           _tipoDoc = profile.idTipoDocumento.toString();
         }

         // Verificar si los campos obligatorios están llenos
         if (_nameController.text.isNotEmpty && 
             _docController.text.isNotEmpty && 
             _phoneController.text.isNotEmpty) {
           _isProfileComplete = true;
         }
       } catch (e) {
         // Fallback a datos básicos del usuario si falla el repositorio
         _nameController.text = widget.user!.nombreUsuario;
         _emailController.text = widget.user!.email;
       }
    } else {
      // Para otros roles, prellenamos lo que tengamos del UserModel
      _nameController.text = widget.user!.nombreUsuario;
      _emailController.text = widget.user!.email;
    }
    
    if (mounted) setState(() {});
  }

  final NumberFormat _currencyFmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  Future<void> _realizarPedido(CartProvider cart) async {
    // Si no está logueado, validamos el formulario
    if (widget.user == null) {
      if (!_formKey.currentState!.validate()) return;
      Navigator.of(context).pop(); // Cierra el modal del formulario
    }
    
    // Mostramos un indicador de carga principal.

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
    );

    try {
      final detalles = cart.items.map((item) => {
        "id_producto": item.idProducto,
        "cantidad": item.cantidad,
        "precio_unitario": item.precio,
      }).toList();

      final data = {
        "tipo_pago": _metodoPago,
        "id_tipo_documento": _tipoDoc,
        "documento_cliente": _docController.text,
        "nombre_cliente": _nameController.text,
        "telefono_cliente": _phoneController.text,
        "email_cliente": _emailController.text,
        "direccion_cliente": _addressController.text,
        "detalles": detalles,
        "id_origen_pedido": 2, // 2 para Movil, 1 para Web
        if (widget.user?.idCliente != null) "id_cliente": widget.user!.idCliente,
      };

      await PedidosRepository().createPedido(data);
      
      cart.clearCart();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra el indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Pedido realizado con éxito! 🎉'), backgroundColor: Colors.green));
      
      _docController.clear();
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
      
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Cierra el indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _mostrarSeleccionMetodoPago(CartProvider cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Método de Pago', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 8),
                  const Text('Tu información de facturación ya está lista. Solo elige cómo deseas pagar.', style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _metodoPago,
                    decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                      DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                      DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta de Crédito / Débito')),
                    ],
                    onChanged: (v) {
                      setState(() => _metodoPago = v!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar modal de pago
                        _realizarPedido(cart);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Confirmar pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _abrirFormularioCheckout(cart);
                    },
                    child: const Text('Editar mis datos de facturación', style: TextStyle(color: Color(0xFF3B82F6))),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _abrirFormularioCheckout(CartProvider cart) {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Datos del Cliente', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 8),
              const Text('Completa este formulario para facturar tu pedido.', style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _tipoDoc,
                          decoration: const InputDecoration(labelText: 'Tipo de Documento', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('C.C. - Cédula de Ciudadanía')),
                            DropdownMenuItem(value: '2', child: Text('NIT - Número de Identificación')),
                            DropdownMenuItem(value: '3', child: Text('C.E. - Cédula de Extranjería')),
                          ],
                          onChanged: (v) => setState(() => _tipoDoc = v!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _docController,
                          decoration: const InputDecoration(labelText: 'Número de Documento', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nombre Completo / Razón Social', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Teléfono / Celular', border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Dirección (Opcional)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _metodoPago,
                          decoration: const InputDecoration(labelText: 'Método de Pago', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                            DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                            DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta de Crédito / Débito')),
                          ],
                          onChanged: (v) => setState(() => _metodoPago = v!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _realizarPedido(cart),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Confirmar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mi Carrito', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: cart.items.isEmpty 
        ? _buildEmptyCart() 
        : _buildCartBody(cart),
      bottomNavigationBar: cart.items.isNotEmpty ? _buildBottomCheckout(cart) : null,
    );
  }

  Widget _buildBottomCheckout(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total a pagar:', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                Text(_currencyFmt.format(cart.totalAmount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A))),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.user != null) {
                  // Si está logueado, vamos directo al método de pago
                  _mostrarSeleccionMetodoPago(cart);
                } else {
                  // Solo si es invitado (null), pedimos datos
                  _abrirFormularioCheckout(cart);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: Text(
                _isProfileComplete ? 'Confirmar Pedido' : 'Realizar Pedido',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text('Tu carrito está vacío', style: TextStyle(color: Color(0xFF64748B), fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildCartBody(CartProvider cart) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      children: cart.items.map((item) => _buildCartItem(item, cart)).toList(),
    );
  }

  Widget _buildCartItem(CartItemModel item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imagenUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: const Color(0xFFF1F5F9), child: const Icon(Icons.image_not_supported, color: Color(0xFFCBD5E1)))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 4),
                Text(_currencyFmt.format(item.precio), style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF94A3B8)), onPressed: () => cart.decrementItem(item.idProducto)),
              Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3B82F6)), onPressed: () => cart.addItem(item)),
            ],
          )
        ],
      ),
    );
  }
}