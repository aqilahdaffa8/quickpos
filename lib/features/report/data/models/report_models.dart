class TopProductModel {
  final String productName;
  final int totalSold;
  final double totalRevenue;

  TopProductModel({
    required this.productName,
    required this.totalSold,
    required this.totalRevenue,
  });
}

class DailyRevenueModel {
  final String date; // Format: YYYY-MM-DD
  final double revenue;

  DailyRevenueModel({
    required this.date,
    required this.revenue,
  });
}