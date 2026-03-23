import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String formatPrice(double price) {
    return "${price.toStringAsFixed(0)} đ";
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.pink,
      ),

      body: cart.items.isEmpty
          ? const Center(child: Text("Cart is empty"))

          : Column(
              children: [
                // 🛒 LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.grey.withOpacity(0.2),
                            )
                          ],
                        ),

                        child: Row(
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "https://api.shopgau.store${item.product.imageUrl}",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image, size: 50),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    formatPrice(item.product.price),
                                    style: const TextStyle(
                                      color: Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // QUANTITY + DELETE
                            Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        int newQty = item.quantity - 1;
                                        cartProvider.updateQuantity(
                                          item.product.id,
                                          newQty,
                                        );
                                      },
                                    ),

                                    Text(
                                      "${item.quantity}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),

                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        int newQty = item.quantity + 1;

                                        if (newQty <= item.product.stock) {
                                          cartProvider.updateQuantity(
                                            item.product.id,
                                            newQty,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text("Vượt quá tồn kho ❌"),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    cartProvider.removeFromCart(
                                        item.product.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 💰 TOTAL
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.withOpacity(0.3),
                      )
                    ],
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            formatPrice(cartProvider.totalPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Checkout coming soon")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          child: const Text("Checkout"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}