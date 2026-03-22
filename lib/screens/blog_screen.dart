import 'package:flutter/material.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog"),
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BlogPost(
            title: "How to Choose a Teddy Bear",
            content: "Choosing the right teddy bear involves considering size, material, and purpose...",
            imageUrl: "https://api.shopgau.store/images/bear1.jpg",
          ),
          BlogPost(
            title: "Teddy Bears as Gifts",
            content: "Teddy bears make excellent gifts for all occasions...",
            imageUrl: "https://api.shopgau.store/images/bear2.jpg",
          ),
          BlogPost(
            title: "Caring for Your Teddy Bear",
            content: "To keep your teddy bear in top condition, follow these care tips...",
            imageUrl: "https://api.shopgau.store/images/bear3.jpg",
          ),
        ],
      ),
    );
  }
}

class BlogPost extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;

  const BlogPost({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}