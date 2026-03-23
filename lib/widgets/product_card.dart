import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool addingToCart = false;

  // Fake cart (sau này thay bằng Provider)
  static Map<int, int> cart = {};

  String formatPrice(double price) {
    return "${price.toStringAsFixed(0)} đ";
  }

  void showMessage(String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

Future<void> handleAddToCart() async {
  final product = widget.product;

  setState(() => addingToCart = true);

  await Future.delayed(const Duration(milliseconds: 300));

  final cartProvider = context.read<CartProvider>();

  final success = cartProvider.addToCart(product);

  if (success) {
    showMessage("Đã thêm vào giỏ 🛒", true);
  } else {
    final currentQty = cartProvider.getQuantity(product.id);

    if (product.stock == 0) {
      showMessage("Hết hàng ❌", false);
    } else {
      showMessage(
        "Chỉ còn ${product.stock - currentQty} sản phẩm",
        false,
      );
    }
  }

  setState(() => addingToCart = false);
}

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-detail',
            arguments: product.id,
          );
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    "https://api.shopgau.store${product.imageUrl}",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(
                            child: Icon(Icons.broken_image,
                                size: 64, color: Colors.grey)),
                  ),

                  // Overlay hết hàng
                  if (product.stock == 0)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      alignment: Alignment.center,
                      child: const Text(
                        "Out of Stock",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (product.category != null)
                    Text(
                      product.category!.name,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Footer (price + button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatPrice(product.price),
                        style: const TextStyle(
                          color: Colors.pink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: (addingToCart || product.stock == 0)
                            ? null
                            : () {
                                handleAddToCart();
                              },
                        icon: addingToCart
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_cart),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}