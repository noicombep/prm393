import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/order_service.dart';
import '../services/session_service.dart';
import '../providers/cart_provider.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController controller;
  Future<void> _clearCartAndNavigate() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.clearCart();
    if (!mounted) return; // check nếu widget đã dispose
    Navigator.pushReplacementNamed(context, "/success");
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            print("URL: ${request.url}");

            final uri = Uri.parse(request.url);

            // ✅ SUCCESS
            if (request.url.contains("payment-success")) {
              final orderId = int.tryParse(
                uri.queryParameters['orderCode'] ?? "",
              );

              if (orderId == null) {
                print("Không lấy được orderId");
                return NavigationDecision.prevent;
              }

              final service = OrderService();
              final token = await SessionService.getToken();

              final result = await service.checkPayment(orderId, token!);

              if (result == "PAID") {
                await _clearCartAndNavigate();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chưa xác nhận thanh toán")),
                );
              }

              return NavigationDecision.prevent;
            }

            // ❌ CANCEL
            if (request.url.contains("payment-cancel")) {
              if (!mounted) return NavigationDecision.prevent;

              // 1️⃣ Nếu đang push PaymentWebView từ CartScreen, chỉ cần pop
              Navigator.pop(context);

              // 2️⃣ Nếu muốn chắc chắn luôn về CartScreen:
              // Navigator.pushReplacementNamed(context, "/cart");

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: WebViewWidget(controller: controller),
    );
  }
}
