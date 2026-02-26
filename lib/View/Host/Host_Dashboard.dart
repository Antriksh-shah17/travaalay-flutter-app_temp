import 'package:flutter/material.dart';
import 'package:traavaalay/View/Host/BookingScreen.dart';
import 'package:traavaalay/View/Host/ContentSceen.dart';
import 'package:traavaalay/View/Host/HostProfilePage.dart';
import 'package:traavaalay/View/Host/PackageScreen.dart';


class HostDashboard extends StatefulWidget {
  final Map<String, dynamic>? user; // Pass user info here

  const HostDashboard({Key? key, this.user}) : super(key: key);

  @override
  _HostDashboardState createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  int _selectedIndex = 0;

  // Screens for bottom navigation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      PackageScreen(),
      BookingScreen(),
      CreateBlogScreen(),
      HostProfilePage(),
    ];
  }

  // Bottom navigation items
  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: "Packages"),
    BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Bookings"),
    BottomNavigationBarItem(icon: Icon(Icons.article), label: "Content"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    String username = widget.user?['name'] ?? 'Host';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Travaalay"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                "Welcome, $username",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
