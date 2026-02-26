import 'package:flutter/material.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  final List<Map<String, dynamic>> bookings = const [
    {
      "id": 1,
      "translatorName": "Translator Shah",
      "touristName": "Antriksh Shah",
      "package": "Astro Tour",
      "date": "2025-09-23",
      "status": "pending"
    },
    {
      "id": 2,
      "translatorName": "Translator Shah",
      "touristName": "Riya Kapoor",
      "package": "Tirth Yatra",
      "date": "2025-09-25",
      "status": "pending"
    }
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "accepted": return Colors.green;
      case "rejected": return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text("${booking['touristName']} → ${booking['translatorName']}"),
            subtitle: Text("${booking['package']} | ${booking['date']}"),
            trailing: Text(
              booking['status'],
              style: TextStyle(
                  color: getStatusColor(booking['status']),
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
