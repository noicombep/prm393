import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử tạo QR cho URL của app hoặc sản phẩm
    const String qrData = "https://shopgau.store";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR to Visit ShopGau"),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Scan this QR code"),
            const SizedBox(height: 32),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}