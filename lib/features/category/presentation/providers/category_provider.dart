import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(String name) async {
    try {
      await _repository.insertCategory(name);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error adding category: $e");
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      // Perhatian: Karena kita menggunakan SQLite RESTRICT di tabel products, 
      // kategori tidak akan bisa dihapus jika masih ada produk yang menggunakannya.
      await _repository.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint("Error deleting category (mungkin sedang digunakan oleh produk): $e");
      return false;
    }
  }
}