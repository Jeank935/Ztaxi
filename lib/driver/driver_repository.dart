import 'driver_application.dart';

/// Thrown when a registration cannot be sent. The message is shown to the
/// driver.
class DriverRegistrationException implements Exception {
  const DriverRegistrationException(this.message);

  final String message;

  @override
  String toString() => 'DriverRegistrationException: $message';
}

/// Where driver registrations are stored. The demo keeps them in memory;
/// the server mode uses Firestore.
abstract interface class DriverRepository {
  Future<void> submit(DriverApplication application);

  /// Whether this user already sent a registration that awaits verification.
  Future<bool> hasPendingApplication();
}

/// Session-only storage for the demo. Nothing leaves the device.
class InMemoryDriverRepository implements DriverRepository {
  DriverApplication? _submitted;

  @override
  Future<void> submit(DriverApplication application) async {
    _submitted = application;
  }

  @override
  Future<bool> hasPendingApplication() async => _submitted != null;
}
