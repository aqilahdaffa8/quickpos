import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/report_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ReportProvider>().loadReportData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Analitik'),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, report, child) {
          if (report.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Bulan Ini',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Kartu Ringkasan (Omset & Laba)
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Omset',
                        amount: report.totalOmset,
                        icon: Icons.account_balance_wallet,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Laba Bersih',
                        amount: report.netProfit,
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Grafik 7 Hari Terakhir
                // Grafik 7 Hari Terakhir
                const Text('Tren Pendapatan (7 Hari Terakhir)',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: report.weeklyRevenue.isEmpty
                      ? const Center(
                          child: Text('Belum ada transaksi minggu ini',
                              style: TextStyle(color: AppColors.textSecondary)))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(
                                show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),

                              // Sumbu Y Kiri (Format Rb/Jt)
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) {
                                      return const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Text('0',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary),
                                            textAlign: TextAlign.right),
                                      );
                                    }

                                    String formattedValue = '';
                                    if (value >= 1000000) {
                                      formattedValue =
                                          '${(value / 1000000).toStringAsFixed(1)} Jt';
                                    } else if (value >= 1000) {
                                      formattedValue =
                                          '${(value / 1000).toInt()} Rb';
                                    } else {
                                      formattedValue = value.toInt().toString();
                                    }

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        formattedValue,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary),
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Sumbu X Bawah (Hari Bahasa Indonesia)
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >=
                                        report.weeklyRevenue.length)
                                      return const Text('');
                                    final dateStr = report
                                        .weeklyRevenue[value.toInt()].date;
                                    final date = DateTime.parse(dateStr);
                                    final dayName =
                                        DateFormat('E', 'id_ID').format(date);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(dayName,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: report.weeklyRevenue
                                .asMap()
                                .entries
                                .map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.revenue,
                                    color: AppColors.accentBlue,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // Produk Terlaris
                const Text('5 Produk Terlaris',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                report.topProducts.isEmpty
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Belum ada data penjualan',
                                style:
                                    TextStyle(color: AppColors.textSecondary))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: report.topProducts.length,
                        itemBuilder: (context, index) {
                          final top = report.topProducts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.warning.withOpacity(0.2),
                                child: Text('#${index + 1}',
                                    style: const TextStyle(
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Text(top.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text('Terjual: ${top.totalSold} item'),
                              trailing: Text(
                                CurrencyFormatter.format(top.totalRevenue),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 40), // Padding bawah
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      {required String title,
      required double amount,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
