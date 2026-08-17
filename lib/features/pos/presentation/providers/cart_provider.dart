import 'package:flutter/foundation.dart';
import '../../data/models/cart_item_model.dart';
import '../../../product/data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  // Menghitung total harga semua barang di keranjang
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Menghitung total kuantitas barang
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Tambah ke keranjang dengan VALIDASI STOK
  void addToCart(ProductModel product) {
    // Cari apakah produk sudah ada di keranjang
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Jika sudah ada, tambah quantity JIKA stok masih mencukupi
      if (_items[existingIndex].quantity < product.stock) {
        _items[existingIndex].quantity++;
        notifyListeners();
      }
    } else {
      // Jika belum ada, pastikan stok lebih dari 0 sebelum ditambah
      if (product.stock > 0) {
        _items.add(CartItemModel(product: product, quantity: 1));
        notifyListeners();
      }
    }
  }

  // Kurangi kuantitas atau hapus jika 0
  void decrementItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  // Hapus satu jenis produk dari keranjang sepenuhnya
  void removeFromCart(ProductModel product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  // Kosongkan keranjang (dipanggil setelah transaksi sukses atau dibatalkan)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}