// lib/features/pages/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/login_page.dart';
import 'models/profile_model.dart';
import 'repositories/profile_repository.dart';
import 'edit_profile_page.dart';
import 'customer_registration_page.dart';
import '../productos/productos_page.dart';
import '../productos/producto_create_modal.dart';
import '../productos/repositories/productos_repository.dart';
import '../../auth/models/user_model.dart';
import '../pedidos/pedidos_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isLoading = true;
  String? _errorMessage;
  
  late ProfileModel _profile;
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _profileRepository.getProfile();
      setState(() {
        _role = result.role;
        _profile = result.profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openRegistrarProducto() async {
    setState(() => _isLoading = true);
    try {
      final repository = ProductosRepository();
      final categorias = await repository.getCategorias();
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProductoCreateModal(
          categorias: categorias,
          onProductCreated: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Producto registrado correctamente'),
                backgroundColor: Color(0xFF00A63E),
              ),
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar categorías: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blue),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final bool isClienteIncompleto = _role == 'cliente' && _profile.telefono.isEmpty && _profile.direccion.isEmpty;

    if (isClienteIncompleto) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Registro Incompleto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Para continuar y realizar pedidos, por favor completa tu registro ingresando tu documento, teléfono, dirección y municipio de entrega.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CustomerRegistrationPage(),
                    ),
                  );
                  if (result == true) {
                    _loadProfile();
                  }
                },
                icon: const Icon(Icons.assignment_ind_outlined, color: Colors.white),
                label: const Text(
                  'Completar Registro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String initial = _profile.nombre.isNotEmpty ? _profile.nombre[0].toUpperCase() : 'U';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tarjeta de Avatar y Rol
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade700, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _profile.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Campos de Detalles del Perfil
          _buildInfoSection('Información Personal', [
            _buildInfoTile(Icons.phone_android, 'Teléfono', _profile.telefono.isNotEmpty ? _profile.telefono : 'No registrado'),
            if (_profile.idTipoDocumento != null && _profile.numeroDocumento != null)
              _buildInfoTile(Icons.badge, 'Documento', '${_profile.idTipoDocumento}: ${_profile.numeroDocumento}'),
          ]),

          if (_role == 'cliente') ...[
            const SizedBox(height: 20),
            _buildInfoSection('Ubicación de Entrega', [
              _buildInfoTile(Icons.location_on_outlined, 'Dirección', _profile.direccion.isNotEmpty ? _profile.direccion : 'No registrada'),
              _buildInfoTile(Icons.map_outlined, 'Municipio', _profile.municipio.isNotEmpty ? _profile.municipio : 'No registrado'),
            ]),
          ],

          const SizedBox(height: 30),

          if (['administrador', 'asistente administrativo', 'asistente de bodega'].contains(_role.toLowerCase()))
            _buildInfoSection('Gestión de Inventario', [
              _buildActionTile(Icons.inventory_2_outlined, 'Ver Catálogo Completo', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductosPage(role: _role.toLowerCase())));
              }),
              _buildActionTile(Icons.add_box_outlined, 'Registrar Nuevo Producto', _openRegistrarProducto),
            ]),

          if (['administrador', 'asistente administrativo', 'asistente de bodega'].contains(_role.toLowerCase()))
            const SizedBox(height: 20),

          if (['vendedor', 'cliente', 'administrador', 'asistente administrativo'].contains(_role.toLowerCase()))
            _buildInfoSection('Mis Pedidos', [
              _buildActionTile(Icons.receipt_long_outlined, 'Ir a Pedidos', () {
                if (widget.user != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PedidosPage(user: widget.user!)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Usuario no cargado')));
                }
              }),
            ]),

          if (['vendedor', 'cliente', 'administrador'].contains(_role.toLowerCase()))
            const SizedBox(height: 40),

          // Botón de Edición
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(profile: _profile, role: _role),
                  ),
                );
                if (result == true) {
                  _loadProfile();
                }
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Editar Perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF334155), // slate-700
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 16),
          ],
        ),
      ),
    );
  }
}