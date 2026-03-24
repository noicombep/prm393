import 'package:flutter/material.dart';
import '../models/order_his.dart';
import '../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final service = OrderService();
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = service.getMyOrders();
  }

  String formatPrice(num price) {
    return "${price.toStringAsFixed(0)} đ";
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color getPaymentColor(String statusFee) {
    switch (statusFee) {
      case "PAID":
        return Colors.green;
      case "COD":
        return Colors.orange;
      case "CANCEL":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng"),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          /// ⏳ Loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          /// ❌ Empty
          if (orders.isEmpty) {
            return const Center(
              child: Text("Bạn chưa có đơn hàng nào"),
            );
          }

          /// ✅ List
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Đơn #${order.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          /// 🚚 STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(order.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                color: getStatusColor(order.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// 💳 PAYMENT STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getPaymentColor(order.statusFee)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.statusFee,
                          style: TextStyle(
                            color: getPaymentColor(order.statusFee),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// INFO
                      Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: [
                          _infoItem(
                            "Ngày đặt",
                            order.createdAt.toLocal().toString(),
                          ),
                          _infoItem("SĐT", order.phone),
                          _infoItem("Địa chỉ", order.shippingAddress),
                        ],
                      ),

                      const Divider(height: 24),

                      /// ITEMS
                      Column(
                        children: order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.productName),
                                ),
                                Text("x${item.quantity} "),
                                Text(
                                  formatPrice(item.price),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      /// TOTAL
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Tổng tiền: ${formatPrice(order.totalAmount)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}