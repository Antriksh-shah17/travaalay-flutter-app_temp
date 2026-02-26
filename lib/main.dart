import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:traavaalay/View/SplashScreen.dart';


Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC30I24x8plVGO46ZUA2J8dXj6W6g6K1ZM",
      appId: "1:1042309955585:android:32fbd1008201cbc9a54000", 
      messagingSenderId: "1042309955585", 
      projectId: "beproject-f65ca")
  );
  
  runApp(const TravaalayApp());
}

class TravaalayApp extends StatelessWidget {
  const TravaalayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travaalay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const SplashScreen(),
    );
  }
}