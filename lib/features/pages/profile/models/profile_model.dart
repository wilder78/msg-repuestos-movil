// lib/features/pages/profile/models/profile_model.dart

class ProfileModel {
  final String nombre;
  final String telefono;
  final String direccion;
  final String municipio;
  final int? municipioId;
  final String? idTipoDocumento;
  final String? numeroDocumento;

  const ProfileModel({
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.municipio,
    this.municipioId,
    this.idTipoDocumento,
    this.numeroDocumento,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      nombre: json['nombre'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      municipio: json['municipio'] as String? ?? '',
      municipioId: json['municipioId'] as int?,
      idTipoDocumento: json['idTipoDocumento']?.toString() ?? json['id_tipo_documento']?.toString(),
      numeroDocumento: json['numeroDocumento']?.toString() ?? 
                       json['numero_documento']?.toString() ?? 
                       json['documento']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
      'municipio': municipio,
      'municipioId': municipioId,
      'idTipoDocumento': idTipoDocumento,
      'numeroDocumento': numeroDocumento,
    };
  }
}
