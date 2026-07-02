import 'package:flutter/material.dart';

class CartItemModel {
  final int idProducto;
  final String nombre;
  final double precio;
  final String imagenUrl;
  int cantidad;

  CartItemModel({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    required this.imagenUrl,
    this.cantidad = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + (item.precio * item.cantidad));

  void addItem(CartItemModel item) {
    final existingIndex = _items.indexWhere((i) => i.idProducto == item.idProducto);
    if (existingIndex >= 0) {
      _items[existingIndex].cantidad += 1;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int idProducto) {
    _items.removeWhere((i) => i.idProducto == idProducto);
    notifyListeners();
  }

  void decrementItem(int idProducto) {
    final existingIndex = _items.indexWhere((i) => i.idProducto == idProducto);
    if (existingIndex >= 0) {
      if (_items[existingIndex].cantidad > 1) {
        _items[existingIndex].cantidad -= 1;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
