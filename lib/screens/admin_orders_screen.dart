import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final service = AdminService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = service.getOrders();
  }

  void _refresh() {
    setState(() {
      _future = service.getOrders();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "PENDING":
        return Colors.orange;
      case "DELIVERED":
        return Colors.green;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPaymentColor(String status) {
    switch (status) {
      case "PAID":
        return Colors.green;
      case "CANCEL":
        return Colors.red;
      case "COD":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatPrice(num price) {
    return "${price.toStringAsFixed(0)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        /// ⏳ Loading
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        /// ❌ Empty
        if (orders.isEmpty) {
          return const Center(child: Text("Không có đơn hàng"));
        }

        /// ✅ List
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${o["id"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(o["username"] ?? ""),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// STATUS
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(o["status"])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              o["status"],
                              style: TextStyle(
                                color: getStatusColor(o["status"]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getPaymentColor(o["paymentStatus"])
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              o["paymentStatus"],
                              style: TextStyle(
                                color: getPaymentColor(o["paymentStatus"]),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// TOTAL + DATE
                      Text("Total: ${formatPrice(o["totalAmount"])}"),
                      Text(
                        "Date: ${o["createdAt"] ?? ""}",
                        style: const TextStyle(fontSize: 12),
                      ),

                      const Divider(),

                      /// ITEMS (preview)
                      Column(
                        children: (o["items"] as List)
                            .take(2)
                            .map((item) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item["productName"]),
                                    Text("x${item["quantity"]}"),
                                  ],
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 10),

                      /// UPDATE STATUS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Update Status:"),

                          DropdownButton<String>(
                            value: o["status"],
                            items: const [
                              DropdownMenuItem(
                                  value: "PENDING", child: Text("PENDING")),
                              DropdownMenuItem(
                                  value: "DELIVERED",
                                  child: Text("DELIVERED")),
                              DropdownMenuItem(
                                  value: "CANCELLED",
                                  child: Text("CANCELLED")),
                            ],
                            onChanged: (value) async {
                              await service.updateOrderStatus(
                                  o["id"], value!);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Đã cập nhật")),
                              );

                              _refresh();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}