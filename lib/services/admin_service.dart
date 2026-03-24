import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';

class AdminService {
  final String baseUrl = "http://10.0.2.2:5059/api/admin";

  Future<Map<String, String>> _getHeaders() async {
    final token = await SessionService.getToken();

    if (token == null) {
      throw Exception("Token is null");
    }

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// 📦 ORDERS
  Future<List<dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: await _getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load orders: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  /// 👤 USERS
  Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: await _getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load users");
    }

    return jsonDecode(res.body);
  }

  /// 🧸 PRODUCTS
  Future<List<dynamic>> getProducts() async {
    final res = await http.get(
      Uri.parse("$baseUrl/products"),
      headers: await _getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load products");
    }

    return jsonDecode(res.body);
  }

  /// 🔄 UPDATE ORDER STATUS
  Future<void> updateOrderStatus(int id, String status) async {
    final res = await http.put(
      Uri.parse("$baseUrl/orders/$id"),
      headers: await _getHeaders(),
      body: jsonEncode({"status": status}),
    );

    if (res.statusCode != 200) {
      throw Exception("Update failed: ${res.body}");
    }
  }
}