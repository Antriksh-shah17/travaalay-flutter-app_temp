import 'package:flutter/material.dart';
import 'package:traavaalay/View/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromRGBO(96, 140, 148, 1),
    body: Center(
      child: Transform.translate(
        offset: const Offset(-20, 0), // shift left by 20 pixels
        child: SizedBox(
          height: 280,
          width: 280,
          child: Image.asset(
            "assets/logog.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}


}