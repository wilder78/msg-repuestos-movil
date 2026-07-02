// lib/features/pages/profile/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/dio_config.dart';
import 'models/profile_model.dart';
import 'repositories/profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile, required this.role});

  final ProfileModel profile;
  final String role;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _docNumberController;
  late final TextEditingController _docTypeController;

  List<dynamic> _departments = [];
  List<dynamic> _municipalities = [];
  int? _selectedDepartment;
  int? _selectedMunicipality;

  bool _isLoading = false;
  bool _isLoadingLocations = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.nombre);
    _phoneController = TextEditingController(text: widget.profile.telefono);
    _addressController = TextEditingController(text: widget.profile.direccion);
    _docNumberController = TextEditingController(text: widget.profile.numeroDocumento ?? '');
    _docTypeController = TextEditingController(text: widget.profile.idTipoDocumento ?? '');
    
    _selectedMunicipality = widget.profile.municipioId;
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _docNumberController.dispose();
    _docTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      // Cargar Departamentos
      final deptResponse = await DioConfig.dio.get<List<dynamic>>('api/departments');
      _departments = deptResponse.data ?? [];

      if (_selectedMunicipality != null) {
        // Si tenemos municipio, intentar encontrar su departamento para pre-seleccionarlo
        // Nota: Esto requiere que el backend devuelva el departmentId en el perfil o buscarlo
        // Como el ProfileModel no tiene departmentId, intentaremos cargar todos y buscar el municipio
        // O simplemente dejar que el usuario seleccione.
        // Pero para una mejor UX, vamos a intentar identificarlo.
        // Por ahora, cargaremos los departamentos y si hay municipio, buscaremos a qué departamento pertenece
        // (Esto podría ser costoso si hay muchos deptos, mejor pre-cargar el depto si se pudiera)
        
        // Simulación: Intentamos cargar municipios si conocemos el depto. 
        // Como no conocemos el depto, solo cargamos la lista de deptos.
      }

      setState(() => _isLoadingLocations = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar ubicaciones: $e';
        _isLoadingLocations = false;
      });
    }
  }

  Future<void> _loadMunicipalities(int departmentId) async {
    setState(() {
      _municipalities = [];
      // No reseteamos _selectedMunicipality inmediatamente si es la carga inicial
    });

    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/municipalities/department/$departmentId');
      setState(() {
        _municipalities = response.data ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar municipios: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _profileRepository.updateProfile(
        nombre: _nameController.text.trim(),
        telefono: _phoneController.text.trim(),
        direccion: _addressController.text.trim(),
        municipioId: _selectedMunicipality,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado con éxito', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCliente = widget.role == 'cliente';
    final primaryBlue = const Color(0xFF1E3A8A);
    final accentBlue = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryBlue),
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.outfit(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading || _isLoadingLocations
            ? Center(child: CircularProgressIndicator(color: accentBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado Visual
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentBlue.withValues(alpha: 0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: accentBlue.withValues(alpha: 0.1),
                            child: Icon(Icons.person_outline, size: 40, color: primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (_errorMessage != null) ...[
                        _buildErrorBanner(_errorMessage!),
                        const SizedBox(height: 20),
                      ],

                      // Sección: Información Básica
                      _buildSectionTitle('Información Básica'),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nombre Completo / Razón Social',
                        icon: Icons.person_outline,
                        hint: 'Tu nombre aquí',
                        validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Número de Teléfono',
                        icon: Icons.phone_android_outlined,
                        hint: '300 000 0000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'El teléfono es obligatorio';
                          if (v.length < 10) return 'El teléfono debe tener 10 dígitos';
                          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Solo se permiten números';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sección: Documento (Solo Lectura)
                      _buildSectionTitle('Identificación (Solo Lectura)'),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              controller: _docTypeController,
                              label: 'Tipo',
                              icon: Icons.badge_outlined,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 7,
                            child: _buildTextField(
                              controller: _docNumberController,
                              label: 'Número de Documento',
                              icon: Icons.numbers_outlined,
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sección: Ubicación
                      if (isCliente) ...[
                        _buildSectionTitle('Ubicación de Entrega'),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Dirección',
                          icon: Icons.location_on_outlined,
                          hint: 'Calle, Carrera, Barrio',
                          validator: (v) => v!.isEmpty ? 'La dirección es obligatoria' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Departamento',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedDepartment,
                                    hint: 'Seleccionar',
                                    items: _departments.map((d) => DropdownMenuItem<int>(
                                      value: d['id'],
                                      child: Text(d['name'] ?? ''),
                                    )).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedDepartment = val;
                                        _selectedMunicipality = null;
                                      });
                                      if (val != null) _loadMunicipalities(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Municipio',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedMunicipality,
                                    hint: 'Seleccionar',
                                    items: _municipalities.map((m) => DropdownMenuItem<int>(
                                      value: m['id'],
                                      child: Text(m['name'] ?? ''),
                                    )).toList(),
                                    onChanged: (val) => setState(() => _selectedMunicipality = val),
                                    enabled: _selectedDepartment != null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Botón de Acción
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [accentBlue, primaryBlue],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Guardar Cambios',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.outfit(
            color: readOnly ? Colors.black45 : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: readOnly ? const Color(0xFFE2E8F0) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.outfit(color: Colors.black38, fontSize: 14)),
          items: enabled ? items : [],
          onChanged: enabled ? onChanged : null,
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.outfit(color: const Color(0xFFB91C1C), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
