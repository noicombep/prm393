import 'package:dio/dio.dart';
import '../services/session_service.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.shopgau.store/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      final token = res.data['token'];

      // ✅ dùng SessionService
      await SessionService.saveToken(token);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await _dio.post(
        "/auth/register",
        data: {"username": username, "email": email, "password": password},
      );
      return true;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data != null && data['message'] != null) {
          throw data['message'];
        }
        if (data != null && data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw firstError.first.toString();
          }
        }
      }
      throw "Register failed";
    }
  }
}
