import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Space
            Spacer(flex: 1), // Add some space at the top

            // Top Text: "Detect early, Protect Always."
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Detect early, Protect Always.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20), // Small spacing between text and logo

            // Centered Logo (both vertically and horizontally)
            Expanded(
              flex: 3, // Give more weight to the logo section
              child: Center(
                child: Image.asset(
                  'assets/plantguard_logo.png',
                  width: 401,
                  height: 172,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Spacer(flex: 1), // Add some space below the logo

            // Footer Text: "PlantGuard"
            Text(
              "PlantGuard",
              style: TextStyle(
                color: const Color(0xFF00FF00), // Bright green color
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}