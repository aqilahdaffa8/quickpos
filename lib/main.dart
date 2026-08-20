import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// --- 1. TAMBAHKAN IMPORT INI ---
import 'package:intl/date_symbol_data_local.dart'; 

import 'package:quick_pos/app.dart';
import 'package:quick_pos/core/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- 2. INISIALISASI LOCALE TANGGAL BAHASA INDONESIA ---
  await initializeDateFormatting('id_ID', null);
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  if (kIsWeb) {
    debugPrint("⚠️ RUNNING ON WEB: Bypassing SQLite Initialization for UI Preview.");
  } else {
    try {
      await DbHelper.instance.database;
      debugPrint("✅ ENTERPRISE DB INIT SUCCESS: quickpos_enterprise.db siap digunakan.");
    } catch (e) {
      debugPrint("❌ DB INIT FAILED: $e");
    }
  }

  runApp(const QuickPosApp());
}