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

    if (data == null) return;

    try {
      final List decoded = jsonDecode(data);

      _cart.items.clear();

      for (var item in decoded) {
        _cart.items.add(CartItem.fromJson(item));
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Load cart error: $e");
    }
  }

  // 💾 Save cart
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _cart.items.map((e) => e.toJson()).toList();

    await prefs.setString(cartKey, jsonEncode(data));
  }

  // ➕ Add to cart
  Future<bool> addToCart(Product product) async {
    final currentQty = getQuantity(product.id);

    if (product.stock == 0) return false;
    if (currentQty >= product.stock) return false;

    _cart.addItem(product);

    await saveCart(); // ✅ FIX await
    notifyListeners();

    return true;
  }

  // ❌ Remove
  Future<void> removeFromCart(int productId) async {
    _cart.removeItem(productId);

    await saveCart(); // ✅ FIX await
    notifyListeners();
  }

  // 🔄 Update quantity
  Future<bool> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) return false;

    try {
      final item = _cart.items.firstWhere(
        (e) => e.product.id == productId,
      );

      if (quantity > item.product.stock) return false;

      item.quantity = quantity;

      await saveCart(); // ✅ FIX await
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  // 🧹 Clear cart
  Future<void> clearCart() async {
    _cart.items.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cartKey); // ✅ tốt hơn clear()

    notifyListeners();
  }

  // 📊 Get quantity
  int getQuantity(int productId) {
    try {
      final item = _cart.items.firstWhere((e) => e.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // 💰 Total price
  double get totalPrice {
    return _cart.items.fold(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
  }

  // 📦 Total items
  int get totalItems {
    return _cart.items.fold(0, (sum, item) => sum + item.quantity);
  }
}