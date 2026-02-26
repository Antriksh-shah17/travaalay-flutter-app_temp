import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:traavaalay/View/SplashScreen.dart';


Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  
  
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