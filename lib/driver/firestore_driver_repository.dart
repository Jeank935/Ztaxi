import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'driver_application.dart';
import 'driver_repository.dart';

const _pendingStatus = 'pendiente';

/// Server mode storage. Not validated yet: it needs Ztaxi's own Firebase
/// project and Storage rules that limit `drivers/{uid}` to its owner.
///
/// Keeps the legacy field names in `users/{uid}` so existing documents remain
/// readable.
class FirestoreDriverRepository implements DriverRepository {
  FirestoreDriverRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

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
      final folder = _storage.ref('drivers/$uid');
      final image = await _upload(folder.child('perfil'), application.photo);
      final license = await _uploadOptional(
        folder.child('licencia'),
        application.licensePhoto,
      );
      final registration = await _uploadOptional(
        folder.child('matricula'),
        application.registrationPhoto,
      );
      final vehicle = application.vehicle;
      await _userDoc(uid).set({
        'name': application.name,
        'image': image,
        'isDriver': true,
        'vehicle_make': vehicle.make,
        'vehicle_model': vehicle.model,
        // The legacy registration stored the year as text.
        'vehicle_year': vehicle.year.toString(),
        'vehicle_number': vehicle.plate,
        'vehicle_color': vehicle.color,
        'cooperative': application.cooperative,
        'unit_number': application.unitNumber,
        if (license != null) 'license_url': license,
        if (registration != null) 'registration_url': registration,
        'driver_status': _pendingStatus,
      }, SetOptions(merge: true));
    } on FirebaseException catch (error, stackTrace) {
      log(
        'Driver registration failed: ${error.code}',
        error: error,
        stackTrace: stackTrace,
      );
      throw const DriverRegistrationException(
        'No se pudo enviar el registro. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<bool> hasPendingApplication() async {
    final snapshot = await _userDoc(_requireUid()).get();
    return snapshot.data()?['driver_status'] == _pendingStatus;
  }

  Future<String?> _uploadOptional(Reference ref, DriverPhoto? photo) async =>
      photo == null ? null : _upload(ref, photo);

  Future<String> _upload(Reference ref, DriverPhoto photo) async {
    final snapshot = await ref.putData(
      photo.bytes,
      SettableMetadata(contentType: photo.mimeType),
    );
    return snapshot.ref.getDownloadURL();
  }
}
