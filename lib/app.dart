import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quick_pos/core/theme/app_theme.dart';
import 'package:quick_pos/features/splash/presentation/screens/splash_screen.dart';
import 'package:quick_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:quick_pos/features/product/presentation/providers/product_provider.dart';
import 'package:quick_pos/features/product/presentation/screens/product_screen.dart';
import 'package:quick_pos/features/category/presentation/providers/category_provider.dart'; // Import Category Provider
import 'package:quick_pos/features/category/presentation/screens/category_screen.dart';
import 'package:quick_pos/features/pos/presentation/providers/cart_provider.dart';
import 'package:quick_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:quick_pos/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:quick_pos/features/transaction/presentation/screens/checkout_screen.dart';
import 'package:quick_pos/features/report/presentation/providers/report_provider.dart';
import 'package:quick_pos/features/report/presentation/screens/report_screen.dart';

class QuickPosApp extends StatelessWidget {
  const QuickPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'QuickPOS UMKM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/categories': (context) => const CategoryScreen(),
          '/products': (context) => const ProductScreen(),
          '/pos': (context) => const POSScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/reports': (context) => const ReportScreen(),
        },
      ),
    );
  }
}