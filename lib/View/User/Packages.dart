import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  List<Map<String, dynamic>> packages = [];
  bool _isLoading = true;
  final String baseUrl = "http://10.135.240.52:3000"; // Replace with your server IP

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
  try {
    final response = await http.get(Uri.parse("$baseUrl/packages"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        packages = data.map((p) {
          String img = p['imageUrl'] ?? "";
          if (img.startsWith("assets/")) {
            img = img.replaceFirst("assets/", "");
          }
          img = "$baseUrl/assets/$img"; // final URL
          return {
            "id": p['id'],
            "category": p['category'],
            "title": p['title'],
            "description": p['description'],
            "price": p['price'],
            "imageUrl": img,
          };
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    print("Error fetching packages: $e");
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Packages"),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Astro"),
              Tab(text: "Agro"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PackageList(category: "Astro", packages: packages),
            PackageList(category: "Agro", packages: packages),
          ],
        ),
      ),
    );
  }
}

// -----------------
// Package List Widget
// -----------------
class PackageList extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> packages;
  const PackageList({super.key, required this.category, required this.packages});

  @override
  Widget build(BuildContext context) {
    final filteredPackages =
        packages.where((p) => p["category"] == category).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredPackages.length,
      itemBuilder: (context, index) {
        final pkg = filteredPackages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PackageCard(
            title: pkg["title"]!,
            description: pkg["description"]!,
            price: pkg["price"]!,
            imageUrl: pkg["imageUrl"]!,
          ),
        );
      },
    );
  }
}

// -----------------
// Package Card
// -----------------
class PackageCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;

  const PackageCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(price,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
