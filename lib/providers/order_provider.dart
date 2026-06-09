import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> createOrder(List<Map<String, dynamic>> cartItems, String address, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (cartItems.isEmpty) return null;
      
      final firstItem = cartItems.first;
      final response = await ApiService.post('/orders', {
        'user_id': userId,
        'package_id': firstItem['package'].id,
        'quantity': firstItem['quantity'],
        'total_price': firstItem['package'].price * firstItem['quantity'],
        'delivery_address': address,
      });

      if (response['success'] == true) {
        return response['order_code'];
      }
      return null;
    } catch (e) {
      debugPrint('Create order error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}