import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  // Daftar opsi ikon yang bisa dipilih user
  static const Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant,
    'local_drink': Icons.local_drink,
    'fastfood': Icons.fastfood,
    'shopping_bag': Icons.shopping_bag,
    'devices': Icons.devices,
    'checkroom': Icons.checkroom,
    'home': Icons.home,
    'category': Icons.category,
  };

  static IconData getIcon(String? name) {
    return availableIcons[name] ?? Icons.category;
  }
}