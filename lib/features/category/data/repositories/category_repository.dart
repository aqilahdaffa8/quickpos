import 'package:sqflite/sqflite.dart';
import '../../../../core/database/db_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
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

  Future<int> updateCategory(CategoryModel category) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      DbHelper.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      DbHelper.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}