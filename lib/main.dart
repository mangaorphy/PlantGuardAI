import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'services/firestore_service.dart';
import 'screens/login_page.dart';
import 'screens/signup.dart';

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
          lazy: false, // Force immediate creation
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        home: StreamBuilder<User?>(
        
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return BlocProvider.value(
                value: BlocProvider.of<NotesBloc>(context),
                child: LoginPage(),
              );
            }
            return LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/home': (context) => BlocProvider.value(
                value: BlocProvider.of<NotesBloc>(context),
                child: LoginPage(),
              ),
        },
      ),
    );
  }
}