import 'package:flutter/material.dart';

enum BookingStatus { pending, accepted, rejected }

class TranslatorBookingsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const TranslatorBookingsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<TranslatorBookingsPage> createState() => _TranslatorBookingsPageState();
}

class _TranslatorBookingsPageState extends State<TranslatorBookingsPage> {
  // Sample bookings
  List<Map<String, dynamic>> bookings = [
    {
      "name": "Antriksh Shah",
      "phone": "+919876543210",
      "package": "Astro Tour",
      "date": "2025-09-23",
      "time": "18:00",
      "status": BookingStatus.pending,
    },
    {
      "name": "Riya Kapoor",
      "phone": "+919812345678",
      "package": "Tirth Yatra",
      "date": "2025-09-25",
      "time": "09:00",
      "status": BookingStatus.pending,
    },
  ];

  void sendSMS(String phone, String name, String packageName) {
    debugPrint("SMS sent to $name ($phone) for $packageName booking confirmation.");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("SMS sent to $name")));
  }

  Color getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  String getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return "Pending";
      case BookingStatus.accepted:
        return "Accepted";
      case BookingStatus.rejected:
        return "Rejected";
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
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking["name"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Phone: ${booking['phone']}"),
                  Text("Package: ${booking['package']}"),
                  Text("Date: ${booking['date']}"),
                  Text("Time: ${booking['time']}"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          color: getStatusColor(booking['status']), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        getStatusText(booking['status']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(booking['status'])),
                      )
                    ],
                  ),
                  if (booking['status'] == BookingStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () {
                              setState(() {
                                bookings[index]['status'] = BookingStatus.accepted;
                              });
                              sendSMS(booking['phone'], booking['name'],
                                  booking['package']);
                            },
                            child: const Text("Accept"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              setState(() {
                                bookings[index]['status'] = BookingStatus.rejected;
                              });
                            },
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    ),
                ]),
          ),
        );
      },
    );
  }
}
