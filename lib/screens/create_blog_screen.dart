import 'package:flutter/material.dart';
import '../services/blog_service.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageController = TextEditingController();
  final service = BlogService();

  void _submit() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nhập đầy đủ dữ liệu")));
      return;
    }

    await service.createBlog(
      titleController.text,
      contentController.text,
      imageController.text,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Blog"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Content"),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text("Post")),
          ],
        ),
      ),
    );
  }
}
