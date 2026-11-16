import 'dart:typed_data';

/// Oldest vehicle year accepted by the form. A sanity check, not a
/// transit regulation.
const minVehicleYear = 1980;

final _platePattern = RegExp(r'^([A-Z]{3})[- ]?(\d{3,4})$');

/// Returns an Ecuadorian plate as `ABC-1234`, or null when the input does not
/// have three letters followed by three or four digits.
String? normalizePlate(String input) {
  final match = _platePattern.firstMatch(input.trim().toUpperCase());
  if (match == null) return null;
  return '${match.group(1)}-${match.group(2)}';
}

/// Form validators shared by the registration screen and
/// [DriverApplication.create]. Each returns a Spanish message or null.
abstract final class DriverValidators {
  static String? name(String? value) =>
      (value ?? '').trim().isEmpty ? 'Escribe tu nombre.' : null;

  static String? requiredText(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  static String? plate(String? value) =>
      normalizePlate(value ?? '') == null
          ? 'Usa 3 letras y 3 o 4 números, por ejemplo ZAB-1234.'
          : null;

  static String? year(String? value, {int? currentYear}) {
    final maxYear = (currentYear ?? DateTime.now().year) + 1;
    final year = int.tryParse((value ?? '').trim());
    if (year == null || year < minVehicleYear || year > maxYear) {
      return 'Escribe un año entre $minVehicleYear y $maxYear.';
    }
    return null;
  }
}

/// A photo chosen by the driver, kept as bytes so it works on web and mobile.
class DriverPhoto {
  const DriverPhoto({required this.bytes, this.mimeType = 'image/jpeg'});

  final Uint8List bytes;
  final String mimeType;
}

class Vehicle {
  const Vehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
  });

  final String make;
  final String model;
  final int year;

  /// Normalized as `ABC-1234`.
  final String plate;
  final String color;
}

/// What a driver submits for verification. Independent of Firebase and UI.
class DriverApplication {
  const DriverApplication._({
    required this.name,
    required this.photo,
    required this.vehicle,
    required this.licensePhoto,
    required this.registrationPhoto,
    required this.cooperative,
    required this.unitNumber,
  });

  /// Validates the input and throws [ArgumentError] with a Spanish message
  /// when a required field is invalid. Optional fields may be empty.
  factory DriverApplication.create({
    required String name,
    required DriverPhoto photo,
    required String make,
    required String model,
    required String year,
    required String plate,
    required String color,
    DriverPhoto? licensePhoto,
    DriverPhoto? registrationPhoto,
    String cooperative = '',
    String unitNumber = '',
    int? currentYear,
  }) {
    final error =
        [
          DriverValidators.name(name),
          DriverValidators.requiredText(make, 'Escribe la marca.'),
          DriverValidators.requiredText(model, 'Escribe el modelo.'),
          DriverValidators.year(year, currentYear: currentYear),
          DriverValidators.plate(plate),
          DriverValidators.requiredText(color, 'Escribe el color.'),
        ].nonNulls.firstOrNull;
    if (error != null) throw ArgumentError(error);
    return DriverApplication._(
      name: name.trim(),
      photo: photo,
      vehicle: Vehicle(
        make: make.trim(),
        model: model.trim(),
        year: int.parse(year.trim()),
        plate: normalizePlate(plate) ?? plate,
        color: color.trim(),
      ),
      licensePhoto: licensePhoto,
      registrationPhoto: registrationPhoto,
      cooperative: cooperative.trim(),
      unitNumber: unitNumber.trim(),
    );
  }

  final String name;
  final DriverPhoto photo;
  final Vehicle vehicle;
  final DriverPhoto? licensePhoto;
  final DriverPhoto? registrationPhoto;
  final String cooperative;
  final String unitNumber;
}
