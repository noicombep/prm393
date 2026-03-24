import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../routes/app_routes.dart';
import '../services/account_service.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final service = AccountService();
  late Future<Map<String, dynamic>> _future;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool isDarkMode = false;
  String? phoneError;

  @override
  void initState() {
    super.initState();
    _future = service.getMe();
  }

  void _loadData() {
    setState(() {
      _future = service.getMe();
    });
  }

  bool isValidPhone(String phone) {
    final regex = RegExp(r'^(0|\+84)[0-9]{9}$');
    return regex.hasMatch(phone);
  }

  void _updateProfile() async {
    final phone = phoneController.text.trim();

    setState(() {
      phoneError = null;
    });

    if (!isValidPhone(phone)) {
      setState(() {
        phoneError = "Số điện thoại không hợp lệ";
      });
      return;
    }

    await service.updateMe({
      "fullName": nameController.text,
      "phone": phone,
      "address": addressController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          nameController.text = user["fullName"] ?? "";
          phoneController.text = user["phone"] ?? "";
          addressController.text = user["address"] ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.pink),

                Text(
                  user["username"] ?? "không có username",
                  style: const TextStyle(fontSize: 20),
                ),

                Text(user["email"] ?? "không có email"),

                Text(user["fullname"] ?? "không có fullname"),

                Text(user["phone"] ?? "không có phone"),

                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone",
                    errorText: phoneError,
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text("Update Profile"),
                ),

                const Divider(height: 40),

                // ⚙️ SETTINGS
                // SwitchListTile(
                //   title: const Text("Dark Mode"),
                //   value: isDarkMode,
                //   onChanged: (value) {
                //     setState(() {
                //       isDarkMode = value;
                //     });
                //   },
                // ),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: themeProvider.isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Change Password"),
                  onTap: () {
                    final oldController = TextEditingController();
                    final newController = TextEditingController();

                    String? error;

                    bool isStrongPassword(String password) {
                      final regex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
                      );
                      return regex.hasMatch(password);
                    }

                    showDialog(
                      context: context,
                      builder: (_) => StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text("Đổi mật khẩu"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: oldController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Mật khẩu cũ",
                                  ),
                                ),
                                TextField(
                                  controller: newController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Mật khẩu mới",
                                    errorText: error,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Hủy"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final oldPass = oldController.text.trim();
                                  final newPass = newController.text.trim();

                                  // reset lỗi
                                  setState(() {
                                    error = null;
                                  });

                                  // ❌ check rỗng
                                  if (oldPass.isEmpty || newPass.isEmpty) {
                                    setState(() {
                                      error = "Không được để trống";
                                    });
                                    return;
                                  }

                                  // ❌ trùng mật khẩu cũ
                                  if (oldPass == newPass) {
                                    setState(() {
                                      error =
                                          "Mật khẩu mới không được trùng mật khẩu cũ";
                                    });
                                    return;
                                  }

                                  // ❌ không đủ mạnh
                                  if (!isStrongPassword(newPass)) {
                                    setState(() {
                                      error =
                                          "Mật khẩu ≥8 ký tự, có HOA, thường, số, ký tự đặc biệt";
                                    });
                                    return;
                                  }

                                  try {
                                    await service.changePassword(
                                      oldPass,
                                      newPass,
                                    );

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Đổi mật khẩu thành công",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    setState(() {
                                      error = "Sai mật khẩu cũ!";
                                    });
                                  }
                                },
                                child: const Text("Xác nhận"),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    await SessionService.clearToken();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
