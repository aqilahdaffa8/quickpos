import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import class utama aplikasi kita
import 'package:quick_pos/app.dart';

void main() {
  testWidgets('QuickPOS smoke test', (WidgetTester tester) async {
    // 1. Build aplikasi kita dan trigger frame pertama
    await tester.pumpWidget(const QuickPosApp());

    // 2. Verifikasi sederhana: Pastikan MaterialApp berhasil ter-build tanpa crash
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Catatan: Karena tampilan awal adalah Splash Screen, 
    // kita hanya memastikan widget root berhasil dirender.
  });
}