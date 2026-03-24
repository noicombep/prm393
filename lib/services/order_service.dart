import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';
import '../models/order_his.dart';
import '../models/order.dart';

class OrderService {
  final String baseUrl = "http://10.0.2.2:5059/api/order";

  Future<Map<String, dynamic>> createOrder({
    required String token,
    required CreateOrderRequest request,
  }) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body);
  }

Future<String> checkPayment(int orderId, String token) async {
  final res = await http.get(
    Uri.parse("$baseUrl/check-payment/$orderId"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(res.body);

  // 🔥 FIX: convert sang String
  return data["status"].toString();
}
Future<List<Order>> getMyOrders() async {
  final token = await SessionService.getToken();

  final res = await http.get(
    Uri.parse("$baseUrl/my-orders"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }

  final List data = jsonDecode(res.body);

  return data.map((e) => Order.fromJson(e)).toList();
}
}