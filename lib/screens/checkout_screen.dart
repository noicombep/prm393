import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import 'payment_webview.dart';
import '../services/session_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final service = OrderService();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                // validate
                if (phoneController.text.isEmpty ||
                    addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nhập đầy đủ info ❌")),
                  );
                  return;
                }

                final request = CreateOrderRequest(
                  phone: phoneController.text,
                  shippingAddress: addressController.text,
                  totalPrice: cartProvider.totalPrice,
                  items: cartProvider.cart.items.map((e) {
                    return OrderItemRequest(
                      productName: e.product.name,
                      quantity: e.quantity,
                      price: e.product.price,
                    );
                  }).toList(),
                );

                final token = await SessionService.getToken();

                final res = await service.createOrder(
                  token: token!,
                  request: request,
                );

                final checkoutUrl = res["checkoutUrl"];

                if (checkoutUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Không lấy được link thanh toán ❌"),
                    ),
                  );
                  return;
                }

                // 🔥 MỞ WEBVIEW
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentWebView(url: checkoutUrl),
                  ),
                );
              },
              child: Text(
                "Thanh toán ${cartProvider.totalPrice.toStringAsFixed(0)} đ",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
