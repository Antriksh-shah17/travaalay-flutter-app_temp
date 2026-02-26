import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:traavaalay/View/Login.dart';
import 'dart:convert';

class UserProfilePage extends StatefulWidget {
  final String userId; // pass the logged-in user ID
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;
  bool _isLoading = true;
  final String baseUrl = "http://10.135.240.52:3000"; // your server IP

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users/${widget.userId}"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          user = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("User not found")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.png"), // placeholder
            ),
            const SizedBox(height: 15),

            // User Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(user!["name"] ?? "Unknown",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(user!["email"] ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(user!["city"] ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(
                      "Languages: ${user!["language"]?.join(", ") ?? ""}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Role: ${user!["role"] ?? ""}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Buttons (same style as HostProfilePage)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Edit Profile page
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
