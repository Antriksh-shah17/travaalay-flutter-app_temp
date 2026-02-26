import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<Map<String, dynamic>> blogs = [];
  bool _isLoading = true;

  // Replace with your server IP
  final String baseUrl = "http://10.135.240.52:3000";

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/blogs"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          blogs = data.map((b) {
            String img = b['image'] ?? "";
            if (!img.startsWith("http")) {
              // Use baseUrl + image name (json-server static folder)
              img = "$baseUrl/$img";
            }
            return {
              "id": b['id'],
              "title": b['title'],
              "description": b['description'],
              "date": b['date'],
              "image": img,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching blogs: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blogs"),
        backgroundColor: Colors.teal,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final post = blogs[index];
          final preview = post["description"]!.length > 100
              ? post["description"]!.substring(0, 100) + "..."
              : post["description"];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post["image"] != null)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      post["image"]!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child:
                            const Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post["title"]!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(preview!),
                      const SizedBox(height: 8),
                      Text(post["date"]!,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => FullBlogScreen(post: post)));
                          },
                          child: const Text("Read More"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullBlogScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const FullBlogScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final paragraphs = post["description"]!.split(". ");

    return Scaffold(
      appBar: AppBar(
        title: Text(post["title"]!),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post["image"] != null)
              Image.network(
                post["image"]!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child:
                      const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paragraphs.map<Widget>((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      p.trim() + ".",
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
