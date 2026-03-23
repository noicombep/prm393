import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../services/account_service.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  late Future<List<Account>> _future;
  final service = AccountService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _future = service.getCustomers();
  }

  // 🗑 DELETE
  void _deleteUser(int id) async {
    await service.deleteUser(id);

    setState(() {
      _loadData();
    });
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text(
          "Bạn có chắc muốn xóa? Chỉ khóa tài khoản không xóa nhé!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(id);
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  // ✏️ EDIT ROLE
  void _showEditDialog(Account user) {
    String role = user.roleId == 1 ? "Admin" : "Customer";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edit ${user.username}"),
          content: DropdownButtonFormField<String>(
            value: role,
            items: [
              "Admin",
              "Customer",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {
              role = value!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int roleId = role == "Admin" ? 1 : 2;

                await service.updateUser(user.id, {"roleId": roleId});

                Navigator.pop(context);

                setState(() {
                  _loadData();
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder<List<Account>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final customers = snapshot.data!;

          if (customers.isEmpty) {
            return const Center(child: Text("Không có khách hàng"));
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final user = customers[index];

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.username),
                subtitle: Text(
                  "${user.email} | Role: ${user.roleId == 1 ? "Admin" : "Customer"}",
                ),

                // 🔥 ACTIONS
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✏️ Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(user),
                    ),

                    // 🗑 Delete (có confirm)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(user.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
