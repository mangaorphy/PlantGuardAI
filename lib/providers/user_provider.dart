import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_model.dart';
import 'theme_provider.dart';
import 'currency_provider.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  File? _profileImageFile;
  String _currentLanguage = 'English';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  File? get profileImageFile => _profileImageFile;
  String get currentLanguage => _currentLanguage;

  // Initialize with default user data
  void initializeUser() {
    _user = UserModel(
      id: '1',
      name: 'Mariam',
      email: 'mariam@example.com',
      phone: '+250 788 123 456',
      location: 'Kigali, Rwanda',
      profileImage: 'assets/images/Rectangle 42.png',
      language: 'English',
      notificationsEnabled: true,
      emailNotifications: true,
      smsNotifications: false,
      orderUpdates: true,
      promotionalOffers: true,
      darkMode: true,
      biometricLogin: false,
      autoBackup: true,
      locationServices: true,
      crashReporting: true,
      currency: 'RWF',
      theme: 'Dark',
    );
    _currentLanguage = 'English';
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? profileImage,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      _user = _user!.copyWith(
        name: name,
        email: email,
        phone: phone,
        location: location,
        profileImage: profileImage,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updatePreferences({
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _user = _user!.copyWith(
        language: language,
        notificationsEnabled: notificationsEnabled,
        emailNotifications: emailNotifications,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Change profile image
  Future<void> changeProfileImage(String imagePath) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      _user = _user!.copyWith(profileImage: imagePath);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  void logout() {
    _user = null;
    _profileImageFile = null;
    _currentLanguage = 'English';
    notifyListeners();
  }

  // Update profile image file
  void updateProfileImageFile(File? imageFile) {
    _profileImageFile = imageFile;
    notifyListeners();
  }

  // Remove profile image
  void removeProfileImage() {
    _profileImageFile = null;
    notifyListeners();
  }

  // Update language immediately (no API call simulation)
  void setLanguage(String language) {
    _currentLanguage = language;
    if (_user != null) {
      _user = _user!.copyWith(language: language);
    }
    notifyListeners();
  }

  // Update notification settings
  void updateNotificationSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? orderUpdates,
    bool? promotionalOffers,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        notificationsEnabled: pushNotifications,
        emailNotifications: emailNotifications,
        smsNotifications: smsNotifications,
        orderUpdates: orderUpdates,
        promotionalOffers: promotionalOffers,
      );
      notifyListeners();
    }
  }

  // Update app settings
  void updateAppSettings({bool? darkMode, String? theme, String? currency}) {
    if (_user != null) {
      _user = _user!.copyWith(
        darkMode: darkMode,
        theme: theme,
        currency: currency,
      );
      notifyListeners();
    }
  }

  // Update security settings
  void updateSecuritySettings({bool? biometricLogin}) {
    if (_user != null) {
      _user = _user!.copyWith(biometricLogin: biometricLogin);
      notifyListeners();
    }
  }

  // Update data settings
  void updateDataSettings({
    bool? autoBackup,
    bool? locationServices,
    bool? crashReporting,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        autoBackup: autoBackup,
        locationServices: locationServices,
        crashReporting: crashReporting,
      );
      notifyListeners();
    }
  }

  // Sync with other providers
  void syncWithProviders(
    ThemeProvider? themeProvider,
    CurrencyProvider? currencyProvider,
  ) {
    if (_user != null) {
      // Sync theme settings
      if (themeProvider != null &&
          _user!.theme != themeProvider.selectedTheme) {
        themeProvider.updateTheme(_user!.theme);
      }

      // Sync currency settings
      if (currencyProvider != null &&
          _user!.currency != currencyProvider.selectedCurrency) {
        currencyProvider.updateCurrency(_user!.currency);
      }
    }
  }

  // Login (for future implementation)
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, create a user
      _user = UserModel(
        id: '1',
        name: 'Mariam',
        email: email,
        phone: '+250 788 123 456',
        location: 'Kigali, Rwanda',
        profileImage: 'assets/images/Rectangle 42.png',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
