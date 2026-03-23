import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  String? otpError;
  String? alertMessage;
  bool loading = false;
  final auth = AuthService();

  Future<void> handleVerify() async {
    setState(() {
      otpError = otpController.text.isEmpty ? "Vui lòng nhập OTP" : null;
    });

    if (otpError != null) return;

    // lấy data được truyền từ signup screen
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    print("Args raw: $args");
    print("Args type: ${args.runtimeType}");
    final username = args['username'] as String? ?? '';
    final email = args['email'] as String? ?? '';
    final password = args['password'] as String? ?? '';

    setState(() {
      loading = true;
      alertMessage = null;
    });

    try {
      await auth.verifyOtp(username, email, password, otpController.text);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      setState(() {
        alertMessage = e.toString();
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận OTP")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Nhập mã OTP", style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),

                  if (alertMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.red[100],
                      child: Text(alertMessage!),
                    ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Mã OTP",
                      errorText: otpError,
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : handleVerify,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Xác nhận"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
