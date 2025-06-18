import 'package:flutter/material.dart';
import 'screens/login_screens/welcome_page.dart';
import 'screens/login_screens/login_page1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantGuard_AI',
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

