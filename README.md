# Ztaxi

Base Flutter importada de Elite Taxi bajo licencia MIT. Consulta [IMPORTACION-ZTAXI.md](IMPORTACION-ZTAXI.md) para la procedencia, la configuración pendiente y las limitaciones conocidas. Esta copia aún requiere adaptación y validación antes de operar.

---

# 🚕 Elite Taxi App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-2.19+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Ready-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive, production-ready taxi booking application built with Flutter. This app provides seamless ride-hailing services for both passengers and drivers, featuring real-time GPS tracking, secure payment integration, and Firebase-powered backend services.

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Technologies Used](#-technologies-used)
- [API Keys Setup](#-api-keys-setup)
- [Firebase Setup](#-firebase-setup)
- [Building the App](#-building-the-app)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### For Passengers
- 🔐 **Secure Authentication**: Phone number-based OTP verification using Firebase Auth
- 🗺️ **Interactive Maps**: Real-time Google Maps integration with custom markers and route visualization
- 📍 **Location Services**: Pick up and drop-off location selection with autocomplete search
- 💳 **Payment Integration**: Multiple payment methods with secure credit card management
- 📊 **Ride History**: Complete history of past rides with detailed information
- 👤 **Profile Management**: Edit personal information and preferences
- 🎫 **Promo Codes**: Apply discount codes for rides
- 🔔 **Real-time Tracking**: Live driver location and ETA updates

### For Drivers
- 🚗 **Vehicle Registration**: Complete vehicle information and documentation upload
- ✅ **Driver Verification**: Admin verification system for driver accounts
- 📱 **Ride Management**: Accept, cancel, and manage ride requests
- 💰 **Earnings Dashboard**: Track earnings and payment history
- 📋 **Profile Setup**: Driver profile configuration with vehicle details

### General Features
- 🎨 **Modern UI/UX**: Beautiful, intuitive interface built with Material Design
- 🌐 **Multi-platform Support**: iOS, Android, Web, Linux, macOS, and Windows
- 🔄 **State Management**: Efficient state management using GetX
- 🎯 **Offline Support**: Basic offline functionality with local caching
- 🔒 **Security**: Secure data handling and authentication
- ⚡ **Performance**: Optimized for smooth performance and fast load times

## 📱 Screenshots

_Add screenshots of your app here_

## 🛠️ Prerequisites

Before you begin, ensure you have met the following requirements:

- **Flutter SDK**: Version 3.0 or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Version 2.19.0 or higher (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **Firebase Account**: For backend services
- **Google Cloud Platform Account**: For Maps API and Places API
- **Git**: For version control

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/elite_taxi_app.git
   cd elite_taxi_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Install dependencies for the custom package**
   ```bash
   cd packages/google_api_headers
   flutter pub get
   cd ../..
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Environment Setup

1. **Android Configuration**
   - Minimum SDK: 21
   - Target SDK: 34
   - Compile SDK: 34

2. **iOS Configuration**
   - Minimum iOS: 12.0
   - Deployment Target: iOS 12.0

## 📁 Project Structure

```
elite_taxi_app/
├── android/                 # Android platform-specific code
│   ├── app/
│   │   ├── build.gradle    # Android build configuration
│   │   └── src/
│   └── settings.gradle     # Gradle settings
├── ios/                     # iOS platform-specific code
├── lib/
│   ├── controller/         # State management controllers (GetX)
│   │   ├── auth_controller.dart
│   │   └── polyline_handler.dart
│   ├── driver/             # Driver-specific screens and features
│   │   ├── car_registration/
│   │   ├── profile_setup.dart
│   │   └── verification_pending_screen.dart
│   ├── models/             # Data models
│   │   └── user_model/
│   ├── utlis/              # Utilities and constants
│   │   ├── app_colors.dart
│   │   └── app_constant.dart
│   ├── views/              # UI screens
│   │   ├── decision_screen/
│   │   ├── login_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   ├── payment.dart
│   │   └── profile_settings.dart
│   ├── widgets/            # Reusable UI components
│   │   ├── green_intro_widget.dart
│   │   ├── login_widget.dart
│   │   ├── my_button.dart
│   │   └── otp_verification_widget.dart
│   ├── firebase_options.dart
│   ├── home.dart
│   └── main.dart           # App entry point
├── assets/                 # Images, fonts, and other assets
├── packages/               # Local packages
│   └── google_api_headers/ # Custom Google API headers package
├── pubspec.yaml            # Flutter dependencies
└── README.md
```

## 🔧 Technologies Used

### Core Framework
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language

### State Management
- **GetX**: State management, dependency injection, and routing

### Backend Services
- **Firebase Authentication**: User authentication with OTP
- **Cloud Firestore**: NoSQL database for app data
- **Firebase Storage**: Image and file storage

### Maps & Location
- **Google Maps Flutter**: Interactive maps and markers
- **Google Places API**: Location autocomplete and search
- **Geocoding**: Address conversion to coordinates

### UI/UX
- **Google Fonts**: Poppins font family
- **Material Design**: UI components and design system
- **Flutter SVG**: SVG image support

### Additional Packages
- **Pinput**: OTP input widgets
- **Image Picker**: Camera and gallery access
- **Smart Auth**: Enhanced authentication features
- **Flutter Credit Card**: Credit card input widgets
- **Country Code Picker**: Phone number country selection

## 🔑 API Keys Setup

### Google Maps API

1. **Create a Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable Required APIs**
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Geocoding API

3. **Create API Keys**
   - Navigate to "APIs & Services" > "Credentials"
   - Create credentials > API Key
   - Restrict the API key to the required APIs

4. **Configure API Keys**

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ANDROID_API_KEY"/>
   ```

   **iOS** (`ios/Runner/AppDelegate.swift`):
   ```swift
   GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
   ```

## 🔥 Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name and follow setup wizard
4. Enable Google Analytics (optional)

### 2. Configure Android App

1. In Firebase Console, click "Add app" > Android
2. Enter package name: `com.example.elite_taxi_app`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 3. Configure iOS App

1. In Firebase Console, click "Add app" > iOS
2. Enter bundle ID: `com.example.eliteTaxiApp`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory using Xcode

### 4. Enable Firebase Services

- **Authentication**: Enable Phone authentication
- **Cloud Firestore**: Create database in test mode (or production mode with rules)
- **Storage**: Enable Cloud Storage with appropriate rules

### 5. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /rides/{rideId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 6. Generate Firebase Options

If not already generated:
```bash
flutterfire configure
```

## 🏗️ Building the App

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📝 Code Generation

If using code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Google Maps team for mapping services
- All open-source package contributors

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

## 🔮 Roadmap

- [ ] Push notifications for ride updates
- [ ] In-app chat between driver and passenger
- [ ] Multiple language support
- [ ] Dark mode
- [ ] Advanced analytics dashboard
- [ ] Rating and review system
- [ ] Ride sharing options

---

**Made with ❤️ using Flutter**
