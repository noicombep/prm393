import 'order_item.dart';

class Order {
  final int id;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final String statusFee;
  final String phone;
  final String shippingAddress;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.statusFee,
    required this.phone,
    required this.shippingAddress,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      createdAt: DateTime.parse(json["createdAt"]),
      totalAmount: (json["totalAmount"] as num).toDouble(),
      status: json["status"],
      statusFee: json["statusFee"], // ✅ đúng backend
      phone: json["phone"] ?? "",
      shippingAddress: json["shippingAddress"] ?? "",
      items: (json["items"] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}