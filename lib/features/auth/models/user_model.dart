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
      idUsuario: json['idUsuario'] as int,
      nombreUsuario: json['nombreUsuario'] as String,
      email: json['email'] as String,
      idEstado: json['idEstado'] as int,
      fechaCreacion: json['fechaCreacion'] as String,
      idRol: json['idRol'] as int,
      idCliente: json['idCliente'] as int?,
    );
  }

  bool get isMaster => idRol == 1;
  bool get isVendedor => idRol == 3;
  bool get isCliente => idRol == 4;
  bool get hasAppAccess => isMaster || isVendedor || isCliente;

  String get rolNombre {
    switch (idRol) {
      case 1:
        return 'Master';
      case 3:
        return 'Vendedor';
      case 4:
        return 'Cliente';
      default:
        return 'Sin acceso';
    }
  }
}