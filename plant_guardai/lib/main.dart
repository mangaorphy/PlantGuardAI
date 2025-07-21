import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/home_page.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/address_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/currency_provider.dart';

void main() {
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
        ChangeNotifierProxyProvider2<
          ThemeProvider,
          CurrencyProvider,
          UserProvider
        >(
          create: (context) => UserProvider(),
          update: (context, themeProvider, currencyProvider, userProvider) {
            userProvider?.syncWithProviders(themeProvider, currencyProvider);
            return userProvider ?? UserProvider();
          },
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PlantGuard AI',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
