import 'package:flutter/material.dart';

enum BookingStatus { pending, accepted, rejected }

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Sample bookings data
  List<Map<String, dynamic>> bookings = [
    {
      "name": "Antriksh Shah",
      "phone": "+919876543210",
      "guests": 3,
      "package": "Astro Tour",
      "date": "2025-09-23",
      "time": "18:00",
      "status": BookingStatus.pending,
    },
    {
      "name": "Riya Kapoor",
      "phone": "+919812345678",
      "guests": 2,
      "package": "Tirth Yatra",
      "date": "2025-09-25",
      "time": "09:00",
      "status": BookingStatus.pending,
    },
  ];

  // Placeholder for sending SMS
  void sendSMS(String phone, String name, String packageName) {
    // Integrate Twilio/Fast2SMS API here
    debugPrint("SMS sent to $name ($phone) for $packageName booking confirmation.");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("SMS sent to $name")),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Requests"),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking["name"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text("Phone: ${booking['phone']}"),
                    Text("Guests: ${booking['guests']}"),
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
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                setState(() {
                                  bookings[index]['status'] =
                                      BookingStatus.accepted;
                                });
                                sendSMS(booking['phone'], booking['name'],
                                    booking['package']);
                              },
                              child: const Text("Accept"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                setState(() {
                                  bookings[index]['status'] =
                                      BookingStatus.rejected;
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
      ),
    );
  }
}
