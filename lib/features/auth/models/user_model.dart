// lib/features/auth/models/user_model.dart

class UserModel {
  final int idUsuario;
  final String nombreUsuario;
  final String email;
  final int idEstado;
  final String fechaCreacion;
  final int idRol;
  final int? idCliente;

  const UserModel({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.email,
    required this.idEstado,
    required this.fechaCreacion,
    required this.idRol,
    this.idCliente,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['idUsuario'] as int? ?? 0,
      nombreUsuario: json['nombreUsuario'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      idEstado: json['idEstado'] as int? ?? 1,
      fechaCreacion: json['fechaCreacion'] as String? ?? '',
      idRol: json['idRol'] as int? ?? 0,
      idCliente: int.tryParse(json['id_cliente']?.toString() ?? json['idCliente']?.toString() ?? '') as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'email': email,
      'idEstado': idEstado,
      'fechaCreacion': fechaCreacion,
      'idRol': idRol,
      'idCliente': idCliente,
    };
  }

  bool get isMaster => idRol == 1;
  bool get isAsistenteAdmin => idRol == 2;
  bool get isVendedor => idRol == 3;
  bool get isCliente => idRol == 4;
  bool get isAsistenteBodega => idRol == 5;

  /// Solo administrador, asistente administrativo y asistente de bodega
  bool get canViewProductos => isMaster || isAsistenteAdmin || isAsistenteBodega;

  bool get hasAppAccess => isMaster || isAsistenteAdmin || isVendedor || isCliente || isAsistenteBodega;

  String get rolNombre {
    switch (idRol) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Asistente Administrativo';
      case 3:
        return 'Vendedor';
      case 4:
        return 'Cliente';
      case 5:
        return 'Asistente de Bodega';
      default:
        return 'Sin acceso';
    }
  }
}
