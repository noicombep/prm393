import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  // ✅ JSON
  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Cart {
  final List<CartItem> items = [];

  // ➕ Add
  void addItem(Product product) {
    try {
      final existingItem =
          items.firstWhere((item) => item.product.id == product.id);

      existingItem.quantity++;
    } catch (e) {
      items.add(CartItem(product: product));
    }
  }

  // ❌ Remove
  void removeItem(int productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  // 🔄 Update
  void updateQuantity(int productId, int quantity) {
    try {
      final item =
          items.firstWhere((item) => item.product.id == productId);

      if (quantity > 0) {
        item.quantity = quantity;
      } else {
        removeItem(productId);
      }
    } catch (e) {
      // không tìm thấy thì bỏ qua
    }
  }

  // 🔥 NEW: lấy quantity (rất quan trọng)
  int getQuantity(int productId) {
    try {
      final item =
          items.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // 💰 total price
  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  // 🧮 total quantity (chuẩn hơn itemCount)
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  // ⚠️ itemCount hiện tại của bố chỉ đếm số loại sản phẩm
  int get itemCount => items.length;

  // 💾 JSON (cho SharedPreferences)
  List<Map<String, dynamic>> toJson() {
    return items.map((e) => e.toJson()).toList();
  }

  void fromJson(List<dynamic> jsonList) {
    items.clear();
    for (var item in jsonList) {
      items.add(CartItem.fromJson(item));
    }
  }
}