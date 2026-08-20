class ProductModel {
  final int? id;
  final int categoryId;
  final String? categoryName;
  final String name;
  final String? imagePath; // <-- PROPERTI BARU
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final String createdAt;

  ProductModel({
    this.id,
    required this.categoryId,
    this.categoryName,
    required this.name,
    this.imagePath, // <-- PROPERTI BARU
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
      imagePath: map['image_path'] as String?, // <-- MAPPING BARU
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
      'image_path': imagePath, // <-- MAPPING BARU
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'created_at': createdAt,
    };
  }
}