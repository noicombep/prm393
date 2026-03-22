import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "MemoSoft 🧸",
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.pink),
            onPressed: () => Navigator.pushNamed(context, "/cart"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                Image.asset(
                  "assets/banner.jpg",
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 400,
                  color: Colors.pink.withValues(alpha: 0.4),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Welcome to MemoSoft 🧸",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Discover the coziest teddy bears",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/products");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.pink,
                              ),
                              child: const Text("Shop Now"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/send-qr");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Create QR"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Featured Products Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Featured Products",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                "https://api.shopgau.store/images/bear${index + 1}.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Teddy Bear ${index + 1}"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Why Choose Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  Text("Why Choose MemoSoft?",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoCard("Ultra Soft Material",
                          "https://api.shopgau.store/images/bear4.jpg"),
                      InfoCard("Unique Cute Designs",
                          "https://api.shopgau.store/images/bear6.jpg"),
                      InfoCard("Perfect Gift",
                          "https://api.shopgau.store/images/bear7.jpg"),
                    ],
                  )
                ],
              ),
            ),

            // How it Works Section
            Container(
              color: Colors.pink.shade50,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  Text("Shopping Made Simple",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      StepItem("🧸", "Choose a Teddy",
                          "Browse our lovely collection."),
                      StepItem("🛒", "Add to Cart",
                          "Pick your favorite bear."),
                      StepItem("💳", "Secure Checkout",
                          "Pay easily and safely."),
                      StepItem("📦", "Fast Delivery",
                          "Receive at your door."),
                    ],
                  )
                ],
              ),
            ),

            // Trending Bears Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Trending Teddy Bears",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(3, (index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://api.shopgau.store/images/bear${index + 1}.jpg",
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Blog Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("From Our Blog",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _blogCard("How to Choose a Teddy",
                          "https://api.shopgau.store/images/bear1.jpg")),
                      Expanded(child: _blogCard("Teddy Bears as Gifts",
                          "https://api.shopgau.store/images/bear2.jpg")),
                      Expanded(child: _blogCard("Caring for Your Teddy",
                          "https://api.shopgau.store/images/bear3.jpg")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, "/blog"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: const Text("View All Blog Posts"),
                  )
                ],
              ),
            ),

            // CTA Section
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    "Ready to find your perfect cuddle buddy?",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/products");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Browse All Products"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, "/products");
              break;
            case 2:
              Navigator.pushNamed(context, "/cart");
              break;
            case 3:
              Navigator.pushNamed(context, "/account");
              break;
          }
        },
      ),
    );
  }
}

// Step Item cho phần "How it Works"
class StepItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  const StepItem(this.icon, this.title, this.desc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          desc,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Blog Card cho phần Blog Section
Widget _blogCard(String title, String imgUrl) {
  return Card(
    margin: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(imgUrl, height: 120, fit: BoxFit.cover, width: double.infinity),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

class InfoCard extends StatelessWidget {
  final String title;
  final String imgUrl;

  const InfoCard(this.title, this.imgUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Image.network(imgUrl, height: 80, fit: BoxFit.cover),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
