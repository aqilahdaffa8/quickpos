import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickPOS Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Utama UMKM',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Kelola Produk',
                  icon: Icons.inventory_2_rounded,
                  color: AppColors.accentBlue,
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),
                _buildMenuCard(
                  context,
                  title: 'Kelola Kategori',
                  icon: Icons.category_rounded,
                  color: AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, '/categories'),
                ),
                _buildMenuCard(
                  context,
                  title: 'Mesin Kasir (POS)',
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.success,
                  onTap: () => Navigator.pushNamed(
                      context, '/pos'), // Hubungkan ke halaman POS
                ),
                _buildMenuCard(
                  context,
                  title: 'Laporan Penjualan',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.primaryBlue,
                  onTap: () => Navigator.pushNamed(context, '/reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
