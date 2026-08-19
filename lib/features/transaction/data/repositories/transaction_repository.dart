import '../../../../core/database/db_helper.dart';
import '../../../pos/data/models/cart_item_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

class TransactionRepository {
  
  /// Memproses checkout: Insert Transaksi -> Insert Items -> Potong Stok
  Future<int> processCheckout({
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> cartItems,
  }) async {
    int insertedTransactionId = 0;

    await DbHelper.instance.executeBatchTransaction((txn) async {
      // 1. Simpan data Transaksi Utama
      final transaction = TransactionModel(
        totalAmount: totalAmount,
        cashAmount: cashAmount,
        changeAmount: changeAmount,
        transactionDate: DateTime.now().toIso8601String(),
      );
      
      insertedTransactionId = await txn.insert(
        DbHelper.tableTransactions,
        transaction.toMap(),
      );

      // 2. Simpan setiap Item & Potong Stok Produk
      for (final item in cartItems) {
        final transactionItem = TransactionItemModel(
          transactionId: insertedTransactionId,
          productId: item.product.id!,
          quantity: item.quantity,
          price: item.product.sellingPrice,
          subtotal: item.subtotal,
        );

        // Insert item ke keranjang riwayat
        await txn.insert(
          DbHelper.tableTransactionItems,
          transactionItem.toMap(),
        );

        // UPDATE (Potong) Stok Produk secara langsung di Database
        await txn.rawUpdate(
          '''
          UPDATE ${DbHelper.tableProducts} 
          SET stock = stock - ? 
          WHERE id = ?
          ''',
          [item.quantity, item.product.id],
        );
      }
    });

    return insertedTransactionId; // Mengembalikan ID Transaksi untuk cetak struk nanti
  }
}