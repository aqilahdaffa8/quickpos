import '../../../product/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  // Getter untuk menghitung subtotal secara dinamis
  double get subtotal => product.sellingPrice * quantity;
}