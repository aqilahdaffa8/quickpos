import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/report_models.dart';
import '../../data/repositories/report_repository.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  bool _isLoading = false;
  double _totalOmset = 0;
  double _netProfit = 0;
  List<TopProductModel> _topProducts = [];
  List<DailyRevenueModel> _weeklyRevenue = [];

  bool get isLoading => _isLoading;
  double get totalOmset => _totalOmset;
  double get netProfit => _netProfit;
  List<TopProductModel> get topProducts => _topProducts;
  List<DailyRevenueModel> get weeklyRevenue => _weeklyRevenue;

  Future<void> loadReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Setup filter bulan ini secara default
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
      // Akhir bulan dibuat sangat mentok agar transaksi malam hari terbaca
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String(); 

      final summary = await _repository.getSummary(startOfMonth, endOfMonth);
      _totalOmset = summary['omset'] ?? 0.0;
      _netProfit = summary['profit'] ?? 0.0;

      _topProducts = await _repository.getTopProducts(startOfMonth, endOfMonth);
      _weeklyRevenue = await _repository.getWeeklyRevenue();

    } catch (e) {
      debugPrint("Gagal memuat laporan: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}