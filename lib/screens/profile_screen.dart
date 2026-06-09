// FILE: lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalOrders = 0;
  double _totalSpent = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderStats();
  }

  Future<void> _fetchOrderStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;
    
    if (userId == null) {
      setState(() => _isLoadingStats = false);
      return;
    }
    
    try {
      final response = await ApiService.get('/my-orders', queryParams: {'user_id': userId.toString()});
      if (response is List) {
        final orders = response;
        setState(() {
          _totalOrders = orders.length;
          _totalSpent = orders.fold(0.0, (sum, order) => sum + double.parse(order['total_price']?.toString() ?? '0'));
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrderStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 24),
              
              // Statistik Card
              _isLoadingStats
                  ? Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
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
                          Container(width: 1, height: 50, color: Colors.white38),
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
              
              // Info Nama
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.green),
                  title: const Text('Nama Lengkap'),
                  subtitle: Text(user?.fullname ?? 'Belum diisi'),
                ),
              ),
              
              // Info Email
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined, color: Colors.green),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? 'Belum diisi'),
                ),
              ),
              
              // Info Role
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Colors.green),
                  title: const Text('Role'),
                  subtitle: Text(user?.role ?? 'Pasien'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tombol Edit Profil
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ).then((_) {
                      _fetchOrderStats();
                      authProvider.refreshUser();
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tombol Riwayat Pesanan
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Lihat Riwayat Pesanan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}