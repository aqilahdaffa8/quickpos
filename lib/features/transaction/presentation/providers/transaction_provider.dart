import 'package:flutter/foundation.dart';
import '../../../pos/data/models/cart_item_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  Future<int?> processCheckout({
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> cartItems,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final transactionId = await _repository.processCheckout(
        totalAmount: totalAmount,
        cashAmount: cashAmount,
        changeAmount: changeAmount,
        cartItems: cartItems,
      );
      
      _isProcessing = false;
      notifyListeners();
      return transactionId;
    } catch (e) {
      debugPrint("Error saat proses checkout: $e");
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}