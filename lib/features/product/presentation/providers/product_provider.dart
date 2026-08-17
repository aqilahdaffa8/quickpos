import 'package:flutter/foundation.dart';
import '../../../category/data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint("Error loading product data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(String name) async {
    try {
      await _repository.insertCategory(name);
      await loadData();
      return true;
    } catch (e) {
      debugPrint("Error adding category: $e");
      return false;
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      await _repository.insertProduct(product);
      await loadData();
      return true;
    } catch (e) {
      debugPrint("Error adding product: $e");
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      await loadData();
      return true;
    } catch (e) {
      debugPrint("Error updating product: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
      await loadData();
      return true;
    } catch (e) {
      debugPrint("Error deleting product: $e");
      return false;
    }
  }
}