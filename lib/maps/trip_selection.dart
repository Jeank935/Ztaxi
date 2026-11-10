import 'geo_coordinate.dart';

enum SelectionTarget { pickup, destination }

class TripSelection {
  const TripSelection({
    this.pickup,
    this.destination,
    this.target = SelectionTarget.pickup,
  });

  final GeoCoordinate? pickup;
  final GeoCoordinate? destination;
  final SelectionTarget target;

  bool get isComplete =>
      pickup != null && destination != null && pickup != destination;

  TripSelection selecting(SelectionTarget value) =>
      TripSelection(pickup: pickup, destination: destination, target: value);

  TripSelection choose(GeoCoordinate point) {
    if (!isInZamoraPreview(point)) {
      throw ArgumentError('Elige un punto en el área de prueba de Zamora.');
    }
    return TripSelection(
      pickup: target == SelectionTarget.pickup ? point : pickup,
      destination: target == SelectionTarget.destination ? point : destination,
      target: target,
    );
  }
}
