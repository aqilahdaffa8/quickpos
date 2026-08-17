import 'package:sqflite/sqflite.dart';
import '../../../../core/database/db_helper.dart';
import '../../../category/data/models/category_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  // --- KATEGORI METHODS ---
  
  Future<List<CategoryModel>> getCategories() async {
    final db = await DbHelper.instance.database;
    final result = await db.query(DbHelper.tableCategories, orderBy: 'name ASC');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> insertCategory(String name) async {
    final db = await DbHelper.instance.database;
    return await db.insert(
      DbHelper.tableCategories,
      CategoryModel(name: name, createdAt: DateTime.now().toIso8601String()).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- PRODUK METHODS ---

  Future<List<ProductModel>> getProducts() async {
    final db = await DbHelper.instance.database;
    // Menggunakan Raw SQL JOIN untuk mengambil nama kategori sekaligus
    final result = await db.rawQuery('''
      SELECT p.*, c.name as category_name 
      FROM ${DbHelper.tableProducts} p
      INNER JOIN ${DbHelper.tableCategories} c ON p.category_id = c.id
      ORDER BY p.name ASC
    ''');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await DbHelper.instance.database;
    return await db.insert(
      DbHelper.tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      DbHelper.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      DbHelper.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}