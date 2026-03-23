class OrderItemRequest {
  final String productName;
  final int quantity;
  final double price;

  OrderItemRequest({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        "productName": productName,
        "quantity": quantity,
        "price": price,
      };
}

class CreateOrderRequest {
  final String phone;
  final String shippingAddress;
  final double totalPrice;
  final List<OrderItemRequest> items;

  CreateOrderRequest({
    required this.phone,
    required this.shippingAddress,
    required this.totalPrice,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "shippingAddress": shippingAddress,
        "paymentMethod": "BANKING", // fix cứng
        "totalPrice": totalPrice,
        "items": items.map((e) => e.toJson()).toList(),
      };
}