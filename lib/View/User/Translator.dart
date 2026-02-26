import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  List<Map<String, dynamic>> translators = [];
  bool _isLoading = true;

  // Replace with your computer LAN IP
  final String baseUrl = "http://10.135.240.52:3000";

  @override
  void initState() {
    super.initState();
    fetchTranslators();
  }

  Future<void> fetchTranslators() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // ✅ Filter only role = translator
        final filtered = data.where((u) => u['role'] == 'translator').toList();

        setState(() {
          translators = filtered.map((t) {
            String imagePath = t['profileImage'] ?? "";
            if (imagePath.isEmpty || !imagePath.startsWith("http")) {
              imagePath = "$baseUrl/assets/Gauri.jpeg"; // default profile
            }
            return {
              "id": t['id'],
              "name": t['name'],
              "email": t['email'],
              "phone": t['phone'] ?? "0000000000",
              "languages": List<String>.from(t['language'] ?? []),
              "bio": t['bio'] ?? "Translator available.",
              "profileImage": imagePath,
              "verified": t['verified'] ?? false,
              "reviews": t['reviews'] ?? [],
              "charges": t['charges'] ?? "₹500/hr",
              "city": t['city'] ?? "Unknown"
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching translators: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Translators")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: translators.length,
        itemBuilder: (context, index) {
          final t = translators[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TranslatorPolaroidCard(
              name: t['name']!,
              imageUrl: t['profileImage']!,
              languages: List<String>.from(t['languages']),
              location: t['city'] ?? "Unknown",
              reviews: List<double>.from(
                  (t['reviews'] ?? []).map((r) => r.toDouble())),
              charges: t['charges']!,
              bio: t['bio']!,
              phone: t['phone']!,
              whatsappNumber: t['phone']!,
              cardColor: pastelColors[index % pastelColors.length],
            ),
          );
        },
      ),
    );
  }
}

// -----------------
// Light Pastel Colors 🎨
final List<Color> pastelColors = [
  Colors.pink.shade50,
  Colors.blue.shade50,
  Colors.green.shade50,
  Colors.yellow.shade50,
  Colors.purple.shade50,
  Colors.teal.shade50,
  Colors.orange.shade50,
];

// -----------------
// Polaroid Card
// -----------------
class TranslatorPolaroidCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final List<String> languages;
  final String location;
  final List<double> reviews;
  final String charges;
  final String bio;
  final String phone;
  final String whatsappNumber;
  final Color cardColor;

  const TranslatorPolaroidCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    this.languages = const [],
    this.location = '',
    required this.reviews,
    this.charges = '',
    this.bio = '',
    required this.phone,
    required this.whatsappNumber,
    required this.cardColor,
  }) : super(key: key);

  @override
  State<TranslatorPolaroidCard> createState() => _TranslatorPolaroidCardState();
}

class _TranslatorPolaroidCardState extends State<TranslatorPolaroidCard> {
  late List<double> reviews;

  @override
  void initState() {
    super.initState();
    reviews = List.from(widget.reviews);
  }

  double get averageRating =>
      reviews.isEmpty ? 0.0 : reviews.reduce((a, b) => a + b) / reviews.length;

  void addReview(double rating) {
    setState(() {
      reviews.add(rating);
    });
  }

  Future<void> openWhatsApp(String phoneNumber, String message) async {
    final Uri whatsappUrl =
        Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> callNumber(String phoneNumber) async {
    final Uri callUrl = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(callUrl)) {
      await launchUrl(callUrl);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text("Image not found"));
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemSize: 14,
                        ),
                        const SizedBox(width: 4),
                        Text("(${reviews.length})",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Languages: ${widget.languages.join(', ')}",
                        style: const TextStyle(fontSize: 12)),
                    Text("Location: ${widget.location}",
                        style: const TextStyle(fontSize: 12)),
                    Text("Charges: ${widget.charges}",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                    const SizedBox(height: 4),
                    Text(
                      widget.bio,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            callNumber(widget.phone);
                          },
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          onPressed: () {
                            openWhatsApp(widget.whatsappNumber,
                                "Hello ${widget.name}, I found you on Travaalay!");
                          },
                          icon: const Icon(Icons.chat_bubble),
                          label: const Text("WhatsApp"),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Leave a Review"),
                                content: RatingBar.builder(
                                  initialRating: 3,
                                  minRating: 1,
                                  allowHalfRating: true,
                                  itemBuilder: (_, __) =>
                                      const Icon(Icons.star, color: Colors.amber),
                                  onRatingUpdate: (rating) {
                                    addReview(rating);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text("Review"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
