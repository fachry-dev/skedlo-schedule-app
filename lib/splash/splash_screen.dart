// import 'dart:async';
import 'package:flutter/material.dart';
import 'spalsh_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashScreenController.handleNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAD7CD), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'skedlo',
              style: TextStyle(
                fontSize: 64,
                fontFamily: 'Outfit', 
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D503C),
                letterSpacing: -2,
              ),
            ),
            Text(
              'schedule app',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Petemoss',
                fontStyle: FontStyle.italic,
                color: const Color(0xFF2D503C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
