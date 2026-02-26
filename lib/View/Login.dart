import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:traavaalay/View/Admin/AdminDashboard.dart';
import 'package:traavaalay/View/Host/Host_Dashboard.dart';
import 'package:traavaalay/View/Signup.dart';
import 'package:traavaalay/View/Translator/TranslatorDashboard.dart';
import 'package:traavaalay/View/User/UserDash.dart';
import 'package:traavaalay/View/User/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  // ✅ Use 10.0.2.2 for Android emulator instead of localhost
final String baseUrl = 'http://192.168.1.104:5000/api/auth'; 
   Future<void> login() async {
  setState(() => loading = true);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    setState(() => loading = false);

    if (response.statusCode == 200) {
      final token = data['token'];
      final user = data['user'];

      await TokenStorage.saveToken(token);

      String role = user['role']?.toLowerCase() ?? 'user';

      if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: user)),
        );
      } else if (role == 'host') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HostDashboard(user: user)),
        );
      } else if (role == 'translator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TranslatorDashboard(user: user)),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unknown role")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Login failed')),
      );
    }
  } catch (e) {
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3CD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/TravText.png", height: 100),
              const SizedBox(height: 30),
              Text("Login Now",
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),

              // Login Button
              ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

             GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
