import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ztaxi/driver/driver_application.dart';
import 'package:ztaxi/driver/driver_repository.dart';

final _photo = DriverPhoto(bytes: Uint8List.fromList([1, 2, 3]));

DriverApplication _application({
  String name = 'Ana Pérez',
  String year = '2018',
  String plate = 'zab1234',
  DriverPhoto? licensePhoto,
  String cooperative = '',
}) => DriverApplication.create(
  name: name,
  photo: _photo,
  make: 'Chevrolet',
  model: 'Aveo',
  year: year,
  plate: plate,
  color: 'Amarillo',
  licensePhoto: licensePhoto,
  cooperative: cooperative,
  currentYear: 2026,
);

void main() {
  group('normalizePlate', () {
    test('accepts Ecuadorian plates and stores them as ABC-1234', () {
      expect(normalizePlate('zab1234'), 'ZAB-1234');
      expect(normalizePlate(' ZAB-123 '), 'ZAB-123');
      expect(normalizePlate('zab 1234'), 'ZAB-1234');
    });

    test('rejects plates that do not have 3 letters and 3 or 4 digits', () {
      for (final plate in [
        '',
        'ZA-1234',
        'ZABC-1234',
        'ZAB-12',
        'ZAB-12345',
        '123-ZAB',
      ]) {
        expect(normalizePlate(plate), isNull, reason: plate);
      }
    });
  });

  group('DriverValidators', () {
    test('requires a name', () {
      expect(DriverValidators.name('  '), isNotNull);
      expect(DriverValidators.name('Ana'), isNull);
    });

    test('accepts years from 1980 to next year only', () {
      expect(DriverValidators.year('1979', currentYear: 2026), isNotNull);
      expect(DriverValidators.year('1980', currentYear: 2026), isNull);
      expect(DriverValidators.year('2027', currentYear: 2026), isNull);
      expect(DriverValidators.year('2028', currentYear: 2026), isNotNull);
      expect(DriverValidators.year('20a8', currentYear: 2026), isNotNull);
    });
  });

  group('DriverApplication.create', () {
    test('normalizes the plate and allows empty optional fields', () {
      final application = _application();
      expect(application.vehicle.plate, 'ZAB-1234');
      expect(application.vehicle.year, 2018);
      expect(application.licensePhoto, isNull);
      expect(application.registrationPhoto, isNull);
      expect(application.cooperative, isEmpty);
      expect(application.unitNumber, isEmpty);
    });

    test('trims optional text and keeps optional photos', () {
      final application = _application(
        cooperative: '  Cooperativa Zamora  ',
        licensePhoto: _photo,
      );
      expect(application.cooperative, 'Cooperativa Zamora');
      expect(application.licensePhoto, same(_photo));
    });

    test('rejects invalid required data', () {
      expect(() => _application(name: ''), throwsArgumentError);
      expect(() => _application(year: '1950'), throwsArgumentError);
      expect(() => _application(plate: 'ZAB'), throwsArgumentError);
    });
  });

  test('the in-memory repository remembers a submitted application', () async {
    final repository = InMemoryDriverRepository();
    expect(await repository.hasPendingApplication(), isFalse);
    await repository.submit(_application());
    expect(await repository.hasPendingApplication(), isTrue);
  });
}
