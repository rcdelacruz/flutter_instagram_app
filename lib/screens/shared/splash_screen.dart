import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instagram-style logo
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Color(0xFF0095F6),
            ),
            SizedBox(height: 24),
            Text(
              'Instagram Clone',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF262626),
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0095F6)),
            ),
          ],
        ),
      ),
    );
  }
}
