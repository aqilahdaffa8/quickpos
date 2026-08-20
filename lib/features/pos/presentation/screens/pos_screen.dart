import 'dart:io'; // IMPORT FILE UNTUK MEMBACA GAMBAR LOKAL
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../../transaction/presentation/screens/checkout_screen.dart'; // Pastikan rute/import ini sesuai

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadData());
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Detail Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                            label: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: cart.items.isEmpty
                          ? const Center(child: Text('Keranjang kosong', style: TextStyle(color: AppColors.textSecondary)))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return ListTile(
                                  title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(CurrencyFormatter.format(item.product.sellingPrice)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                                        onPressed: () => cart.decrementItem(item.product),
                                      ),
                                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
                                        onPressed: () {
                                          if (item.quantity < item.product.stock) {
                                            cart.addToCart(item.product);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Stok tidak mencukupi!')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Belanja:', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                              Text(
                                CurrencyFormatter.format(cart.totalAmount),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: cart.items.isEmpty ? null : () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/checkout');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Lanjut ke Pembayaran', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesin Kasir (POS)'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProv, child) {
          if (productProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProv.products.isEmpty) {
            return const Center(child: Text('Belum ada produk untuk dijual.', style: TextStyle(color: AppColors.textSecondary)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: productProv.products.length,
            itemBuilder: (context, index) {
              final product = productProv.products[index];
              final isOutOfStock = product.stock <= 0;

              return InkWell(
                onTap: isOutOfStock
                    ? null
                    : () {
                        context.read<CartProvider>().addToCart(product);
                      },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  color: isOutOfStock ? AppColors.backgroundLight : AppColors.surfaceWhite,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // --- GAMBAR PRODUK DI GRID POS ---
                        Expanded(
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                image: product.imagePath != null
                                    ? DecorationImage(
                                        image: FileImage(File(product.imagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.imagePath == null
                                  ? Icon(
                                      Icons.shopping_bag,
                                      size: 48,
                                      color: isOutOfStock ? AppColors.cardBorder : AppColors.accentBlue,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        // ---------------------------------

                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(product.sellingPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock ? AppColors.textMuted : AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOutOfStock ? AppColors.error.withOpacity(0.1) : AppColors.primaryNavy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isOutOfStock ? 'Habis' : 'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOutOfStock ? AppColors.error : AppColors.primaryNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      bottomSheet: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () => _showCartBottomSheet(context),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(color: AppColors.surfaceWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Keranjang',
                        style: TextStyle(color: AppColors.surfaceWhite, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(cart.totalAmount),
                        style: const TextStyle(color: AppColors.surfaceWhite, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_up, color: AppColors.surfaceWhite),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}