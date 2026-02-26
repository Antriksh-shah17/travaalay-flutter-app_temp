import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:traavaalay/Model/event.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventSlider extends StatefulWidget {
  final List<String> defaultMedia;

  const EventSlider({super.key, required this.defaultMedia, required List<Event> events});

  @override
  State<EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<EventSlider> {
  List<Event> slides = [];
  final String baseUrl = "http://10.135.240.52:3000"; // LAN IP of your computer
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/events"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        slides = data.map((jsonEvent) {
          return Event(
            
            title: jsonEvent['title'] ?? "",
            description: jsonEvent['description'] ?? "",
            date: DateTime.tryParse(jsonEvent['date'] ?? "") ?? DateTime.now(),
            mediaPath: jsonEvent['mediaPath'] != null && jsonEvent['mediaPath'].isNotEmpty
                ? "$baseUrl/assets/${jsonEvent['mediaPath']}" // full URL for local image
                : "",
          );
        }).toList();
      } else {
        // fallback to default media
        slides = widget.defaultMedia.map((url) => Event(
          
          title: "",
          description: "",
          date: DateTime.now(),
          mediaPath: url
        )).toList();
      }
    } catch (e) {
      slides = widget.defaultMedia.map((url) => Event(
        
        title: "",
        description: "",
        date: DateTime.now(),
        mediaPath: url
      )).toList();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: slides.length,
          itemBuilder: (context, index, realIndex) {
            final slide = slides[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  slide.mediaPath.isNotEmpty
                      ? Image.network(
                          slide.mediaPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text("Image not found"));
                          },
                        )
                      : const Center(child: Text("No Image")),
                  if (slide.title.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(slide.date),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enableInfiniteScroll: slides.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.teal : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}
