import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traavaalay/View/Host/AgroForm.dart';
import 'package:traavaalay/View/Host/AstroForm.dart';



class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Package",
          style: TextStyle(color: Colors.teal),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Column(
        children: [
          // ✅ TabBar below AppBar
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.teal,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Agro"),
                Tab(text: "Astro"),
                
              ],
            ),
          ),
          // ✅ Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AgroForm(),
                AstroForm(),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
