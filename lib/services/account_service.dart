import 'package:dio/dio.dart';
import '../models/account.dart';
import 'session_service.dart';

class AccountService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5059/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  // 🔐 Gắn token
  Future<void> _setAuthHeader() async {
    final token = await SessionService.getToken();
    if (token != null) {
      _dio.options.headers["Authorization"] = "Bearer $token";
    }
  }

  // 👥 Lấy danh sách customer
  Future<List<Account>> getCustomers() async {
    try {
      await _setAuthHeader();

      final res = await _dio.get("/auth/customers");

      final data = res.data as List;

      return data.map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Không thể tải danh sách khách hàng");
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _dio.put("/auth/users/$id", data: data);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete("/auth/users/$id");
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await SessionService.getToken();

    final res = await _dio.get(
      "/auth/me",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return res.data;
  }

  Future<void> updateMe(Map<String, dynamic> data) async {
    final token = await SessionService.getToken();

    await _dio.put(
      "/auth/me",
      data: data,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    final token = await SessionService.getToken();

    await _dio.put(
      "/auth/change-password",
      data: {"oldPassword": oldPass, "newPassword": newPass},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}








//  AuthService() {
//     (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//         (client) {
//           client.badCertificateCallback =
//               (X509Certificate cert, String host, int port) => true;
//           return client;
//         };
//   }