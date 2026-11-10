# Setup Guide - Elite Taxi App

This comprehensive guide will walk you through setting up the Elite Taxi App development environment from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Flutter Installation](#flutter-installation)
3. [Firebase Setup](#firebase-setup)
4. [Google Cloud Setup](#google-cloud-setup)
5. [Project Configuration](#project-configuration)
6. [Running the App](#running-the-app)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **Operating System**: Windows 10/11, macOS 10.14+, or Linux
- **Git**: [Download Git](https://git-scm.com/downloads)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **JDK**: Java Development Kit 17 or higher

### Required Accounts

- **Google Account**: For Firebase and Google Cloud Platform
- **GitHub Account**: For version control (optional)

## Flutter Installation

### Windows

1. **Download Flutter SDK**
   - Visit [Flutter Installation Guide](https://docs.flutter.dev/get-started/install/windows)
   - Download the latest stable Flutter SDK
   - Extract to `C:\src\flutter` (or your preferred location)

2. **Add to PATH**
   - Add `C:\src\flutter\bin` to your system PATH
   - Restart your terminal

3. **Verify Installation**
   ```bash
   flutter doctor
   ```

4. **Install Additional Tools**
   ```bash
   flutter doctor --android-licenses
   ```

### macOS

1. **Download Flutter SDK**
   ```bash
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **Add to PATH**
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Install Xcode**
   - Install from App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

### Linux

1. **Install Dependencies**
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
   ```

2. **Download Flutter**
   ```bash
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

3. **Add to PATH**
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `elite-taxi-app`
4. Disable Google Analytics (optional)
5. Click **"Create project"**

### 2. Configure Android App

1. In Firebase Console, click **"Add app"** > **Android**
2. Register app:
   - **Package name**: `com.example.elite_taxi_app`
   - **App nickname**: `Elite Taxi Android`
   - **Debug signing certificate**: Leave blank for now
3. Download `google-services.json`
4. Place file in: `android/app/google-services.json`

### 3. Configure iOS App (macOS only)

1. In Firebase Console, click **"Add app"** > **iOS**
2. Register app:
   - **Bundle ID**: `com.example.eliteTaxiApp`
   - **App nickname**: `Elite Taxi iOS`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into `Runner` folder
6. Ensure "Copy items if needed" is checked

### 4. Enable Firebase Services

#### Authentication

1. Go to **Authentication** > **Get started**
2. Enable **Phone** sign-in method
3. Configure authorized domains

#### Cloud Firestore

1. Go to **Firestore Database** > **Create database**
2. Start in **test mode** (for development)
3. Select location closest to your users
4. Click **"Enable"**

**Security Rules:**
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
    match /drivers/{driverId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == driverId;
    }
  }
}
```

#### Cloud Storage

1. Go to **Storage** > **Get started**
2. Start in **test mode**
3. Select location

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /drivers/{driverId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == driverId;
    }
  }
}
```

### 5. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 6. Configure FlutterFire

```bash
flutterfire configure
```

Follow the prompts to select:
- Firebase project
- Platforms (Android, iOS, Web)

## Google Cloud Setup

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing Firebase project
3. Note your Project ID

### 2. Enable Required APIs

Enable these APIs in Google Cloud Console:

- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Places API**
- **Directions API**
- **Geocoding API**
- **Geocoding API (New)**

Steps:
1. Go to **APIs & Services** > **Library**
2. Search for each API
3. Click **"Enable"**

### 3. Create API Keys

1. Go to **APIs & Services** > **Credentials**
2. Click **"Create Credentials"** > **API Key**
3. Copy the API key
4. Click **"Restrict key"**
5. **Application restrictions**:
   - Android apps: Add package name and SHA-1
   - iOS apps: Add bundle ID
6. **API restrictions**: Restrict to:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Geocoding API

### 4. Get SHA-1 Certificate Fingerprint (Android)

**Debug keystore:**
```bash
cd android
./gradlew signingReport
```

Look for `SHA1` in the output.

**Or manually:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 5. Configure API Keys in App

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Project Configuration

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/elite_taxi_app.git
cd elite_taxi_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Install Local Package Dependencies

```bash
cd packages/google_api_headers
flutter pub get
cd ../..
```

### 4. Update Package Name (Optional)

If you want to change the package name:

**Android:**
1. Update `android/app/build.gradle`:
   ```gradle
   applicationId "com.yourcompany.elite_taxi_app"
   namespace "com.yourcompany.elite_taxi_app"
   ```

2. Update package in `AndroidManifest.xml`
3. Rename package directories in `android/app/src/main/kotlin/`

**iOS:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner in Project Navigator
3. Update Bundle Identifier

### 5. Configure Build Files

The project uses modern Gradle plugin system. Ensure:

- `android/settings.gradle` uses declarative plugins
- `android/app/build.gradle` uses plugins block
- `android/app/src/main/AndroidManifest.xml` doesn't have package attribute

## Running the App

### Check Flutter Setup

```bash
flutter doctor -v
```

### Get Dependencies

```bash
flutter pub get
```

### Run on Android

```bash
flutter run
```

Or specify device:
```bash
flutter devices
flutter run -d <device-id>
```

### Run on iOS (macOS only)

```bash
flutter run
```

### Run on Web

```bash
flutter run -d chrome
```

### Build Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Troubleshooting

### Flutter Doctor Issues

**Android license not accepted:**
```bash
flutter doctor --android-licenses
```

**Missing Android SDK:**
- Install via Android Studio > SDK Manager
- Set `ANDROID_HOME` environment variable

**Xcode not configured (macOS):**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Build Issues

**Gradle build fails:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Pod install issues (iOS):**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**Firebase configuration:**
- Ensure `google-services.json` is in correct location
- Verify package name matches Firebase project
- Check API keys are correctly configured

### Runtime Issues

**Maps not showing:**
- Verify API keys are correct
- Check API restrictions in Google Cloud Console
- Ensure APIs are enabled

**Authentication fails:**
- Verify Firebase Authentication is enabled
- Check phone number format
- Ensure Firebase project is active

**Firestore connection:**
- Check security rules
- Verify database region
- Check internet connection

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Platform](https://developers.google.com/maps)
- [GetX Documentation](https://github.com/jonataslaw/getx)

## Need Help?

If you encounter issues:
1. Check [Troubleshooting](#troubleshooting) section
2. Search existing GitHub issues
3. Create a new issue with details

---

**Happy Coding! 🚀**
