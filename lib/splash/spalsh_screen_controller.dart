import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreenController {
  static void handleNavigation(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }
}