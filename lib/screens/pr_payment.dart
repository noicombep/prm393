import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'payment_success_screen.dart';
import '../services/session_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
class PaymentQrScreen extends StatefulWidget {
  final int orderId;
  final String qrCode;

  const PaymentQrScreen({
    super.key,
    required this.orderId,
    required this.qrCode,
  });

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  String status = "WAITING";

  @override
  void initState() {
    super.initState();
    pollPayment();
  }

  Future<void> pollPayment() async {
    final service = OrderService();
    final token = await SessionService.getToken();

    while (status == "WAITING") {
      await Future.delayed(const Duration(seconds: 3));

      final result = await service.checkPayment(widget.orderId, token!);

      if (!mounted) return;

      setState(() => status = result);

      if (result == "PAID") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PaymentSuccessScreen(),
          ),
        );
        break;
      }

      if (result == "CANCEL") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán thất bại ❌")),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quét QR thanh toán")),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: widget.qrCode, // 🔥 đúng ở đây
            size: 250,
          ),

          const SizedBox(height: 20),

          const Text("Dùng app ngân hàng để quét"),

          const SizedBox(height: 10),

          Text("Status: $status"),
        ],
      ),
    );
  }
}