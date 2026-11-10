import 'package:elite_taxi_app/maps/geo_coordinate.dart';
import 'package:elite_taxi_app/maps/trip_selection.dart';
import 'package:elite_taxi_app/models/user_model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'editing a pickup preserves the destination and requires distinct points',
    () {
      final pickup = const TripSelection().choose(zamoraCenter);
      expect(pickup.isComplete, isFalse);
      final trip = pickup
          .selecting(SelectionTarget.destination)
          .choose(const GeoCoordinate(-4.072, -78.951));
      expect(trip.isComplete, isTrue);
      final changed = trip
          .selecting(SelectionTarget.pickup)
          .choose(const GeoCoordinate(-4.065, -78.957));
      expect(changed.destination, trip.destination);
      expect(changed.pickup, isNot(trip.pickup));
      expect(
        changed
            .selecting(SelectionTarget.pickup)
            .choose(changed.destination!)
            .isComplete,
        isFalse,
      );
    },
  );

  test(
    'invalid and out-of-area selections leave the previous selection intact',
    () {
      final trip = const TripSelection().choose(zamoraCenter);
      for (final point in [
        const GeoCoordinate(double.nan, -78.95),
        const GeoCoordinate(-4.07, double.infinity),
        const GeoCoordinate(91, 0),
        const GeoCoordinate(0, 0),
      ]) {
        expect(() => trip.choose(point), throwsArgumentError);
        expect(trip.pickup, zamoraCenter);
      }
    },
  );

  test('existing Firestore GeoPoints remain readable without a map SDK', () {
    final user = UserModel.fromJson({
      'name': 'Prueba',
      'home_latlng': const GeoPoint(-4.0691, -78.9567),
    });
    expect(user.homeAddress, zamoraCenter);
    expect(user.businessAddress, isNull);
    expect(user.shoppingAddress, isNull);
  });

  test('incomplete or malformed saved locations do not crash the profile', () {
    final user = UserModel.fromJson({'home_latlng': 'invalid'});
    expect(user.homeAddress, isNull);
  });
}
