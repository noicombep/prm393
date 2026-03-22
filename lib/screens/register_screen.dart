import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? alertMessage;

  bool loading = false;

  final auth = AuthService();

  void validateForm() {
    setState(() {
      usernameError =
          usernameController.text.isEmpty ? "Username is required" : null;
      emailError =
          emailController.text.isEmpty ? "Email is required" : null;
      passwordError =
          passwordController.text.isEmpty ? "Password is required" : null;
    });
  }

  Future<void> handleRegister() async {
    validateForm();

    if (usernameError != null ||
        emailError != null ||
        passwordError != null) {
      return;
    }

    setState(() {
      loading = true;
      alertMessage = null;
    });

    try {
      final success = await auth.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Register success")),
          );

          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        setState(() {
          alertMessage = "Register failed";
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
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
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
                      "Create Account",
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

                    // Username
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        errorText: usernameError,
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

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
                        onPressed: loading ? null : handleRegister,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Register"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text("Already have account? Login"),
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