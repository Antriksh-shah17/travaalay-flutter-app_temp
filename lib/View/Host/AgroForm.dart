import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgroForm extends StatefulWidget {
  const AgroForm({super.key});

  @override
  State<AgroForm> createState() => _AgroFormState();
}

class _AgroFormState extends State<AgroForm> {
  final TextEditingController eventName = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController capacity = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController cropType = TextEditingController();
  final TextEditingController season = TextEditingController();
  final TextEditingController farmSize = TextEditingController();
  final TextEditingController certificates = TextEditingController();
  final TextEditingController imageUrl = TextEditingController();

  bool songImagesUploaded = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final String baseUrl = 'http://10.135.240.52:3000'; // your json-server

  Future<void> pickDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030));
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
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
      "category": "Agro",
      "title": eventName.text,
      "description": description.text,
      "price": price.text,
      "location": location.text,
      "cropType": cropType.text,
      "season": season.text,
      "farmSize": farmSize.text,
      "certificates": certificates.text,
      "date": selectedDate?.toIso8601String() ?? "",
      "time": selectedTime?.format(context) ?? "",
      "songImagesUploaded": songImagesUploaded,
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
          const SnackBar(content: Text("Agro Package Submitted!")),
        );

        // Clear form
        eventName.clear();
        description.clear();
        capacity.clear();
        price.clear();
        location.clear();
        cropType.clear();
        season.clear();
        farmSize.clear();
        certificates.clear();
        imageUrl.clear();
        setState(() {
          selectedDate = null;
          selectedTime = null;
          songImagesUploaded = false;
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
          const Text("Agro Package Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          customTextField("Event Name", eventName),
          customTextField("Description", description, maxLines: 3),
          customTextField("Price", price),
          customTextField("Location", location),
          customTextField("Image URL", imageUrl), // ✅ New field
          const SizedBox(height: 10),
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
          customTextField("Crop Type", cropType),
          customTextField("Season", season),
          customTextField("Farm Size", farmSize),
          customTextField("Certificates", certificates),
          CheckboxListTile(
            title: const Text("Song Images Uploaded"),
            value: songImagesUploaded,
            onChanged: (val) => setState(() => songImagesUploaded = val!),
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
