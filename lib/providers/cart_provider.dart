import 'package:flutter/material.dart';
import '../models/meal_package_model.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  
  List<Map<String, dynamic>> get items => _items;
  
  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += (item['package'].price * item['quantity']);
    }
    return total;
  }

  int get itemCount => _items.length;

  void addToCart(MealPackage package, int quantity) {
    int index = _items.indexWhere((item) => item['package'].id == package.id);
    if (index != -1) {
      _items[index]['quantity'] += quantity;
    } else {
      _items.add({'package': package, 'quantity': quantity});
    }
    notifyListeners();
  }

  void removeFromCart(int packageId) {
    _items.removeWhere((item) => item['package'].id == packageId);
    notifyListeners();
  }

  void updateQuantity(int packageId, int quantity) {
    int index = _items.indexWhere((item) => item['package'].id == packageId);
    if (index != -1 && quantity > 0) {
      _items[index]['quantity'] = quantity;
    } else if (quantity <= 0) {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}