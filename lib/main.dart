import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'services/firestore_service.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/address_provider.dart';
import 'providers/currency_provider.dart';

import 'screens/login_screens/login_page.dart';
import 'screens/login_screens/signup.dart';
import 'screens/login_screens/welcome_page.dart';
import '/providers/product_provider.dart';
import '/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProxyProvider2<ThemeProvider, CurrencyProvider, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, themeProvider, currencyProvider, userProvider) {
            userProvider?.syncWithProviders(themeProvider, currencyProvider);
            return userProvider ?? UserProvider();
          },
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        // BLoC Providers
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => NotesBloc(FirestoreService()),
          lazy: false,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PlantGuard AI',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/welcome',
            routes: {
              '/welcome': (context) => const WelcomePage(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignUpPage(),
              '/home': (context) => const HomePage(),
            },
            builder: (context, child) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    final User? user = snapshot.data;
                    if (user != null) {
                      Future.microtask(() {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/home', 
                          (route) => false,
                        );
                      });
                    }
                  }
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}