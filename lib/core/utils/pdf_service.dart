import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'currency_formatter.dart';
import '../../features/pos/data/models/cart_item_model.dart';

class PdfService {
  PdfService._();

  static Future<void> generateAndShareReceipt({
    required int transactionId,
    required double totalAmount,
    required double cashAmount,
    required double changeAmount,
    required List<CartItemModel> items,
  }) async {
    final pdf = pw.Document();

    // Format tanggal transaksi
    final String dateFormatted = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        // Menggunakan ukuran kertas Roll 80mm (standar thermal printer POS)
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Toko
              pw.Center(
                child: pw.Text(
                  'QUICKPOS ENTERPRISE',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Jl. Teknologi No. 99, Jakarta',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 12),
              
              // Info Transaksi
              pw.Text('No. Transaksi : #TRX-$transactionId', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Tanggal       : $dateFormatted', style: const pw.TextStyle(fontSize: 10)),
              
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              
              // Daftar Item Belanja
              ...items.map((item) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.product.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.product.sellingPrice)}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              
              // Ringkasan Pembayaran
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(CurrencyFormatter.format(totalAmount), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TUNAI', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(CurrencyFormatter.format(cashAmount), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('KEMBALI', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(CurrencyFormatter.format(changeAmount), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              
              pw.SizedBox(height: 16),
              
              // Footer
              pw.Center(
                child: pw.Text(
                  'Terima Kasih Atas Kunjungan Anda!',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Barang yang sudah dibeli tidak dapat ditukar',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Dapatkan direktori temporary sistem OS untuk menyimpan file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Struk_TRX_$transactionId.pdf');
      
      // Tulis byte PDF ke dalam file
      await file.writeAsBytes(await pdf.save());

      // Bagikan file menggunakan Native Share (WhatsApp, Email, Bluetooth Printer)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Terlampir struk belanja untuk transaksi #TRX-$transactionId',
      );
    } catch (e) {
      debugPrint("Gagal mencetak struk: $e");
    }
  }
}