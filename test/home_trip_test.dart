import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ztaxi/home.dart';
import 'package:ztaxi/maps/geo_coordinate.dart';
import 'package:ztaxi/maps/trip_selection.dart';
import 'package:ztaxi/maps/zamora_map.dart';
import 'package:ztaxi/trips/trip_repository.dart';

const _destination = GeoCoordinate(-4.072, -78.951);
const _otherPoint = GeoCoordinate(-4.08, -78.96);

/// MapLibre is a native view. Failing the style load keeps [ZamoraMap] in its
/// error state so the rest of the screen can be tested. The bundle cache is
/// cleared because a cached future from an earlier test never completes in
/// the next test's fake-async zone.
void _failMapStyle(WidgetTester tester) {
  final messenger = tester.binding.defaultBinaryMessenger;
  rootBundle.clear();
  messenger.setMockMessageHandler('flutter/assets', (_) async => null);
  addTearDown(() {
    messenger.setMockMessageHandler('flutter/assets', null);
    rootBundle.clear();
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  TripRepository? repository,
}) async {
  _failMapStyle(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: HomeScreen(
        demoMode: repository != null,
        tripRepository: repository,
      ),
    ),
  );
}

void _tapMap(WidgetTester tester, GeoCoordinate point) =>
    tester.widget<ZamoraMap>(find.byType(ZamoraMap)).onSelect(point);

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
}

Future<void> _openReview(WidgetTester tester) async {
  await tester.pumpAndSettle();
  _tapMap(tester, zamoraCenter);
  await tester.pump();
  await _tap(tester, 'Confirmar recogida');
  await tester.pump();
  _tapMap(tester, _destination);
  await tester.pump();
  await _tap(tester, 'Revisar puntos');
  await tester.pumpAndSettle();
}

// The search spinner never settles, so advance time explicitly.
Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets(
    'requesting shows the panel, locks the map and cancelling keeps points',
    (tester) async {
      final repository = InMemoryTripRepository();
      addTearDown(repository.dispose);
      await _pumpHome(tester, repository: repository);
      expect(
        find.text('Modo demo · viajes simulados, sin cobros'),
        findsOneWidget,
      );

      await _openReview(tester);
      await tester.tap(find.text('Solicitar taxi (simulado)'));
      await _pumpFrames(tester);
      expect(find.text('Buscando conductor…'), findsOneWidget);

      _tapMap(tester, _otherPoint);
      await _pumpFrames(tester);
      expect(find.text(_otherPoint.label), findsNothing);

      await _tap(tester, 'Cancelar solicitud');
      await _pumpFrames(tester);
      expect(find.text('Buscando conductor…'), findsNothing);
      expect(find.text(zamoraCenter.label), findsOneWidget);
      expect(find.text(_destination.label), findsOneWidget);
    },
  );

  testWidgets('returning with an active request restores its points', (
    tester,
  ) async {
    final repository = InMemoryTripRepository();
    addTearDown(repository.dispose);
    await repository.request(
      const TripSelection(pickup: zamoraCenter, destination: _destination),
    );

    await _pumpHome(tester, repository: repository);
    await _pumpFrames(tester);
    expect(find.text('Buscando conductor…'), findsOneWidget);

    await _tap(tester, 'Cancelar solicitud');
    await _pumpFrames(tester);
    expect(find.text(zamoraCenter.label), findsOneWidget);
    expect(find.text(_destination.label), findsOneWidget);
  });

  testWidgets('the request panel opens at the top on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = InMemoryTripRepository();
    addTearDown(repository.dispose);
    await _pumpHome(tester, repository: repository);

    await _openReview(tester);
    await _tap(tester, 'Solicitar taxi (simulado)');
    await _pumpFrames(tester);

    expect(find.text('Buscando conductor…').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without a repository the screen only previews the points', (
    tester,
  ) async {
    await _pumpHome(tester);
    expect(
      find.text('Vista previa del mapa · sin solicitud de viaje'),
      findsOneWidget,
    );

    await _openReview(tester);
    expect(find.textContaining('No se ha solicitado un viaje'), findsOneWidget);
    expect(find.text('Solicitar taxi (simulado)'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Seguir editando'),
      findsOneWidget,
    );
  });
}
