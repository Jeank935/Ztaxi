# Architecture Documentation

This document describes the architecture and design decisions of the Elite Taxi App.

## Overview

Elite Taxi App is built using Flutter with a clean architecture approach, utilizing GetX for state management and Firebase as the backend service provider.

## Architecture Pattern

The app follows a **Model-View-Controller (MVC)** pattern with GetX for state management:

- **Model**: Data models representing entities (User, Ride, etc.)
- **View**: UI screens and widgets
- **Controller**: Business logic and state management using GetX Controllers

## Project Structure

```
lib/
├── controller/          # State management (GetX Controllers)
├── models/             # Data models
├── views/              # Screen widgets
├── widgets/            # Reusable UI components
├── utlis/              # Utilities and constants
├── driver/             # Driver-specific features
└── main.dart          # Application entry point
```

## State Management

### GetX Controllers

The app uses GetX for:
- **State Management**: Reactive state updates
- **Dependency Injection**: Controller lifecycle management
- **Navigation**: Route management

**Key Controllers:**
- `AuthController`: Handles authentication, user session, and routing decisions
- `PolylineHandler`: Manages map routes and polylines

### Example Controller Structure

```dart
class AuthController extends GetxController {
  // Observable state
  final Rx<UserModel> user = UserModel().obs;

  // Methods
  Future<void> signIn(String phoneNumber) async {
    // Authentication logic
  }

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // Initialization
  }
}
```

## Data Flow

```
User Interaction
    ↓
View Widget
    ↓
Controller Method
    ↓
Firebase Service / API
    ↓
Update Controller State
    ↓
Reactive UI Update (GetX)
```

## Backend Services

### Firebase Services

1. **Firebase Authentication**
   - Phone number-based OTP verification
   - User session management
   - Role-based access (Driver/Passenger)

2. **Cloud Firestore**
   - User profiles
   - Ride data
   - Driver information
   - Payment history

3. **Firebase Storage**
   - User profile images
   - Driver documents
   - Vehicle images

### Google Services

1. **Google Maps API**
   - Map rendering
   - Custom markers
   - Route visualization

2. **Google Places API**
   - Location autocomplete
   - Place details
   - Search functionality

3. **Geocoding API**
   - Address to coordinates conversion
   - Reverse geocoding

## Key Features Implementation

### Authentication Flow

```
1. User enters phone number
2. OTP sent via Firebase Auth
3. User verifies OTP
4. Create/update user in Firestore
5. Navigate to appropriate screen (Driver/Passenger)
```

### Ride Booking Flow

```
1. User selects pickup location
2. User selects drop-off location
3. Display route on map
4. Calculate fare estimate
5. Confirm ride
6. Match with available driver
7. Track ride in real-time
8. Complete ride and payment
```

### Driver Registration Flow

```
1. Driver selects "Login As Driver"
2. Vehicle registration form
3. Upload documents/images
4. Submit for verification
5. Admin verification
6. Driver can accept rides
```

## Dependencies

### Core Dependencies

- **flutter**: Core Flutter framework
- **get**: State management and navigation
- **firebase_core**: Firebase initialization
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **firebase_storage**: File storage

### UI Dependencies

- **google_fonts**: Typography
- **flutter_svg**: SVG support
- **google_maps_flutter**: Maps integration
- **flutter_credit_card**: Payment UI

### Utility Dependencies

- **google_maps_webservice**: Places API
- **geocoding**: Address conversion
- **image_picker**: Camera/gallery access
- **pinput**: OTP input

## Code Organization Principles

1. **Separation of Concerns**: Each file has a single responsibility
2. **Reusability**: Common widgets and utilities are extracted
3. **Consistency**: Follow Flutter and Dart best practices
4. **Maintainability**: Clear naming and structure

## Best Practices

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `lowerCamelCase` or `SCREAMING_CAPS`

### File Organization

- Group related files in folders
- Keep files focused and small
- Use meaningful file names
- Separate concerns into different files

### Code Style

- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

## Testing Strategy

### Unit Tests
- Test business logic in controllers
- Test utility functions
- Test data models

### Widget Tests
- Test UI components
- Test user interactions
- Test state updates

### Integration Tests
- Test complete user flows
- Test API integrations
- Test navigation

## Performance Considerations

1. **Lazy Loading**: Load data as needed
2. **Image Optimization**: Compress and cache images
3. **State Management**: Use reactive updates efficiently
4. **Network Calls**: Implement caching and retry logic
5. **Memory Management**: Dispose controllers properly

## Security Considerations

1. **Authentication**: Secure Firebase Auth implementation
2. **API Keys**: Never commit keys to repository
3. **Data Validation**: Validate all user inputs
4. **Firestore Rules**: Proper security rules
5. **Storage Rules**: Secure file access

## Future Improvements

- Implement offline-first architecture
- Add caching layer for better performance
- Implement dependency injection container
- Add more comprehensive error handling
- Implement analytics and monitoring
- Add CI/CD pipeline
- Implement automated testing

## References

- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Firebase Best Practices](https://firebase.google.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
