// FILE: lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'order_status_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  int _totalOrders = 0;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    try {
      final response = await ApiService.get('/my-orders', queryParams: {'user_id': userId.toString()});
      if (response is List) {
        setState(() {
          _orders = response.reversed.toList();
          _totalOrders = _orders.length;
          _totalSpent = _orders.fold(0.0, (sum, order) => sum + double.parse(order['total_price']?.toString() ?? '0'));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'preparing': return 'Dimasak';
      case 'delivered': return 'Dikirim';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'preparing': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistik Card
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalOrders',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Text('Total Pesanan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.white38),
                      Column(
                        children: [
                          const Icon(Icons.money, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Rp${_totalSpent.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Text('Total Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                // List Pesanan
                Expanded(
                  child: _orders.isEmpty
                      ? const Center(child: Text('Belum ada pesanan'))
                      : RefreshIndicator(
                          onRefresh: _fetchOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(order['status']),
                                    child: const Icon(Icons.receipt, color: Colors.white, size: 20),
                                  ),
                                  title: Text(
                                    order['order_code'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'Rp${order['total_price']} • ${order['created_at']?.toString().substring(0, 10) ?? '-'}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusLabel(order['status']),
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderStatusScreen(orderCode: order['order_code']),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ), 
                ),
              ],
            ),
    ); 
  }
}