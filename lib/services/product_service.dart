import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5059/api", // Giả sử API này
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<List<Product>> getProducts() async {
    try {
      final res = await _dio.get("/products");
      final List<dynamic> data = res.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      // Nếu API không có, trả về dữ liệu giả
      return _getMockProducts();
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final res = await _dio.get("/products/$id");
      return Product.fromJson(res.data);
    } catch (e) {
      // Mock
      return _getMockProducts().firstWhere((p) => p.id == id);
    }
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: 1,
        name: "Teddy Bear 1",
        description: "A cute teddy bear.",
        price: 29.99,
        stock: 10,
        imageUrl: "https://api.shopgau.store/images/bear1.jpg",
        categoryId: 1,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
      Product(
        id: 2,
        name: "Teddy Bear 2",
        description: "Soft and cuddly.",
        price: 34.99,
        stock: 5,
        imageUrl: "https://api.shopgau.store/images/bear2.jpg",
        categoryId: 1,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
      Product(
        id: 3,
        name: "Teddy Bear 3",
        description: "Perfect gift.",
        price: 39.99,
        stock: 8,
        imageUrl: "https://api.shopgau.store/images/bear3.jpg",
        categoryId: 2,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
      Product(
        id: 4,
        name: "Teddy Bear 4",
        description: "Ultra soft.",
        price: 44.99,
        stock: 12,
        imageUrl: "https://api.shopgau.store/images/bear4.jpg",
        categoryId: 2,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
      Product(
        id: 5,
        name: "Teddy Bear 5",
        description: "Unique design.",
        price: 49.99,
        stock: 3,
        imageUrl: "https://api.shopgau.store/images/bear5.jpg",
        categoryId: 3,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
      Product(
        id: 6,
        name: "Teddy Bear 6",
        description: "Cute and fun.",
        price: 54.99,
        stock: 7,
        imageUrl: "https://api.shopgau.store/images/bear6.jpg",
        categoryId: 3,
        isActive: true,
        createdAt: "2026-01-01T00:00:00.000",
      ),
    ];
  }
}
