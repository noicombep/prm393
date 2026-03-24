class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json["productName"],
      quantity: json["quantity"],
      price: (json["price"] as num).toDouble(),
    );
  }
}