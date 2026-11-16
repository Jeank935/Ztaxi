import 'package:flutter_test/flutter_test.dart';
import 'package:ztaxi/maps/geo_coordinate.dart';
import 'package:ztaxi/maps/trip_selection.dart';
import 'package:ztaxi/trips/trip_repository.dart';
import 'package:ztaxi/trips/trip_request.dart';

const _destination = GeoCoordinate(-4.072, -78.951);
final _createdAt = DateTime(2026, 11, 15, 10);

TripSelection _complete() => const TripSelection()
    .choose(zamoraCenter)
    .selecting(SelectionTarget.destination)
    .choose(_destination);

void main() {
  group('TripRequest.fromSelection', () {
    test('starts searching for a driver with the chosen points', () {
      final trip = TripRequest.fromSelection(
        _complete(),
        id: 'a',
        createdAt: _createdAt,
      );
      expect(trip.pickup, zamoraCenter);
      expect(trip.destination, _destination);
      expect(trip.status, TripStatus.searchingDriver);
      expect(trip.isActive, isTrue);
    });

    test('rejects incomplete selections and identical points', () {
      for (final selection in [
        const TripSelection(),
        const TripSelection().choose(zamoraCenter),
        const TripSelection(pickup: zamoraCenter, destination: zamoraCenter),
      ]) {
        expect(
          () => TripRequest.fromSelection(
            selection,
            id: 'a',
            createdAt: _createdAt,
          ),
          throwsArgumentError,
        );
      }
    });
  });

  group('InMemoryTripRepository', () {
    late InMemoryTripRepository repository;

    setUp(() => repository = InMemoryTripRepository(clock: () => _createdAt));
    tearDown(() => repository.dispose());

    test('publishes the active request and clears it on cancel', () async {
      final updates = <TripRequest?>[];
      final subscription = repository.watchActive().listen(updates.add);

      final trip = await repository.request(_complete());
      await repository.cancel(trip.id);
      await pumpEventQueue();

      expect(updates, [null, trip, null]);
      expect(trip.createdAt, _createdAt);
      await subscription.cancel();
    });

    test('allows only one active request at a time', () async {
      final first = await repository.request(_complete());
      await expectLater(
        repository.request(_complete()),
        throwsA(isA<TripRequestException>()),
      );
      await repository.cancel(first.id);
      final second = await repository.request(_complete());
      expect(second.id, isNot(first.id));
    });

    test('ignores cancelling a request that is not active', () async {
      final trip = await repository.request(_complete());
      await repository.cancel('otra');
      final latest = await repository.watchActive().first;
      expect(latest, same(trip));
    });
  });
}
