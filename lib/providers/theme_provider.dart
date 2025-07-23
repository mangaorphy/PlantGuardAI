import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _selectedTheme = 'Dark';

  ThemeMode get themeMode => _themeMode;
  String get selectedTheme => _selectedTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Update theme based on user selection
  void updateTheme(String theme) {
    _selectedTheme = theme;

    switch (theme) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'Auto':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.dark;
    }

    notifyListeners();
  }

  // Get theme data for light mode
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  // Get theme data for dark mode
  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  // Get current background color
  Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;

  // Get current text color
  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  // Get current secondary text color
  Color get secondaryTextColor =>
      isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  // Get current card color
  Color get cardColor => isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;

  // Get current border color
  Color get borderColor => isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
}
