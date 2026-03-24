import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/account_screen.dart';
import '../screens/qr_screen.dart';
import '../screens/blog_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/Account/customer_screen.dart';

class AppRoutes {
  static const String splash = "/";
  static const String login = "/login";
  static const String home = "/home";
  static const String signup = "/signup";
  static const String products = "/products";
  static const String productDetail = "/product-detail";
  static const String cart = "/cart";
  static const String checkout = "/checkout";
  static const String account = "/account";
  static const String sendQr = "/send-qr";
  static const String blog = "/blog";
  static const String otp = "/otp";
  static const String customers = "/customers";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case home:
        return MaterialPageRoute(builder: (_) => HomePage());

      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());

      case productDetail:
        final productId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );

      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());

      case sendQr:
        return MaterialPageRoute(builder: (_) => const QrScreen());

      case blog:
        return MaterialPageRoute(builder: (_) => const BlogScreen());

      case otp:
        return MaterialPageRoute(
          builder: (_) => const OtpScreen(),
          settings: settings,
        );
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomerScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
