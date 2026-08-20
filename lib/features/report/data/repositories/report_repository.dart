import '../../../../core/database/db_helper.dart';
import '../models/report_models.dart';

class ReportRepository {
  
  // 1. Dapatkan Total Omset & Laba Bersih berdasarkan rentang tanggal
  Future<Map<String, double>> getSummary(String startDate, String endDate) async {
    final db = await DbHelper.instance.database;
    
    // Query Total Omset (Pendapatan Kotor)
    final revenueResult = await db.rawQuery('''
      SELECT SUM(total_amount) as omset 
      FROM ${DbHelper.tableTransactions} 
      WHERE transaction_date >= ? AND transaction_date <= ?
    ''', [startDate, endDate]);

    // Query Laba Bersih (Harga Jual - Harga Beli) * Kuantitas
    final profitResult = await db.rawQuery('''
      SELECT SUM((ti.price - p.purchase_price) * ti.quantity) as profit
      FROM ${DbHelper.tableTransactionItems} ti
      INNER JOIN ${DbHelper.tableTransactions} t ON ti.transaction_id = t.id
      INNER JOIN ${DbHelper.tableProducts} p ON ti.product_id = p.id
      WHERE t.transaction_date >= ? AND t.transaction_date <= ?
    ''', [startDate, endDate]);

    double omset = (revenueResult.first['omset'] as num?)?.toDouble() ?? 0.0;
    double profit = (profitResult.first['profit'] as num?)?.toDouble() ?? 0.0;

    return {
      'omset': omset,
      'profit': profit,
    };
  }

  // 2. Dapatkan 5 Produk Terlaris
  Future<List<TopProductModel>> getTopProducts(String startDate, String endDate) async {
    final db = await DbHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT p.name, SUM(ti.quantity) as total_sold, SUM(ti.subtotal) as total_revenue
      FROM ${DbHelper.tableTransactionItems} ti
      INNER JOIN ${DbHelper.tableTransactions} t ON ti.transaction_id = t.id
      INNER JOIN ${DbHelper.tableProducts} p ON ti.product_id = p.id
      WHERE t.transaction_date >= ? AND t.transaction_date <= ?
      GROUP BY p.id
      ORDER BY total_sold DESC
      LIMIT 5
    ''', [startDate, endDate]);

    return result.map((row) => TopProductModel(
      productName: row['name'] as String,
      totalSold: row['total_sold'] as int,
      totalRevenue: (row['total_revenue'] as num).toDouble(),
    )).toList();
  }

  // 3. Dapatkan Pendapatan Harian untuk Grafik (7 Hari Terakhir)
  Future<List<DailyRevenueModel>> getWeeklyRevenue() async {
    final db = await DbHelper.instance.database;
    
    // Hitung tanggal 7 hari yang lalu
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6)).toIso8601String();
    final today = DateTime.now().toIso8601String();

    // substr(transaction_date, 1, 10) mengambil string 'YYYY-MM-DD' dari ISO8601
    final result = await db.rawQuery('''
      SELECT substr(transaction_date, 1, 10) as date, SUM(total_amount) as revenue
      FROM ${DbHelper.tableTransactions}
      WHERE transaction_date >= ? AND transaction_date <= ?
      GROUP BY substr(transaction_date, 1, 10)
      ORDER BY date ASC
    ''', [sevenDaysAgo, today]);

    return result.map((row) => DailyRevenueModel(
      date: row['date'] as String,
      revenue: (row['revenue'] as num).toDouble(),
    )).toList();
  }
}