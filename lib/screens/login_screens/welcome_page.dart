import 'package:flutter/material.dart';
import 'login_page1.dart'; // Import your LoginPage

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isNavigating = false; // To prevent multiple taps

  @override
  void initState() {
    super.initState();

    // Navigate to LoginPage after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      if (!_isNavigating) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(flex: 1),

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

            SizedBox(height: 20),

            Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  'assets/plantguard_logo.png',
                  width: 401,
                  height: 172,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Spacer(flex: 1),

            // Make "PlantGuard" text tappable
            GestureDetector(
              onTap: () {
                // Prevent multiple taps
                if (!_isNavigating) {
                  setState(() {
                    _isNavigating = true;
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              },
              child: Text(
                "PlantGuard",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}