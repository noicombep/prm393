import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class Cart {
  final List<CartItem> items = [];

  void addItem(Product product) {
    final existingItem = items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    if (existingItem.quantity == 0) {
      items.add(CartItem(product: product));
    } else {
      existingItem.quantity++;
    }
  }

  void removeItem(int productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(int productId, int quantity) {
    final item = items.firstWhere((item) => item.product.id == productId);
    if (quantity > 0) {
      item.quantity = quantity;
    } else {
      removeItem(productId);
    }
  }

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => items.length;
}