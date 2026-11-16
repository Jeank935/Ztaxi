import 'dart:async';

import 'package:ztaxi/maps/trip_selection.dart';

import 'trip_request.dart';

/// Thrown when a request cannot be created. The message is shown to the
/// passenger.
class TripRequestException implements Exception {
  const TripRequestException(this.message);

  final String message;

  @override
  String toString() => 'TripRequestException: $message';
}

/// Where taxi requests live. The demo keeps them in memory; a Firestore
/// version will come with Ztaxi's own Firebase project.
abstract interface class TripRepository {
  /// Throws [TripRequestException] if another request is still active.
  Future<TripRequest> request(TripSelection selection);

  /// Does nothing if [id] is not the active request.
  Future<void> cancel(String id);

  /// Emits the current active request (or null) and every later change.
  Stream<TripRequest?> watchActive();
}

/// Session-only requests for the demo. No driver is ever notified.
class InMemoryTripRepository implements TripRepository {
  InMemoryTripRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final _changes = StreamController<TripRequest?>.broadcast();
  TripRequest? _active;
  int _nextId = 1;

  @override
  Future<TripRequest> request(TripSelection selection) async {
    if (_active != null) {
      throw const TripRequestException(
        'Ya tienes una solicitud activa. Cancélala para pedir otra.',
      );
    }
    final trip = TripRequest.fromSelection(
      selection,
      id: 'demo-${_nextId++}',
      createdAt: _clock(),
    );
    _active = trip;
    _changes.add(trip);
    return trip;
  }

  @override
  Future<void> cancel(String id) async {
    if (_active?.id != id) return;
    _active = null;
    _changes.add(null);
  }

  @override
  Stream<TripRequest?> watchActive() {
    // Snapshot and subscription happen together in onListen, so no change
    // can slip in between them.
    StreamSubscription<TripRequest?>? changes;
    late final StreamController<TripRequest?> controller;
    controller = StreamController<TripRequest?>(
      onListen: () {
        controller.add(_active);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  Future<void> dispose() => _changes.close();
}
