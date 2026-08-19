import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_pos/features/pos/data/models/cart_item_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/presentation/providers/cart_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/utils/pdf_service.dart';
import '../../../../core/utils/thermal_printer_service.dart';

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

  void _showSuccessDialog({
    required int transactionId,
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> items,
  }) {
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
              Text('#TRX-$transactionId', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // OPSI 1: CETAK BLUETOOTH THERMAL
              ElevatedButton.icon(
                onPressed: () => _showPrinterSelectionDialog(
                  transactionId: transactionId,
                  totalAmount: totalAmount,
                  cashAmount: cashAmount,
                  changeAmount: changeAmount,
                  items: items,
                ),
                icon: const Icon(Icons.print, color: AppColors.surfaceWhite),
                label: const Text('Cetak Struk Thermal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 12),

              // OPSI 2: SHARE DIGITAL PDF
              OutlinedButton.icon(
                onPressed: () async {
                  await PdfService.generateAndShareReceipt(
                    transactionId: transactionId,
                    totalAmount: totalAmount,
                    cashAmount: cashAmount,
                    changeAmount: changeAmount,
                    items: items,
                  );
                },
                icon: const Icon(Icons.share, color: AppColors.accentBlue),
                label: const Text('Bagikan Struk Digital (PDF)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  side: const BorderSide(color: AppColors.accentBlue),
                ),
              ),
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke POS
                },
                child: const Text('Selesai, Kembali ke Kasir', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- LOGIKA SCAN BLUETOOTH PRINTER ---
  void _showPrinterSelectionDialog({
    required int transactionId,
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> items,
  }) async {
    // Tampilkan loading saat scanning Bluetooth
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final printers = await ThermalPrinterService.getPairedPrinters();
    
    if (context.mounted) Navigator.pop(context); // Tutup loading

    if (printers.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada printer Bluetooth yang ter-pairing di HP ini.')),
        );
      }
      return;
    }

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Pilih Printer Thermal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final printer = printers[index];
                    return ListTile(
                      leading: const Icon(Icons.print, color: AppColors.accentBlue),
                      title: Text(printer.name),
                      subtitle: Text(printer.macAdress),
                      onTap: () async {
                        Navigator.pop(context); // Tutup list printer
                        
                        // Eksekusi Koneksi & Cetak
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Menghubungkan ke ${printer.name}...')),
                        );
                        
                        bool isConnected = await ThermalPrinterService.connectPrinter(printer.macAdress);
                        if (isConnected) {
                          bool printed = await ThermalPrinterService.printReceipt(
                            transactionId: transactionId,
                            totalAmount: totalAmount,
                            cashAmount: cashAmount,
                            changeAmount: changeAmount,
                            items: items,
                          );
                          
                          if (printed && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Struk berhasil dicetak!'), backgroundColor: AppColors.success),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal terhubung ke printer.'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
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

    // SIMPAN DATA KERANJANG SEMENTARA SEBELUM DI CLEAR (Untuk PDF)
    final purchasedItems = List<CartItemModel>.from(cartProvider.items);

    final transactionId = await transactionProvider.processCheckout(
      totalAmount: totalAmount,
      cashAmount: _cashAmount,
      changeAmount: changeAmount,
      cartItems: purchasedItems,
    );

    if (transactionId != null) {
      cartProvider.clearCart();
      await productProvider.loadData(); // Update stok di UI Kasir
      
      if (context.mounted) {
        _showSuccessDialog(
          transactionId: transactionId,
          totalAmount: totalAmount,
          cashAmount: _cashAmount,
          changeAmount: changeAmount,
          items: purchasedItems,
        );
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