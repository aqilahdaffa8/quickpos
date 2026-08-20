import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../report/presentation/providers/report_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportProvider>().loadReportData());
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      // HAPUS SafeArea() agar header bisa tembus ke status bar atas
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION (Sapaan & Info Toko) ---
            Container(
              // Padding atas dibuat dinamis (Tinggi Status Bar + 24)
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24, 
                left: 24, 
                right: 24, 
                bottom: 24
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo, Juragan! 👋',
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.surfaceWhite
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayDate,
                            style: TextStyle(
                              fontSize: 14, 
                              color: AppColors.surfaceWhite.withOpacity(0.8)
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront, color: AppColors.surfaceWhite, size: 28),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // --- MINI REPORT CARD ---
                  const Text(
                    'Omset Bulan Ini',
                    style: TextStyle(fontSize: 14, color: AppColors.surfaceWhite),
                  ),
                  const SizedBox(height: 8),
                  Consumer<ReportProvider>(
                    builder: (context, report, child) {
                      if (report.isLoading) {
                        return const SizedBox(
                          height: 36, 
                          child: CircularProgressIndicator(color: AppColors.surfaceWhite)
                        );
                      }
                      return Text(
                        CurrencyFormatter.format(report.totalOmset),
                        style: const TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.bold, 
                          color: AppColors.surfaceWhite
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // ---------------------------------------------

            const SizedBox(height: 24),
            
            // --- MENU UTAMA SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Operasional',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textPrimary
                    ),
                  ),
                  GridView.count(
                    padding: const EdgeInsets.only(top: 24),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Mesin Kasir',
                        subtitle: 'Mulai Transaksi',
                        icon: Icons.point_of_sale_rounded,
                        color: AppColors.success,
                        onTap: () => Navigator.pushNamed(context, '/pos'),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Produk',
                        subtitle: 'Kelola Barang',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.accentBlue,
                        onTap: () => Navigator.pushNamed(context, '/products'),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Kategori',
                        subtitle: 'Grup Produk',
                        icon: Icons.category_rounded,
                        color: AppColors.warning,
                        onTap: () => Navigator.pushNamed(context, '/categories'),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Laporan',
                        subtitle: 'Analitik Bisnis',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.primaryBlue,
                        onTap: () => Navigator.pushNamed(context, '/reports'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12, 
                  color: AppColors.textSecondary
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}