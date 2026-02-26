import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traavaalay/View/Login.dart';

class TranslatorProfilePage extends StatefulWidget {
  final Map<String, dynamic> user; // pass the translator JSON

  const TranslatorProfilePage({super.key, required this.user});

  @override
  State<TranslatorProfilePage> createState() => _TranslatorProfilePageState();
}

class _TranslatorProfilePageState extends State<TranslatorProfilePage> {
  String verificationStatus = "Pending Verification";

  /// Pick image/document and upload to Firebase Storage + save in Firestore
  Future<void> _uploadDocument(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = "${type}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    setState(() {
      verificationStatus = "Uploading $type...";
    });

    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("translator_documents/${widget.user['id']}/$fileName");

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("verificationRequests")
          .doc(widget.user['id'].toString())
          .collection("documents")
          .add({
        "type": type,
        "fileUrl": downloadUrl,
        "status": "pending",
        "uploadedAt": DateTime.now(),
      });

      setState(() {
        verificationStatus = "$type Uploaded (Pending Verification)";
      });
    } catch (e) {
      setState(() {
        verificationStatus = "Error uploading $type ❌";
      });
      print("Upload error: $e");
    }
  }

  /// Send verification request
  Future<void> _proceedToVerify() async {
    setState(() {
      verificationStatus = "Sending request...";
    });

    try {
      await FirebaseFirestore.instance
          .collection("verificationRequests")
          .doc(widget.user['id'].toString())
          .set({
        "name": widget.user['name'] ?? "Unknown",
        "email": widget.user['email'] ?? "",
        "city": widget.user['city'] ?? "",
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        verificationStatus = "Pending Admin Approval";
      });
    } catch (e) {
      setState(() {
        verificationStatus = "Error sending request ❌";
      });
      print("Firestore error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user['profileImage'] != null
                  ? NetworkImage(user['profileImage'])
                  : const AssetImage("assets/Gauri.jpeg") as ImageProvider,
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(user['name'] ?? "No Name",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(user['email'] ?? "No Email",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(user['city'] ?? "Unknown City",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            buildOption(
              icon: Icons.badge,
              title: "Upload ID Proof",
              onTap: () => _uploadDocument("ID Proof"),
            ),
            buildOption(
              icon: Icons.verified,
              title: "Upload Certificates",
              onTap: () => _uploadDocument("Certificate"),
            ),
            buildOption(
              icon: Icons.verified_user,
              title: "Proceed to Verify",
              onTap: _proceedToVerify,
            ),
            const SizedBox(height: 15),
            Text(
              "Status: $verificationStatus",
              style: TextStyle(
                fontSize: 14,
                color: verificationStatus.contains("Approval")
                    ? Colors.orange
                    : verificationStatus.contains("Verified")
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: navigate to edit page
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
