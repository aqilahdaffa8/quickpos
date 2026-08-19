import 'package:flutter/foundation.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:intl/intl.dart';

import 'currency_formatter.dart';
import '../../features/pos/data/models/cart_item_model.dart';

class ThermalPrinterService {
  ThermalPrinterService._();

  // 1. Dapatkan daftar perangkat Bluetooth yang sudah di-pairing ke HP
  static Future<List<BluetoothInfo>> getPairedPrinters() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      debugPrint("Gagal mencari printer: $e");
      return [];
    }
  }

  // 2. Hubungkan ke Mac Address Printer tertentu
  static Future<bool> connectPrinter(String macAddress) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
    } catch (e) {
      debugPrint("Gagal koneksi ke printer: $e");
      return false;
    }
  }

  // 3. Rakit Struk ESC/POS & Cetak
  static Future<bool> printReceipt({
    required int transactionId,
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> items,
  }) async {
    try {
      // Pastikan printer terkoneksi sebelum mencetak
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) return false;

      // Load profil ESC/POS standar dan setel ukuran kertas 58mm
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      final String dateFormatted = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

      // --- MULAI MERAKIT RAW BYTES ESC/POS ---
      
      // HEADER
      bytes += generator.text('QUICKPOS ENTERPRISE', styles: const PosStyles(align: PosAlign.center, bold: true, width: PosTextSize.size2));
      bytes += generator.text('Jl. Teknologi No. 99, Jakarta', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(1);

      // INFO TRANSAKSI
      bytes += generator.text('No. TRX : #TRX-$transactionId');
      bytes += generator.text('Tanggal : $dateFormatted');
      bytes += generator.hr(); // Garis pembatas

      // DAFTAR ITEM BELANJA
      for (var item in items) {
        bytes += generator.text(item.product.name, styles: const PosStyles(bold: true));
        bytes += generator.row([
          PosColumn(text: '${item.quantity} x ${CurrencyFormatter.format(item.product.sellingPrice)}', width: 7),
          PosColumn(text: CurrencyFormatter.format(item.subtotal), width: 5, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      bytes += generator.hr();

      // RINGKASAN PEMBAYARAN
      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: CurrencyFormatter.format(totalAmount), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'TUNAI', width: 6),
        PosColumn(text: CurrencyFormatter.format(cashAmount), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'KEMBALI', width: 6),
        PosColumn(text: CurrencyFormatter.format(changeAmount), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      // FOOTER
      bytes += generator.emptyLines(1);
      bytes += generator.text('Terima Kasih Atas Kunjungan Anda!', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(2); // Gulung kertas sedikit agar mudah disobek

      // KIRIM KE HARDWARE PRINTER
      await PrintBluetoothThermal.writeBytes(bytes);
      return true;
      
    } catch (e) {
      debugPrint("Gagal mencetak thermal: $e");
      return false;
    }
  }
}