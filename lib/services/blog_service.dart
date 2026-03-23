import 'package:dio/dio.dart';
import 'session_service.dart';

class BlogService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:5059/api"));

  Future<List<dynamic>> getTopBlogs() async {
    final res = await _dio.get("/blog/top");
    return res.data;
  }

  Future<void> likeBlog(int id) async {
    await _dio.post("/blog/$id/like");
  }

  Future<void> createBlog(String title, String content, String imageUrl) async {
    final token = await SessionService.getToken();

    await _dio.post(
      "/blog/blogs",
      data: {"title": title, "content": content, "imageUrl": imageUrl},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
