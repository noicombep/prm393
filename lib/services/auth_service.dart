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
      await SessionService.saveToken(token);

      return true;
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          throw data['message'];
        }
      }
      throw "Login failed";
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _dio.post(
        "/auth/register",
        data: {"username": username, "email": email, "password": password},
      );
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        // print("Status: ${e.response?.statusCode}");
        // print("Data: ${e.response?.data}");
        // print("Data type: ${e.response?.data.runtimeType}");
        if (data != null && data['message'] != null) {
          throw data['message'];
        }
        if (data is Map && data['message'] != null) {
          throw data['message'];
        }
      }
      throw "Register failed";
    }
  }

  Future<void> verifyOtp(
    String username,
    String email,
    String password,
    String otp,
  ) async {
    print("Gửi lên: username=$username, email=$email, otp=$otp");
    try {
      final res = await _dio.post(
        "/auth/verify-otp",
        data: {
          "username": username,
          "email": email,
          "password": password,
          "otp": otp,
        },
      );
      print("Response: ${res.data}");
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        // if (data is Map && data['errors'] != null) {
        //   final errors = data['errors'] as Map;
        //   final firstError = errors
        //       .values
        //       .first;
        //   if (firstError is List && firstError.isNotEmpty) {
        //     throw firstError.first.toString();
        //   }
        // }
        if (data is String && data.isNotEmpty) {
          throw data;
        }
      }
      throw "OTP không hợp lệ";
    }
  }
}
