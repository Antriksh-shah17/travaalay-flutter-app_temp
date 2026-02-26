// lib/View/User/UserDash.dart
import 'package:flutter/material.dart';
import 'package:traavaalay/Controller/home_controller.dart';
import 'package:traavaalay/View/User/Blog.dart';
import 'package:traavaalay/View/User/Packages.dart';
import 'package:traavaalay/View/User/Translator.dart';
import 'package:traavaalay/View/User/UserProfile.dart';

import '../../event_slider.dart';
// import your other pages: PackagesPage, TravAiPage, BlogPage

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;
  final HomeController _controller = HomeController();

  HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = _controller.getUpcomingEvents();

    final categories = [
      {
        "title": "Translator",
        "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"
      },
      {
        "title": "Packages",
        "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"
      },
      {
        "title": "TravAI",
        "image": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb"
      },
      {
        "title": "Blog",
        "image": "https://images.unsplash.com/photo-1556740738-b6a63e27c4df"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Travaalay"),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              Text(
                "Welcome, ${user['name'] ?? 'User'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: ()  {
                  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: user['id'].toString()), // pass logged-in user ID
      ),
    );
                },
                icon: const Icon(Icons.person),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EventSlider(
              events: upcomingEvents,
              defaultMedia: _controller.defaultMedia,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(
                    context,
                    category["title"]!,
                    category["image"]!,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case "Translator":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TranslatorPage()));
            break;
          case "Packages":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PackagesPage()));
            break;
          case "TravAI":
            Navigator.pushNamed(context, '/travai');
            break;
          case "Blog":
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const BlogScreen()));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Page for $title not implemented")),
            );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.4),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
