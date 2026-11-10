/// A coordinate independent of the map renderer and database SDK.
class GeoCoordinate {
  const GeoCoordinate(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  String get label =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  @override
  bool operator ==(Object other) =>
      other is GeoCoordinate &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

const zamoraCenter = GeoCoordinate(-4.0691, -78.9567);

/// Pilot viewport, not an administrative boundary or a service authorization.
bool isInZamoraPreview(GeoCoordinate point) =>
    point.isValid &&
    point.latitude >= -4.14 &&
    point.latitude <= -4.00 &&
    point.longitude >= -79.02 &&
    point.longitude <= -78.88;
