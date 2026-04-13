import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau Icon
            Container(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/app_icon/pajajap-gradient.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 30),

            // App Name
            const Text(
              'Pajajap',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            const Text(
              'Pasar Digital Terpercaya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 0, 163, 16)),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
