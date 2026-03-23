import 'package:dio/dio.dart';
import '../services/session_service.dart';
import 'dart:io';
import 'package:dio/io.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5059/api",
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
      final role = res.data['role'];
      // ✅ dùng SessionService
      await SessionService.saveToken(token, role);
      return true;
    } catch (e) {
      print("LOGIN ERROR: $e");
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
      return false;
    }
  }
}
