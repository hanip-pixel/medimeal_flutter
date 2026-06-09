import 'package:flutter/material.dart';
import '../models/meal_package_model.dart';
import '../services/api_service.dart';
import 'package_detail_screen.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  late Future<List<MealPackage>> _packages;
  String _selectedCondition = 'semua';
  bool _isLoading = false;

  final List<Map<String, String>> _conditions = [
    {'value': 'semua', 'label': 'Semua Kondisi', 'icon': '🍽️'},
    {'value': 'diabetes', 'label': 'Diabetes', 'icon': '🩸'},
    {'value': 'jantung', 'label': 'Jantung', 'icon': '❤️'},
    {'value': 'ginjal', 'label': 'Gagal Ginjal', 'icon': '💧'},
    {'value': 'pasca-operasi', 'label': 'Pasca Operasi', 'icon': '🏥'},
  ];

  Future<List<MealPackage>> fetchPackages() async {
    try {
      final response = await ApiService.get('/packages');
      if (response != null && response is List) {
        List<MealPackage> packages = response.map((json) => MealPackage.fromJson(json)).toList();
        
        if (_selectedCondition != 'semua') {
          packages = packages.where((p) => p.medicalCondition == _selectedCondition).toList();
        }
        return packages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _packages = fetchPackages();
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _selectedCondition = value ?? 'semua';
      _packages = fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: Column(
        children: [
          // Filter Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _conditions.map((condition) {
                  bool isSelected = _selectedCondition == condition['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${condition['icon']} ${condition['label']}'),
                      selected: isSelected,
                      onSelected: (_) => _onFilterChanged(condition['value']),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // List Package
          Expanded(
            child: FutureBuilder(
              future: _packages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.food_bank, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('Tidak ada paket untuk ${_conditions.firstWhere((c) => c['value'] == _selectedCondition)['label']}'),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final pkg = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageDetailScreen(package: pkg),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: pkg.getConditionColor().withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    pkg.getConditionIcon(),
                                    color: pkg.getConditionColor(),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pkg.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: pkg.getConditionColor().withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          pkg.getConditionLabel(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: pkg.getConditionColor(),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp${pkg.price.toStringAsFixed(0)}/hari',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price Button
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Text(
                                    'Pesan',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}