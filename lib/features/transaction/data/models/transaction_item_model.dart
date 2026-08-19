class TransactionItemModel {
  final int? id;
  final int transactionId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}