import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'driver_application.dart';
import 'driver_repository.dart';

const _pendingStatus = 'pendiente';

// Without these limits a weak connection keeps the driver on the spinner:
// Storage retries uploads for 10 minutes and Firestore waits for the server.
const _uploadRetryTime = Duration(seconds: 30);
const _submitTimeout = Duration(seconds: 60);

const _connectionError =
    'No se pudo enviar el registro. Revisa tu conexión e inténtalo de nuevo.';

/// Server mode storage. Not validated yet: it needs Ztaxi's own Firebase
/// project and security rules that:
/// - limit Storage `drivers/{uid}` to its owner (and reviewers);
/// - only accept `driver_status: 'pendiente'` from the app, so a driver
///   cannot approve themselves.
///
/// Keeps the legacy field names in `users/{uid}` so existing documents remain
/// readable. License and registration photos are stored as Storage paths, not
/// download links, because a download link bypasses Storage rules.
class FirestoreDriverRepository implements DriverRepository {
  FirestoreDriverRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance {
    _storage.setMaxUploadRetryTime(_uploadRetryTime);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const DriverRegistrationException(
        'Inicia sesión antes de registrarte como conductor.',
      );
    }
    return uid;
  }

  @override
  Future<void> submit(DriverApplication application) async {
    final uid = _requireUid();
    try {
      await _send(uid, application).timeout(_submitTimeout);
    } on TimeoutException catch (error, stackTrace) {
      log(
        'Driver registration timed out',
        error: error,
        stackTrace: stackTrace,
      );
      throw const DriverRegistrationException(_connectionError);
    } on FirebaseException catch (error, stackTrace) {
      log(
        'Driver registration failed: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw const DriverRegistrationException(_connectionError);
    }
  }

  Future<void> _send(String uid, DriverApplication application) async {
    final folder = _storage.ref('drivers/$uid');
    final image = await _upload(folder.child('perfil'), application.photo);
    final license = await _uploadDocument(
      folder.child('licencia'),
      application.licensePhoto,
    );
    final registration = await _uploadDocument(
      folder.child('matricula'),
      application.registrationPhoto,
    );
    final vehicle = application.vehicle;
    await _userDoc(uid).set({
      'name': application.name,
      // Shown to passengers, so it keeps a download link like the legacy code.
      'image': await image.getDownloadURL(),
      'isDriver': true,
      'vehicle_make': vehicle.make,
      'vehicle_model': vehicle.model,
      // The legacy registration stored the year as text.
      'vehicle_year': vehicle.year.toString(),
      'vehicle_number': vehicle.plate,
      'vehicle_color': vehicle.color,
      'cooperative': application.cooperative,
      'unit_number': application.unitNumber,
      // Delete stale paths when a document is not sent again.
      'license_path': license ?? FieldValue.delete(),
      'registration_path': registration ?? FieldValue.delete(),
      'driver_status': _pendingStatus,
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> hasPendingApplication() async {
    final snapshot = await _userDoc(_requireUid()).get();
    return snapshot.data()?['driver_status'] == _pendingStatus;
  }

  /// Returns the Storage path, or null when the driver did not add the photo.
  Future<String?> _uploadDocument(Reference ref, DriverPhoto? photo) async {
    if (photo == null) return null;
    final uploaded = await _upload(ref, photo);
    return uploaded.fullPath;
  }

  Future<Reference> _upload(Reference ref, DriverPhoto photo) async {
    final snapshot = await ref.putData(
      photo.bytes,
      SettableMetadata(contentType: photo.mimeType),
    );
    return snapshot.ref;
  }
}
