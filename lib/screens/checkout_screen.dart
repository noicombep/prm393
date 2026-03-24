import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final detailAddressController = TextEditingController();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final res = await http.get(Uri.parse("https://provinces.open-api.vn/api/p/"));
    setState(() {
      provinces = jsonDecode(res.body);
    });
  }

  Future<void> fetchDistricts(String provinceCode) async {
    final res = await http.get(Uri.parse("https://provinces.open-api.vn/api/p/$provinceCode?depth=2"));
    final data = jsonDecode(res.body);
    setState(() {
      districts = data['districts'] ?? [];
      wards = [];
      selectedDistrict = null;
      selectedWard = null;
    });
  }

  Future<void> fetchWards(String districtCode) async {
    final res = await http.get(Uri.parse("https://provinces.open-api.vn/api/d/$districtCode?depth=2"));
    final data = jsonDecode(res.body);
    setState(() {
      wards = data['wards'] ?? [];
      selectedWard = null;
    });
  }

  void handleOrder() async {
    final cartProvider = context.read<CartProvider>();
    final phone = phoneController.text;
    final detailAddress = detailAddressController.text;

    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');

    if (phone.isEmpty ||
        detailAddress.isEmpty ||
        selectedProvince == null ||
        selectedDistrict == null ||
        selectedWard == null 
) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin ❌")),
      );
      return;
    }

    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ ❌")),
      );
      return;
    }

final provinceName = provinces.firstWhere(
  (p) => p['code'].toString() == selectedProvince,
  orElse: () => {'name': 'Không xác định'},
)['name'];

final districtName = districts.firstWhere(
  (d) => d['code'].toString() == selectedDistrict,
  orElse: () => {'name': 'Không xác định'},
)['name'];

final wardName = wards.firstWhere(
  (w) => w['code'].toString() == selectedWard,
  orElse: () => {'name': 'Không xác định'},
)['name'];

    final fullAddress = "$detailAddress, $wardName, $districtName, $provinceName";

    final request = CreateOrderRequest(
      phone: phone,
      shippingAddress: fullAddress,
      totalPrice: cartProvider.totalPrice,
      items: cartProvider.cart.items.map((e) => OrderItemRequest(
        productName: e.product.name,
        quantity: e.quantity,
        price: e.product.price,
      )).toList(),
    );

    final token = await SessionService.getToken();
    final service = OrderService();
    final res = await service.createOrder(token: token!, request: request);

    final checkoutUrl = res["checkoutUrl"];
    if (checkoutUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentWebView(url: checkoutUrl)),
      );
      return;
    }

    cartProvider.clearCart();
    Navigator.pushReplacementNamed(context, '/order');
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán đơn hàng")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CART
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (cartProvider.cart.items.isEmpty)
                      const Text("Không có sản phẩm trong giỏ hàng")
                    else
                      ...cartProvider.cart.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${item.product.name} x${item.quantity}"),
                            Text("${item.product.price.toStringAsFixed(0)} đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("Tổng: ${cartProvider.totalPrice.toStringAsFixed(0)} đ",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    )
                  ],
                ),
              ),
            ),

            // ADDRESS
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Địa chỉ giao hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Province
                    DropdownButtonFormField<String>(
                      value: selectedProvince,
                      decoration: const InputDecoration(labelText: "Tỉnh / Thành phố"),
                      items: provinces.map<DropdownMenuItem<String>>((p) {
                        return DropdownMenuItem<String>(
                          value: p['code'].toString(),
                          child: Text(p['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() { selectedProvince = val; });
                        if (val != null) fetchDistricts(val);
                      },
                    ),
                    const SizedBox(height: 8),

                    // District
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: const InputDecoration(labelText: "Quận / Huyện"),
                      items: districts.map<DropdownMenuItem<String>>((d) {
                        return DropdownMenuItem<String>(
                          value: d['code'].toString(),
                          child: Text(d['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() { selectedDistrict = val; });
                        if (val != null) fetchWards(val);
                      },
                    ),
                    const SizedBox(height: 8),

                    // Ward
                    DropdownButtonFormField<String>(
                      value: selectedWard,
                      decoration: const InputDecoration(labelText: "Phường / Xã"),
                      items: wards.map<DropdownMenuItem<String>>((w) {
                        return DropdownMenuItem<String>(
                          value: w['code'].toString(),
                          child: Text(w['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() { selectedWard = val; }),
                    ),
                    const SizedBox(height: 8),

                    // Phone
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: "Số điện thoại"),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),

                    // Detail Address
                    TextField(
                      controller: detailAddressController,
                      decoration: const InputDecoration(labelText: "Địa chỉ chi tiết"),
                    ),
                  ],
                ),
              ),
            ),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleOrder,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text("Đặt hàng ${cartProvider.totalPrice.toStringAsFixed(0)} đ", style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}