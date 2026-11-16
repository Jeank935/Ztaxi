import 'package:ztaxi/maps/geo_coordinate.dart';
import 'package:ztaxi/maps/trip_selection.dart';

enum TripStatus { searchingDriver, cancelled }

/// A passenger's taxi request. Independent of the map renderer and Firebase.
class TripRequest {
  const TripRequest({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.status,
    required this.createdAt,
  });

  /// Throws [ArgumentError] unless the selection has two different points.
  factory TripRequest.fromSelection(
    TripSelection selection, {
    required String id,
    required DateTime createdAt,
  }) {
    final pickup = selection.pickup;
    final destination = selection.destination;
    if (!selection.isComplete || pickup == null || destination == null) {
      throw ArgumentError('Elige una recogida y un destino diferentes.');
    }
    return TripRequest(
      id: id,
      pickup: pickup,
      destination: destination,
      status: TripStatus.searchingDriver,
      createdAt: createdAt,
    );
  }

  final String id;
  final GeoCoordinate pickup;
  final GeoCoordinate destination;
  final TripStatus status;
  final DateTime createdAt;

  bool get isActive => status == TripStatus.searchingDriver;
}
