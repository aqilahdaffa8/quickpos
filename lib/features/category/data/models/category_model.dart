class CategoryModel {
  final int? id;
  final String name;
  final String? iconName; // PROPERTI BARU
  final String createdAt;

  CategoryModel({
    this.id,
    required this.name,
    this.iconName,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String?, // MAPPING BARU
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_name': iconName, // MAPPING BARU
      'created_at': createdAt,
    };
  }
}