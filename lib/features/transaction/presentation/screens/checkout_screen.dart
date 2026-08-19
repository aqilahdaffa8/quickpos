import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/providers/cart_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _cashController = TextEditingController();
  double _cashAmount = 0;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 80),
              const SizedBox(height: 16),
              const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Stok otomatis terpotong.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke layar POS
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPayment() async {
    final cartProvider = context.read<CartProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final productProvider = context.read<ProductProvider>();

    final totalAmount = cartProvider.totalAmount;
    final changeAmount = _cashAmount - totalAmount;

    if (changeAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang tunai tidak cukup!'), backgroundColor: AppColors.error),
      );
      return;
    }

    final transactionId = await transactionProvider.processCheckout(
      totalAmount: totalAmount,
      cashAmount: _cashAmount,
      changeAmount: changeAmount,
      cartItems: cartProvider.items,
    );

    if (transactionId != null) {
      // Bersihkan keranjang belanja
      cartProvider.clearCart();
      // MUAT ULANG DATA PRODUK agar stok di POS langsung update!
      await productProvider.loadData();
      
      if (context.mounted) {
        _showSuccessDialog();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan sistem'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isProcessing = context.watch<TransactionProvider>().isProcessing;
    
    final totalAmount = cart.totalAmount;
    final changeAmount = _cashAmount - totalAmount;
    final isValidPayment = changeAmount >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: isProcessing 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan Tagihan Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryNavy, AppColors.primaryBlue]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Tagihan', style: TextStyle(color: AppColors.surfaceWhite, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(totalAmount),
                        style: const TextStyle(color: AppColors.surfaceWhite, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Input Uang Tunai
                const Text('Uang Tunai (Cash)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: _cashController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cashAmount = double.tryParse(value) ?? 0;
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Info Kembalian
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isValidPayment ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isValidPayment ? AppColors.success : AppColors.error),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isValidPayment ? 'Kembalian:' : 'Kurang:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isValidPayment ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(changeAmount.abs()),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isValidPayment ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: (!isValidPayment || totalAmount == 0 || isProcessing) ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              disabledBackgroundColor: AppColors.cardBorder,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('PROSES PEMBAYARAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}