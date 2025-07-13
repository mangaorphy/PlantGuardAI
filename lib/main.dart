// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'services/firestore_service.dart';

import 'screens/login_screens/login_page.dart';
import 'screens/login_screens/signup.dart';
import 'screens/login_screens/welcome_page.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => NotesBloc(FirestoreService()),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'PlantGuard',
        debugShowCheckedModeBanner: false,
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => WelcomePage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/home': (context) => HomePage(),
        },
        builder: (context, child) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final User? user = snapshot.data;
                if (user != null) {
                  // If already logged in, redirect to home
                  Future.microtask(() {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  });
                }
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}