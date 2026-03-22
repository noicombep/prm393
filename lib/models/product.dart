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
  final List<dynamic> reviews; // Assuming reviews are dynamic, can be typed later

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
      categoryId: json['categoryId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      reviews: json['reviews'] ?? [],
    );
  }
}