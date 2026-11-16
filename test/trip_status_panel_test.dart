import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ztaxi/maps/geo_coordinate.dart';
import 'package:ztaxi/trips/trip_request.dart';
import 'package:ztaxi/trips/trip_status_panel.dart';

final _trip = TripRequest(
  id: 'demo-1',
  pickup: zamoraCenter,
  destination: const GeoCoordinate(-4.072, -78.951),
  status: TripStatus.searchingDriver,
  createdAt: DateTime(2026, 11, 15),
);

void main() {
  testWidgets('shows a simulated search with both points and can cancel', (
    tester,
  ) async {
    var cancelled = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripStatusPanel(trip: _trip, onCancel: () => cancelled++),
        ),
      ),
    );

    expect(find.text('Buscando conductor…'), findsOneWidget);
    expect(
      find.textContaining('no hay conductores conectados'),
      findsOneWidget,
    );
    expect(find.text(zamoraCenter.label), findsOneWidget);
    expect(find.text(_trip.destination.label), findsOneWidget);
    // No invented driver, fare or arrival time.
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.textContaining('min'), findsNothing);

    await tester.tap(find.text('Cancelar solicitud'));
    await tester.pump();
    expect(cancelled, 1);
  });

  testWidgets('fits a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TripStatusPanel(trip: _trip, onCancel: () {}),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
