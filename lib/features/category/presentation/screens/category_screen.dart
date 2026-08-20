import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryProvider>().loadCategories());
  }

  void _showCategoryForm({CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.iconName ?? 'restaurant'; // Default ikon pertama

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceWhite,
              title: Text(
                category == null ? 'Tambah Kategori' : 'Edit Kategori',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Kategori'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Ikon:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    
                    // Grid Pilihan Ikon
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: IconMapper.availableIcons.entries.map((entry) {
                        final isSelected = selectedIcon == entry.key;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = entry.key;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentBlue.withOpacity(0.2) : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.accentBlue : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              entry.value,
                              color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final provider = context.read<CategoryProvider>();
                    bool success;

                    if (category == null) {
                      success = await provider.addCategory(nameController.text, selectedIcon);
                    } else {
                      final updatedCategory = CategoryModel(
                        id: category.id,
                        name: nameController.text,
                        iconName: selectedIcon,
                        createdAt: category.createdAt,
                      );
                      success = await provider.updateCategory(updatedCategory);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Kategori berhasil disimpan' : 'Gagal menyimpan kategori'),
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
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
        title: const Text('Kelola Kategori'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kategori',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconMapper.getIcon(category.iconName),
                      color: AppColors.accentBlue,
                    ),
                  ),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                        onPressed: () => _showCategoryForm(category: category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () async {
                          final success = await provider.deleteCategory(category.id!);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal: Kategori ini sedang digunakan oleh produk!'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () => _showCategoryForm(),
        child: const Icon(Icons.add, color: AppColors.surfaceWhite),
      ),
    );
  }
}