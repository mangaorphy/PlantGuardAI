# 🌱 PlantGuard AI

An intelligent plant care application that helps farmers and gardeners identify plant diseases and find appropriate treatments through AI-powered analysis and a comprehensive product marketplace.

## 📱 App Overview

PlantGuard AI is a Flutter-based mobile application that combines artificial intelligence with e-commerce to provide a complete plant care solution. Users can capture images of their plants, get AI-powered disease diagnosis, and purchase recommended treatments directly through the app.

## ✨ Key Features

### 🔍 **Plant Disease Detection**
- **AI-Powered Analysis**: Upload or capture plant images for disease identification
- **Real-time Diagnosis**: Get instant analysis results with treatment recommendations
- **Image History**: Track all your plant analysis sessions

### 🛒 **E-Commerce Platform**
- **Product Catalog**: Browse pesticides, fertilizers, and plant care products
- **Smart Search**: Find products by name, category, or plant disease
- **Shopping Cart**: Add multiple items and manage quantities
- **Wishlist**: Save products for later purchase

### 💳 **Payment Integration**
- **MTN Mobile Money**: Seamless payments for Rwanda users
- **Order Management**: Track your purchase history and order status
- **Address Management**: Save multiple delivery addresses

### 🎨 **User Experience**
- **Dark/Light Themes**: Customizable app appearance
- **Multi-Language Support**: Available in English, Kinyarwanda, French, and Swahili
- **Currency Conversion**: Support for RWF, USD, EUR, KES, and UGX
- **Responsive Design**: Optimized for phones and tablets

### 👤 **User Management**
- **Firebase Authentication**: Secure login with email/password and Google Sign-In
- **Profile Management**: Update personal information and preferences
- **Settings**: Customize app behavior and notifications

## 🏗️ Technical Architecture

### **State Management**
- **Provider Pattern**: Primary state management for business logic
  - ThemeProvider, CartProvider, WishlistProvider, UserProvider, etc.
- **BLoC Pattern**: Authentication and complex event handling
- **Firebase Integration**: Real-time data synchronization

### **Dependencies**
```yaml
dependencies:
  flutter: ^3.8.1
  firebase_core: ^3.15.0
  firebase_auth: ^5.6.1
  cloud_firestore: ^5.6.10
  provider: ^6.1.5
  flutter_bloc: ^9.1.1
  google_sign_in: ^6.1.5
  image_picker: ^1.1.2
  currency_converter_pro: ^0.0.7
  http: ^0.13.6
  shared_preferences: ^2.5.3
  video_player: ^2.8.5
```

### **Project Structure**
```
lib/
├── main.dart                     # App entry point
├── providers/                    # State management
│   ├── theme_provider.dart
│   ├── cart_provider.dart
│   ├── wishlist_provider.dart
│   ├── user_provider.dart
│   ├── product_provider.dart
│   └── ...
├── bloc/                        # Authentication BLoC
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
├── screens/                     # UI screens
│   ├── home_page.dart
│   ├── login_screens/
│   ├── profile/
│   ├── payment_screens/
│   └── ...
├── ui/                          # UI components
│   ├── models/
│   └── widgets/
├── services/                    # External services
├── utils/                       # Utilities
└── assets/                      # Images and resources
```

## 🚀 Getting Started

### **For End Users (APK Installation)**

#### **📱 Android Installation**
1. **Download APK**: Get the latest `app-release.apk` (55MB) from the releases
2. **Enable Unknown Sources**:
   - Go to Settings → Security
   - Enable "Install from Unknown Sources" or "Install Unknown Apps"
3. **Install**: Open the APK file and tap "Install"
4. **Launch**: Find PlantGuard AI in your app drawer

#### **⚠️ Device Requirements**
- Android 6.0 (API level 23) or higher
- At least 200MB free storage
- Internet connection for full functionality
- Camera access for plant analysis

#### **❌ Not Compatible With**
- iPhone/iPad (iOS devices)
- Windows computers
- Mac computers

### **For Developers (Source Code)**

#### **🛠️ Prerequisites**
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio or VS Code
- Android device or emulator
- Firebase project setup

#### **⚙️ Setup Instructions**

1. **Clone Repository**
   ```bash
   git clone https://github.com/mangaorphy/PlantGuardAI.git
   cd PlantGuardAI
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Add your `google-services.json` to `android/app/`
   - Configure Firebase Authentication and Firestore
   - Update Firebase rules as needed

4. **Run the App**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on connected device
   flutter run
   
   # Build APK
   flutter build apk --release
   ```

#### **🔧 Development Commands**
```bash
# Hot reload during development
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit

# Build for release
flutter build apk --release

# Run tests
flutter test

# Check code issues
flutter analyze

# Format code
flutter format .
```

## 📊 Features Overview

### **🏠 Home Screen**
- Featured products carousel
- Quick plant analysis access
- Category-based browsing
- Search functionality

### **🔍 Plant Analysis**
- Camera integration for plant photos
- AI-powered disease detection
- Treatment recommendations
- Analysis history tracking

### **🛍️ Product Marketplace**
- Pesticides and fertilizers catalog
- Advanced filtering and sorting
- Product details with usage guides
- Quick add to cart/wishlist

### **🛒 Shopping Experience**
- Cart management with quantity controls
- Wishlist for saved items
- Multiple payment options
- Order tracking and history

### **👤 User Profile**
- Personal information management
- Order history and tracking
- App settings and preferences
- Address book management

## 🌍 Supported Regions

### **🇷🇼 Rwanda (Primary Market)**
- MTN Mobile Money integration
- Local currency (RWF) support
- Kinyarwanda language support
- Local product availability

### **🌍 International Support**
- Multi-currency support (USD, EUR, KES, UGX)
- Multiple language options
- Expandable payment methods

## 🔒 Security & Privacy

- **Firebase Authentication**: Secure user management
- **Data Encryption**: All user data encrypted in transit
- **Privacy Compliant**: GDPR and local privacy law compliance
- **Secure Payments**: PCI DSS compliant payment processing

## 🚧 Troubleshooting

### **Installation Issues**
- **"Installation blocked"**: Enable Unknown Sources in Settings
- **"App not installed"**: Ensure sufficient storage space
- **"No app found"**: Download a file manager app

### **App Issues**
- **Crashes on startup**: Check internet connection and restart
- **Images not loading**: Verify network connectivity
- **Payment failures**: Contact support with transaction details

## 📞 Support

### **🐛 Bug Reports**
- Open an issue on GitHub with:
  - Device model and Android version
  - Steps to reproduce the problem
  - Screenshots if applicable

### **💡 Feature Requests**
- Submit feature ideas through GitHub issues
- Include use case and expected behavior

### **📧 Contact**
- **Developer**: mangaorphy
- **Repository**: [PlantGuardAI](https://github.com/mangaorphy/PlantGuardAI)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Firebase**: For backend services
- **Contributors**: All developers who contributed to this project
- **Users**: Our community of farmers and gardeners

---

**Version**: 1.0.0  
**Build**: July 31, 2025  
**Platform**: Android  
**Minimum SDK**: Android 6.0 (API 23)
