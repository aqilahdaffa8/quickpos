import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickPOS Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Dashboard Ready - Menunggu Tahap 2',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}