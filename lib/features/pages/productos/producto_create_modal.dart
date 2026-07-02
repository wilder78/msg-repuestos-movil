import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'models/producto_model.dart';
import 'repositories/productos_repository.dart';

class ProductoCreateModal extends StatefulWidget {
  final List<CategoriaModel> categorias;
  final VoidCallback onProductCreated;

  const ProductoCreateModal({
    super.key,
    required this.categorias,
    required this.onProductCreated,
  });

  @override
  State<ProductoCreateModal> createState() => _ProductoCreateModalState();
}

class _ProductoCreateModalState extends State<ProductoCreateModal> {
  final _formKey = GlobalKey<FormState>();
  final ProductosRepository _repository = ProductosRepository();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _nombreController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioPublicoController = TextEditingController();
  final _precioMayoristaController = TextEditingController();
  final _precioMinoristaController = TextEditingController();
  final _stockController = TextEditingController();
  final _fechaController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _descripcionController = TextEditingController();

  int? _selectedCategoryId;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _referenciaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _precioCompraController.dispose();
    _precioPublicoController.dispose();
    _precioMayoristaController.dispose();
    _precioMinoristaController.dispose();
    _stockController.dispose();
    _fechaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione una categoría')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> productData = {
        'nombre': _nombreController.text.trim(),
        'referencia': _referenciaController.text.trim(),
        'id_categoria': _selectedCategoryId,
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'precio_compra': double.parse(_precioCompraController.text),
        'precio_publico': double.parse(_precioPublicoController.text),
        'precio_mayorista': double.parse(_precioMayoristaController.text),
        'precio_minorista': double.parse(_precioMinoristaController.text),
        'stock_buen_estado': int.parse(_stockController.text),
        'fecha_registro': _fechaController.text,
        'descripcion': _descripcionController.text.trim(),
        // La imagen requiere multipart en el backend, si el endpoint no lo soporta
        // en JSON directo, se ignorará por ahora o se enviaría base64 si es necesario.
        // Pero el repo usa .post<Map<String, dynamic>> que es JSON.
      };

      await _repository.createProducto(productData);

      if (mounted) {
        widget.onProductCreated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto registrado exitosamente'),
            backgroundColor: Color(0xFF00A63E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Información General'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre del Producto',
                      hint: 'Ej: Pastillas de Freno Cerámicas',
                      isRequired: true,
                      icon: Icons.info_outline,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _referenciaController,
                            label: 'Referencia / SKU',
                            hint: 'FRE-PAST-001',
                            isRequired: true,
                            icon: Icons.qr_code,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCategoryDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _marcaController,
                            label: 'Marca',
                            hint: 'Akebono',
                            icon: Icons.branding_watermark_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _modeloController,
                            label: 'Modelo / Año',
                            hint: '2024',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Precios'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _precioCompraController,
                            label: 'Precio Compra',
                            hint: '0.00',
                            isRequired: true,
                            isNumeric: true,
                            icon: Icons.attach_money,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _precioPublicoController,
                            label: 'Precio Público',
                            hint: '0.00',
                            isRequired: true,
                            isNumeric: true,
                            icon: Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _precioMayoristaController,
                            label: 'Precio Mayorista',
                            hint: '0.00',
                            isRequired: true,
                            isNumeric: true,
                            icon: Icons.attach_money,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _precioMinoristaController,
                            label: 'Precio Minorista',
                            hint: '0.00',
                            isRequired: true,
                            isNumeric: true,
                            icon: Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Inventario y Detalles'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _stockController,
                            label: 'Stock Inicial',
                            hint: '0',
                            isRequired: true,
                            isNumeric: true,
                            icon: Icons.archive_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _fechaController,
                            label: 'Fecha Registro',
                            hint: 'YYYY-MM-DD',
                            isRequired: true,
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Detalles adicionales del producto...',
                      isMultiline: true,
                    ),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Nuevo Producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Ingresa las especificaciones técnica',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
              image: _imageFile != null
                  ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                  : null,
            ),
            child: _imageFile == null
                ? const Icon(Icons.image_outlined, size: 40, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton.small(
              onPressed: _pickImage,
              backgroundColor: const Color(0xFF00A63E),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool isRequired = false,
    bool isNumeric = false,
    bool isMultiline = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Color(0xFF00A63E))),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
          maxLines: isMultiline ? 3 : 1,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFF00A63E)),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Campo requerido';
            }
            if (isNumeric && value != null && value.isNotEmpty) {
              if (double.tryParse(value) == null) return 'Valor inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Categoría',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            Text(' *', style: TextStyle(color: Color(0xFF00A63E))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: const Text('Selecciona', style: TextStyle(fontSize: 14)),
              items: widget.categorias.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat.idCategoria,
                  child: Text(cat.nombreCategoria, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A63E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Guardar Producto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
