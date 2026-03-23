import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  static const String cartKey = "cart_data";

  // 🟢 Load cart khi app start
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(cartKey);

    if (data != null) {
      final decoded = jsonDecode(data);

      _cart.items.clear();

      for (var item in decoded) {
        _cart.items.add(CartItem.fromJson(item));
      }

      notifyListeners();
    }
  }

  // 💾 Save cart
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _cart.items.map((e) => e.toJson()).toList();

    await prefs.setString(cartKey, jsonEncode(data));
  }

  // ➕ Add to cart (có validate stock)
  bool addToCart(Product product) {
    final currentQty = getQuantity(product.id);

    // ❌ Hết hàng
    if (product.stock == 0) {
      return false;
    }

    // ❌ Vượt stock
    if (currentQty >= product.stock) {
      return false;
    }

    _cart.addItem(product);
    saveCart();
    notifyListeners();

    return true;
  }

  // ❌ Remove
  void removeFromCart(int productId) {
    _cart.removeItem(productId);
    saveCart();
    notifyListeners();
  }

  // 🔄 Update quantity (có validate stock)
  bool updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return false;

    final item = _cart.items.firstWhere(
      (e) => e.product.id == productId,
      orElse: () => throw Exception("Item not found"),
    );

    // ❌ vượt stock
    if (quantity > item.product.stock) {
      return false;
    }

    item.quantity = quantity;

    saveCart();
    notifyListeners();

    return true;
  }

  // 🧹 Clear cart
  void clearCart() {
    _cart.items.clear();
    saveCart();
    notifyListeners();
  }


  // 📊 Get quantity
  int getQuantity(int productId) {
    try {
      final item = _cart.items.firstWhere(
        (e) => e.product.id == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // 💰 Total price (bonus)
  double get totalPrice {
    double total = 0;

    for (var item in _cart.items) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

  // 📦 Total items
  int get totalItems {
    return _cart.items.fold(0, (sum, item) => sum + item.quantity);
  }
}

