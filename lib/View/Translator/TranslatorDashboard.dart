import 'package:flutter/material.dart';
import 'package:traavaalay/View/Translator/TranslatorBookingScreen.dart';
import 'package:traavaalay/View/Translator/TranslatorProfile.dart';



class TranslatorDashboard extends StatefulWidget {
  final Map<String, dynamic> user; // User info passed from login

  const TranslatorDashboard({Key? key, required this.user}) : super(key: key);

  @override
  State<TranslatorDashboard> createState() => _TranslatorDashboardState();
}

class _TranslatorDashboardState extends State<TranslatorDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TranslatorBookingsPage(user: widget.user), // Booking requests
      TranslatorProfilePage(user: widget.user),  // Profile page
    ];
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Bookings"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Translator Dashboard"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


