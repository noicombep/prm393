import 'category.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final int categoryId;
  final bool isActive;
  final String createdAt;
  final Category? category;
  final List<dynamic> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
    this.category,
    this.reviews = const [],
  });

  // ✅ FROM JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      reviews: json['reviews'] ?? [],
    );
  }

  // ✅ TO JSON (QUAN TRỌNG)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': createdAt,
      'category': category?.toJson(),
      'reviews': reviews,
    };
  }
}