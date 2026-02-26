import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AstroForm extends StatefulWidget {
  const AstroForm({super.key});

  @override
  State<AstroForm> createState() => _AstroFormState();
}

class _AstroFormState extends State<AstroForm> {
  final TextEditingController eventName = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController capacity = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController bestViewingTime = TextEditingController();
  final TextEditingController weatherDep = TextEditingController();
  final TextEditingController imageUrl = TextEditingController(); // ✅ New field

  bool telescopeProvided = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  StargazingStatus _status = StargazingStatus.good;

  final String baseUrl = 'http://10.135.240.52:3000'; // json-server URL

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> submitForm() async {
    if (eventName.text.isEmpty ||
        description.text.isEmpty ||
        price.text.isEmpty ||
        location.text.isEmpty ||
        imageUrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    final package = {
      "category": "Astro",
      "title": eventName.text,
      "description": description.text,
      "price": price.text,
      "location": location.text,
      "bestViewingTime": bestViewingTime.text,
      "weatherDep": weatherDep.text,
      "telescopeProvided": telescopeProvided,
      "date": selectedDate?.toIso8601String() ?? "",
      "time": selectedTime?.format(context) ?? "",
      "stargazingSignal": _status.name,
      "imageUrl": imageUrl.text
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/packages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(package),
      );

      Navigator.pop(context); // close loading

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Astro Package Submitted!")),
        );

        // Clear form
        eventName.clear();
        description.clear();
        price.clear();
        location.clear();
        bestViewingTime.clear();
        weatherDep.clear();
        imageUrl.clear();
        setState(() {
          selectedDate = null;
          selectedTime = null;
          telescopeProvided = false;
          _status = StargazingStatus.good;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Astro Package Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          customTextField("Event Name", eventName),
          customTextField("Description", description, maxLines: 3),
          customTextField("Price", price),
          customTextField("Location", location),
          customTextField("Image URL", imageUrl), // ✅ New field
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: pickDate,
                    child: Text(selectedDate == null
                        ? "Pick Date"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}")),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                    onPressed: pickTime,
                    child: Text(selectedTime == null
                        ? "Pick Time"
                        : selectedTime!.format(context))),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Text("Telescope Provided"),
            value: telescopeProvided,
            onChanged: (val) => setState(() => telescopeProvided = val!),
          ),
          customTextField("Best Viewing Time", bestViewingTime),
          customTextField("Weather Dependencies", weatherDep),
          const SizedBox(height: 10),
          const Text("Stargazing Signal", style: TextStyle(fontWeight: FontWeight.bold)),
          StargazingSignal(status: _status),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => setState(() => _status = StargazingStatus.good),
                  child: const Text("Good")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed: () => setState(() => _status = StargazingStatus.moderate),
                  child: const Text("Moderate")),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(onPressed: submitForm, child: const Text("Submit")),
          )
        ],
      ),
    );
  }

  Widget customTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

enum StargazingStatus { good, moderate }

class StargazingSignal extends StatelessWidget {
  final StargazingStatus status;

  const StargazingSignal({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case StargazingStatus.good:
        color = Colors.green;
        text = "✅ Great visibility – Perfect for stargazing!";
        break;
      case StargazingStatus.moderate:
        color = Colors.yellow;
        text = "⚠️ Moderate visibility – Possible stargazing.";
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
