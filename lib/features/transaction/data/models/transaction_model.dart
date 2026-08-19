class TransactionModel {
  final int? id;
  final double totalAmount;
  final double cashAmount;
  final double changeAmount;
  final String transactionDate;

  TransactionModel({
    this.id,
    required this.totalAmount,
    required this.cashAmount,
    required this.changeAmount,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'total_amount': totalAmount,
      'cash_amount': cashAmount,
      'change_amount': changeAmount,
      'transaction_date': transactionDate,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      cashAmount: (map['cash_amount'] as num).toDouble(),
      changeAmount: (map['change_amount'] as num).toDouble(),
      transactionDate: map['transaction_date'] as String,
    );
  }
}