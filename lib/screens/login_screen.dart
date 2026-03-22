import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? alertMessage;

  bool loading = false;

  final auth = AuthService();


  void validateForm() {
    setState(() {
      emailError = emailController.text.isEmpty ? "Email is required" : null;
      passwordError = passwordController.text.isEmpty ? "Password is required" : null;
    });
  }

  Future<void> handleLogin() async {
    validateForm();

    if (emailError != null || passwordError != null) return;

    setState(() {
      loading = true;
      alertMessage = null;
    });

    try {
      final success = await auth.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        final token = await SessionService.getToken(); // nếu cần
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
            arguments: token,
          );
        }
      } else {
        setState(() {
          alertMessage = "Login failed";
        });
      }
    } catch (e) {
      setState(() {
        alertMessage = "Error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(fontSize: 24),
                    ),

                    const SizedBox(height: 20),

                    // Alert
                    if (alertMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.red[100],
                        child: Text(alertMessage!),
                      ),

                    const SizedBox(height: 10),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: emailError,
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Password
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        errorText: passwordError,
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : handleLogin,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text("Don't have account? Register"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}