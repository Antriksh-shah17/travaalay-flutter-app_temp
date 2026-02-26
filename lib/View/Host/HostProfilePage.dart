import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traavaalay/View/Login.dart';

class HostProfilePage extends StatefulWidget {
  const HostProfilePage({super.key});

  @override
  State<HostProfilePage> createState() => _HostProfilePageState();
}

class _HostProfilePageState extends State<HostProfilePage> {
  String verificationStatus = "Pending Verification";
  final String userId = "host123"; // TODO: use FirebaseAuth.instance.currentUser!.uid

  /// Pick image and upload to Firebase Storage + save to Firestore
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
      // Upload to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("host_documents/$userId/$fileName");

      UploadTask uploadTask = ref.putFile(file);

      // Await upload completion
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save in Firestore
      await FirebaseFirestore.instance
          .collection("verificationRequests")
          .doc(userId)
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

  /// Save overall verification request in Firestore
  Future<void> _proceedToVerify() async {
    setState(() {
      verificationStatus = "Sending request...";
    });

    try {
      await FirebaseFirestore.instance
          .collection("verificationRequests")
          .doc(userId)
          .set({
        "name": "John Doe",
        "email": "johndoe@example.com",
        "phone": "+91 9876543210",
        "location": "Pune, Maharashtra",
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
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.png"),
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
                  children: const [
                    Text("John Doe",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("johndoe@example.com",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 6),
                    Text("+91 9876543210",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 6),
                    Text("Pune, Maharashtra",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
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
