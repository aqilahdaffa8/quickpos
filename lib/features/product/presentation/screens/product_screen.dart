import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().loadData());
  }

  void _showProductForm({ProductModel? product}) {
    final provider = context.read<ProductProvider>();
    final nameController = TextEditingController(text: product?.name ?? '');
    final purchaseController = TextEditingController(text: product != null ? product.purchasePrice.toString() : '');
    final sellingController = TextEditingController(text: product != null ? product.sellingPrice.toString() : '');
    final stockController = TextEditingController(text: product != null ? product.stock.toString() : '');
    
    int? selectedCategory = product?.categoryId ?? (provider.categories.isNotEmpty ? provider.categories.first.id : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product == null ? 'Tambah Produk Baru' : 'Edit Produk',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: provider.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) => selectedCategory = val,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: purchaseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Beli (Rp)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sellingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Jual (Rp)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stok Awal'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedCategory == null) return;
                    
                    final newProduct = ProductModel(
                      id: product?.id,
                      categoryId: selectedCategory!,
                      name: nameController.text,
                      purchasePrice: double.tryParse(purchaseController.text) ?? 0,
                      sellingPrice: double.tryParse(sellingController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      createdAt: product?.createdAt ?? DateTime.now().toIso8601String(),
                    );

                    bool success;
                    if (product == null) {
                      success = await provider.addProduct(newProduct);
                    } else {
                      success = await provider.updateProduct(newProduct);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Produk berhasil disimpan' : 'Gagal menyimpan produk')),
                      );
                    }
                  },
                  child: const Text('Simpan Produk'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk & Inventaris'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('Belum ada produk tersimpan', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProductForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk Pertama'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              // Indikator Stok Berbasis Warna
              Color stockColor = AppColors.success;
              if (product.stock == 0) {
                stockColor = AppColors.error;
              } else if (product.stock <= 5) {
                stockColor = AppColors.warning;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryNavy),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(product.categoryName ?? 'Umum', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(CurrencyFormatter.format(product.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentBlue)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: stockColor),
                              ),
                              child: Text(
                                'Stok: ${product.stock}',
                                style: TextStyle(color: stockColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                                  onPressed: () => _showProductForm(product: product),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                  onPressed: () async {
                                    await provider.deleteProduct(product.id!);
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add, color: AppColors.surfaceWhite),
        onPressed: () => _showProductForm(),
      ),
    );
  }
}