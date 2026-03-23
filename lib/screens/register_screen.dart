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
  final confirmPasswordController = TextEditingController();
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? alertMessage;
  bool showPassword = false;
  bool showConfirmPassword = false;

  bool loading = false;

  final auth = AuthService();

  void validateForm() {
    setState(() {
      usernameError = usernameController.text.isEmpty
          ? "Username is required"
          : null;
      emailError = emailController.text.isEmpty
          ? "Email is required"
          : !RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(emailController.text)
          ? "Email không đúng định dạng"
          : null;
      passwordError = passwordController.text.isEmpty
          ? "Password is required"
          : passwordController.text.length < 8 ||
                !passwordController.text.contains(RegExp(r'[A-Z]')) ||
                !passwordController.text.contains(RegExp(r'[a-z]')) ||
                !passwordController.text.contains(
                  RegExp(r'[!@#\$%^&*(),.?":{}|<>]'),
                )
          ? "Mật khẩu phải ≥ 8 ký tự, gồm chữ hoa, chữ thường và kí tự đặc biệt"
          : null;
      confirmPasswordError = confirmPasswordController.text.isEmpty
          ? "Confirm Password is required"
          : passwordController.text != confirmPasswordController.text
          ? "Confirm Password does not match with Password"
          : null;
    });
  }

  Future<void> handleRegister() async {
    validateForm();

    if (usernameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      return;
    }

    setState(() {
      loading = true;
      alertMessage = null;
    });

    try {
      await auth.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        print("username: ${usernameController.text}");
        print("email: ${emailController.text}");
        // chuyển sang màn hình OTP, truyền thông tin sang
        Navigator.pushNamed(
          context,
          AppRoutes.otp,
          arguments: {
            "username": usernameController.text,
            "email": emailController.text,
            "password": passwordController.text,
          },
        );
      }
    } catch (e) {
      setState(() {
        alertMessage = e.toString();
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
    confirmPasswordController.dispose();
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
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        errorText: passwordError,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),
                      ),
                    ),
                    // Confirm Password
                    const SizedBox(height: 15),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        errorText: confirmPasswordError,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => showConfirmPassword = !showConfirmPassword,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : handleRegister,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Register"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text("Already have account? Login"),
                    ),
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
