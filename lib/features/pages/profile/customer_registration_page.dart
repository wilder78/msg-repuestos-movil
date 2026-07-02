// lib/features/pages/profile/customer_registration_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../config/dio_config.dart';

class CustomerRegistrationPage extends StatefulWidget {
  const CustomerRegistrationPage({super.key});

  @override
  State<CustomerRegistrationPage> createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _documentNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  List<dynamic> _documentTypes = [];
  List<dynamic> _departments = [];
  List<dynamic> _municipalities = [];

  int? _selectedDocumentType;
  int? _selectedDepartment;
  int? _selectedMunicipality;
  final String _selectedClientType = 'Consumidor final';

  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('auth_user');
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _emailController.text = userData['email'] ?? '';
      }

      // 1. Cargar Tipos de Documento
      final docResponse = await DioConfig.dio.get<List<dynamic>>('api/tipo-documento');
      
      // 2. Cargar Departamentos
      final deptResponse = await DioConfig.dio.get<List<dynamic>>('api/departments');

      setState(() {
        _documentTypes = docResponse.data ?? [];
        _departments = deptResponse.data ?? [];
        
        if (_documentTypes.isNotEmpty) {
          _selectedDocumentType = _documentTypes[0]['idTipoDocumento'];
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar catálogos: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadMunicipalities(int departmentId) async {
    setState(() {
      _municipalities = [];
      _selectedMunicipality = null;
    });

    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/municipalities/department/$departmentId');
      setState(() {
        _municipalities = response.data ?? [];
        if (_municipalities.isNotEmpty) {
          _selectedMunicipality = _municipalities[0]['id'];
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar municipios: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMunicipality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un municipio'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await DioConfig.dio.post<Map<String, dynamic>>(
        'api/customers',
        data: {
          'idTipoDocumento': _selectedDocumentType,
          'numeroDocumento': _documentNumberController.text.trim(),
          'razonSocial': _businessNameController.text.trim(),
          'direccion': _addressController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'tipoCliente': _selectedClientType,
          'municipioId': _selectedMunicipality,
          'activo': 1,
        },
      );

      final body = response.data ?? {};
      if (body['status'] == 'success') {
        // Guardar idCliente en SharedPreferences para mantener consistencia local
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString('auth_user');
        if (userJson != null) {
          final userData = jsonDecode(userJson);
          userData['idCliente'] = body['data']['idCliente'];
          await prefs.setString('auth_user', jsonEncode(userData));
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro de cliente completado con éxito'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception(body['message'] ?? 'Error al registrar cliente');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = responseData is Map ? (responseData['message'] ?? responseData['error']) : null;
      setState(() {
        _errorMessage = msg ?? 'Error inesperado: ${e.message}';
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Completar Registro de Cliente',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Razón Social / Nombre
                      const Text(
                        'Nombre Completo / Razón Social *',
                        style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _businessNameController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: _buildInputDecoration(hint: 'Escribe tu nombre comercial', icon: Icons.business),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Este campo es obligatorio' : null,
                      ),
                      const SizedBox(height: 20),

                      // Tipo y Número de Documento en Fila
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tipo Doc. *',
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                _buildDocumentTypeDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Documento *',
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _documentNumberController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: _buildInputDecoration(hint: 'Número', icon: Icons.badge_outlined),
                                  validator: (value) => value == null || value.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dirección y Teléfono en Fila
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Teléfono *',
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: _buildInputDecoration(hint: 'Teléfono', icon: Icons.phone_android_outlined),
                                  validator: (value) => value == null || value.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Dirección de Entrega *',
                        style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: _buildInputDecoration(hint: 'Calle # - Barrio', icon: Icons.location_on_outlined),
                        validator: (value) => value == null || value.trim().isEmpty ? 'La dirección es obligatoria' : null,
                      ),
                      const SizedBox(height: 20),

                      // Email (Prefilled, read-only)
                      const Text(
                        'Correo Electrónico (Prefijado)',
                        style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.black38),
                        decoration: _buildInputDecoration(hint: 'Correo', icon: Icons.email_outlined).copyWith(
                          fillColor: const Color(0xFFEEEEEE),
                        ),
                      ),
                      const SizedBox(height: 20),



                      // Departamentos y Municipios en Fila
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Departamento *',
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                _buildDepartmentDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Municipio *',
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                _buildMunicipalityDropdown(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Botón Guardar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Completar Registro',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDocumentType,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
          isExpanded: true,
          items: _documentTypes.map((type) {
            return DropdownMenuItem<int>(
              value: type['idTipoDocumento'] as int,
              child: Text(type['sigla'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedDocumentType = value);
          },
        ),
      ),
    );
  }


  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDepartment,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
          hint: const Text('Selec.', style: TextStyle(color: Colors.black38)),
          isExpanded: true,
          items: _departments.map((dept) {
            return DropdownMenuItem<int>(
              value: dept['id'] as int,
              child: Text(dept['name'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedDepartment = value);
              _loadMunicipalities(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMunicipalityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMunicipality,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
          hint: const Text('Selec.', style: TextStyle(color: Colors.black38)),
          isExpanded: true,
          items: _municipalities.map((muni) {
            return DropdownMenuItem<int>(
              value: muni['id'] as int,
              child: Text(muni['name'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedMunicipality = value);
          },
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
