class ProductModel {
  final int? id;
  final int categoryId;
  final String? categoryName; // Join field untuk tampilan UI
  final String name;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final String createdAt;

  ProductModel({
    this.id,
    required this.categoryId,
    this.categoryName,
    required this.name,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String?,
      name: map['name'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      stock: map['stock'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'name': name,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'created_at': createdAt,
    };
  }
}