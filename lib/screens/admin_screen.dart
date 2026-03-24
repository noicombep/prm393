import 'package:flutter/material.dart';
import '../screens/Account/customer_screen.dart';
import 'admin_orders_screen.dart';
// import 'admin_products_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int index = 0;

  final screens = const [
    AdminOrdersScreen(),
    CustomerScreen(),
    //AdminProductsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
       // BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Products"),
        ],
      ),
    );
  }
}