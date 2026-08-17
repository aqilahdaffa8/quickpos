import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quick_pos/core/theme/app_theme.dart';
import 'package:quick_pos/features/splash/presentation/screens/splash_screen.dart';
import 'package:quick_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quick_pos/features/product/presentation/providers/product_provider.dart';
import 'package:quick_pos/features/product/presentation/screens/product_screen.dart';

class QuickPosApp extends StatelessWidget {
  const QuickPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'QuickPOS UMKM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/products': (context) => const ProductScreen(),
        },
      ),
    );
  }
}