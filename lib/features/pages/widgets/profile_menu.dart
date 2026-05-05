import 'package:flutter/material.dart';

import '../../auth/models/user_model.dart';

class ProfileMenu {
  static void show({
    required BuildContext context,
    required UserModel? user,
    required VoidCallback onLogout,
  }) {
    showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 0, 0),
      items: [
        PopupMenuItem<int>(
          value: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.nombreUsuario ?? 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar sesión'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 1) onLogout();
    });
  }
}