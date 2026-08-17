import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import untuk cek platform Web
import 'package:quick_pos/app.dart';
import 'package:quick_pos/core/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Orientasi & Overlay tidak berlaku di Web, tapi aman untuk dibiarkan
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

  // Mencegah Crash di Web dengan melakukan bypass inisialisasi SQLite
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