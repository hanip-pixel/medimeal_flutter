import 'package:flutter/material.dart';

class MealPackage {
  final int id;
  final String name;
  final String description;
  final String medicalCondition;
  final double price;
  final int durationDays;
  final int calories;
  final String imageUrl;
  final bool isAvailable;

  MealPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.medicalCondition,
    required this.price,
    required this.durationDays,
    required this.calories,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory MealPackage.fromJson(Map<String, dynamic> json) {
    return MealPackage(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      medicalCondition: json['medical_condition'] ?? 'Umum',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : double.parse(json['price'].toString()),
      durationDays: json['duration_days'] ?? 7,
      calories: json['calories'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
    );
  }

  // Helper untuk get icon berdasarkan kondisi medis
  IconData getConditionIcon() {
    switch (medicalCondition) {
      case 'diabetes':
        return Icons.bloodtype;
      case 'jantung':
        return Icons.favorite;
      case 'ginjal':
        return Icons.water_drop;
      case 'pasca-operasi':
        return Icons.local_hospital;
      default:
        return Icons.food_bank;
    }
  }

  // Helper untuk get warna berdasarkan kondisi medis
  Color getConditionColor() {
    switch (medicalCondition) {
      case 'diabetes':
        return Colors.orange;
      case 'jantung':
        return Colors.red;
      case 'ginjal':
        return Colors.blue;
      case 'pasca-operasi':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  String getConditionLabel() {
    switch (medicalCondition) {
      case 'diabetes':
        return 'Diabetes';
      case 'jantung':
        return 'Jantung';
      case 'ginjal':
        return 'Gagal Ginjal';
      case 'pasca-operasi':
        return 'Pasca Operasi';
      default:
        return medicalCondition;
    }
  }
}