// lib/features/auth/register_page.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/dio_config.dart';
import 'services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Credenciales Section
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Facturación Section
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _documentNumberController = TextEditingController();

  // Dropdown Catalogs
  List<dynamic> _documentTypes = [];
  List<dynamic> _departments = [];
  List<dynamic> _municipalities = [];

  int? _selectedDocumentType;
  int? _selectedDepartment;
  int? _selectedMunicipality;

  bool _isLoading = false;
  bool _isLoadingCatalogs = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String? _errorMessage;
  
  // Errores en tiempo real
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _documentError;
  String? _businessNameError;
  String? _contactPersonError;
  String? _addressError;
  String? _usernameError;
  String? _deptError;
  String? _muniError;
  String? _docTypeError;

  void _validateEmail(String val) {
    setState(() {
      if (val.isEmpty) {
        _emailError = 'El correo es obligatorio';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
        _emailError = 'Email no válido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePasswords(String? _) {
    setState(() {
      if (_passwordController.text.isEmpty) {
        _passwordError = 'La contraseña es obligatoria';
      } else {
        _passwordError = null;
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Debes confirmar la contraseña';
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _validatePhone(String val) {
    setState(() {
      if (val.isEmpty) {
        _phoneError = 'El teléfono es obligatorio';
      } else if (val.length < 10) {
        _phoneError = 'Mínimo 10 dígitos';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateDocument(String val) {
    setState(() {
      if (val.isEmpty) {
        _documentError = 'El documento es obligatorio';
      } else if (val.length < 6) {
        _documentError = 'Documento muy corto';
      } else {
        _documentError = null;
      }
    });
  }

  void _validateRequired(String field, String val) {
    setState(() {
      switch (field) {
        case 'business': _businessNameError = val.isEmpty ? 'La razón social es obligatoria' : null; break;
        case 'contact': _contactPersonError = val.isEmpty ? 'El contacto es obligatorio' : null; break;
        case 'address': _addressError = val.isEmpty ? 'La dirección es obligatoria' : null; break;
        case 'username': _usernameError = val.isEmpty ? 'El usuario es obligatorio' : null; break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final docResponse = await DioConfig.dio.get<List<dynamic>>('api/tipo-documento');
      final deptResponse = await DioConfig.dio.get<List<dynamic>>('api/departments');

      setState(() {
        _documentTypes = docResponse.data ?? [];
        _departments = deptResponse.data ?? [];
        
        if (_documentTypes.isNotEmpty) {
          _selectedDocumentType = _documentTypes[0]['idTipoDocumento'];
        }
        _isLoadingCatalogs = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar catálogos: $e';
          _isLoadingCatalogs = false;
        });
      }
    }
  }

  Future<void> _loadMunicipalities(int departmentId) async {
    setState(() {
      _municipalities = [];
      _selectedMunicipality = null;
    });

    try {
      final response = await DioConfig.dio.get<List<dynamic>>('api/municipalities/department/$departmentId');
      if (mounted) {
        setState(() {
          _municipalities = response.data ?? [];
          if (_municipalities.isNotEmpty) {
            _selectedMunicipality = _municipalities[0]['id'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar municipios: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_acceptedTerms) {
      setState(() => _errorMessage = '⚠️ Debes aceptar los términos de servicio y políticas para continuar');
      return;
    }

    if (_selectedDocumentType == null || _selectedMunicipality == null) {
      setState(() => _errorMessage = 'Por favor selecciona el tipo de documento y municipio');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().register(
        nombreUsuario: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        razonSocial: _businessNameController.text.trim(),
        numeroDocumento: _documentNumberController.text.trim(),
        idTipoDocumento: _selectedDocumentType!,
        direccion: _addressController.text.trim(),
        telefono: _phoneController.text.trim(),
        municipioId: _selectedMunicipality!,
        personaContacto: _contactPersonController.text.trim(),
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Por favor inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF11244D), Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text('Registro de Usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _isLoadingCatalogs 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              const _Logo(),
                              const SizedBox(height: 24),
                              
                              // TODO EN UNA SOLA CARD
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // SUBSECCIÓN: DATOS DE FACTURACIÓN
                                    _buildSubSectionTitle('Datos de Facturación', const Color(0xFFEF4444)),
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _businessNameController,
                                              label: 'Razón Social / Nombre Comercial',
                                              hint: 'Ej: Repuestos El Motor',
                                              icon: Icons.person_outline,
                                              errorText: _businessNameError,
                                              onChanged: (v) => _validateRequired('business', v),
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _contactPersonController,
                                              label: 'Persona de Contacto',
                                              hint: 'Ej: Juan Pérez',
                                              icon: Icons.person_outline,
                                              errorText: _contactPersonError,
                                              onChanged: (v) => _validateRequired('contact', v),
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _phoneController,
                                              label: 'Teléfono de contacto',
                                              hint: 'Ej: 3001234567',
                                              icon: Icons.phone_outlined,
                                              keyboardType: TextInputType.phone,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              errorText: _phoneError,
                                              onChanged: _validatePhone,
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _addressController,
                                              label: 'Dirección de entrega',
                                              hint: 'Ej: Calle 50 #10-20',
                                              icon: Icons.location_on_outlined,
                                              errorText: _addressError,
                                              onChanged: (v) => _validateRequired('address', v),
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _DropdownField(
                                              label: 'Tipo de documento',
                                              value: _selectedDocumentType,
                                              icon: Icons.description_outlined,
                                              errorText: _docTypeError,
                                              items: _documentTypes.map((t) => 
                                                DropdownMenuItem(value: t['idTipoDocumento'] as int, child: Text(t['sigla'] ?? ''))
                                              ).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedDocumentType = val;
                                                  _docTypeError = val == null ? 'Obligatorio' : null;
                                                });
                                              },
                                            ),
                                            _InputField(
                                              controller: _documentNumberController,
                                              label: 'Número de documento',
                                              hint: 'Ej: 10203040',
                                              icon: Icons.description_outlined,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              errorText: _documentError,
                                              onChanged: _validateDocument,
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _DropdownField(
                                              label: 'Departamento',
                                              value: _selectedDepartment,
                                              icon: Icons.location_on_outlined,
                                              hintText: 'Selecciona un departamento',
                                              errorText: _deptError,
                                              items: _departments.map((d) => 
                                                DropdownMenuItem(value: d['id'] as int, child: Text(d['name'] ?? ''))
                                              ).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() {
                                                    _selectedDepartment = val;
                                                    _deptError = null;
                                                  });
                                                  _loadMunicipalities(val);
                                                }
                                              },
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _DropdownField(
                                              label: 'Municipio / Ciudad',
                                              value: _selectedMunicipality,
                                              icon: Icons.location_on_outlined,
                                              hintText: 'Selecciona un municipio',
                                              errorText: _muniError,
                                              items: _municipalities.map((m) => 
                                                DropdownMenuItem(value: m['id'] as int, child: Text(m['name'] ?? ''))
                                              ).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedMunicipality = val;
                                                  _muniError = val == null ? 'El municipio es obligatorio' : null;
                                                });
                                              },
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),

                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                    ),

                                    // SUBSECCIÓN: CREDENCIALES DE USUARIO
                                    _buildSubSectionTitle('Credenciales de Usuario', const Color(0xFFEF4444)),
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _usernameController,
                                              label: 'Nombre de usuario',
                                              hint: 'Ej: juanperez12',
                                              icon: Icons.person_outline,
                                              errorText: _usernameError,
                                              onChanged: (v) => _validateRequired('username', v),
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _InputField(
                                              controller: _emailController,
                                              label: 'Correo electrónico',
                                              hint: 'tu@email.com',
                                              icon: Icons.email_outlined,
                                              keyboardType: TextInputType.emailAddress,
                                              errorText: _emailError,
                                              onChanged: _validateEmail,
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _PasswordField(
                                              controller: _passwordController,
                                              label: 'Contraseña',
                                              hint: '••••••••',
                                              obscureText: _obscurePassword,
                                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                              errorText: _passwordError,
                                              onChanged: _validatePasswords,
                                            ),
                                          ]),
                                          _buildFieldRow([
                                            _PasswordField(
                                              controller: _confirmPasswordController,
                                              label: 'Confirmar contraseña',
                                              hint: '••••••••',
                                              obscureText: _obscureConfirmPassword,
                                              onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                              errorText: _confirmPasswordError,
                                              onChanged: _validatePasswords,
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                              
                              _TermsCheckbox(
                                value: _acceptedTerms,
                                showError: _errorMessage != null && !_acceptedTerms,
                                onChanged: (val) => setState(() {
                                  _acceptedTerms = val ?? false;
                                  if (_acceptedTerms) _errorMessage = null;
                                }),
                              ),
                              
                              const SizedBox(height: 24),
                              if (_errorMessage != null) _ErrorMessage(message: _errorMessage!),
                              _RegisterButton(isLoading: _isLoading, onPressed: _register),
                              
                              const SizedBox(height: 32),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                    children: [
                                      TextSpan(text: '¿Ya tienes cuenta? '),
                                      TextSpan(
                                        text: 'Inicia sesión',
                                        style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(List<Widget> fields) {
    if (fields.length == 1) return Padding(padding: const EdgeInsets.only(bottom: 16), child: fields[0]);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: e.key < fields.length - 1 ? 12 : 0,
              ),
              child: e.value,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ⬇️ Widgets auxiliares refinados

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'auth_logo',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 80,
          height: 80,
          child: Image.asset('assets/images/logocuadrado.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            errorText: errorText,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.hintText,
    this.errorText,
  });

  final String label;
  final int? value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?> onChanged;
  final IconData icon;
  final String? hintText;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: errorText != null ? Colors.redAccent : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF64748B), size: 20),
                    const SizedBox(width: 10),
                    Text(hintText ?? 'Selecciona', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                  ],
                ),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggle,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 20),
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged, this.showError = false});
  final bool value;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: showError ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: showError ? Colors.redAccent.withValues(alpha: 0.5) : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: const Color(0xFF1E3A8A),
              side: showError ? const BorderSide(color: Colors.redAccent, width: 2) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: showError ? Colors.red[100] : Colors.white, fontSize: 14),
                children: [
                  const TextSpan(text: 'Acepto los '),
                  TextSpan(
                    text: 'Términos de servicio',
                    style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' y la '),
                  TextSpan(
                    text: 'Política de privacidad',
                    style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('REGISTRARSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
