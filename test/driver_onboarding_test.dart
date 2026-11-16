import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ztaxi/driver/driver_application.dart';
import 'package:ztaxi/driver/driver_onboarding_screen.dart';
import 'package:ztaxi/driver/driver_repository.dart';
import 'package:ztaxi/driver/photo_field.dart';
import 'package:ztaxi/main.dart';

// 1x1 PNG so Image.memory can decode the fake photo.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Future<DriverPhoto?> _fakePicker(PhotoOrigin origin) async =>
    DriverPhoto(bytes: _png, mimeType: 'image/png');

Future<void> _fill(WidgetTester tester, String label, String value) =>
    tester.enterText(find.widgetWithText(TextFormField, label), value);

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo login leads to the passenger or driver choice', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('demo-code')), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Soy pasajero'), findsOneWidget);
    expect(find.text('Soy conductor'), findsOneWidget);
    await tester.tap(find.text('Soy conductor'));
    await tester.pumpAndSettle();
    expect(find.text('Registro de conductor'), findsOneWidget);
  });

  testWidgets('a driver completes registration with only required data', (
    tester,
  ) async {
    final repository = InMemoryDriverRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: DriverOnboardingScreen(
          repository: repository,
          demoMode: true,
          pickPhoto: _fakePicker,
        ),
      ),
    );

    // Step 1 requires the profile photo.
    await _fill(tester, 'Nombre completo', 'Ana Pérez');
    await _tapButton(tester, 'Continuar');
    expect(find.text('Agrega una foto tuya.'), findsOneWidget);
    await tester.tap(find.text('Elegir foto').first);
    await tester.pumpAndSettle();
    await _tapButton(tester, 'Continuar');

    // Step 2 validates the plate.
    expect(find.text('Tu vehículo'), findsOneWidget);
    await _fill(tester, 'Marca', 'Chevrolet');
    await _fill(tester, 'Modelo', 'Aveo');
    await _fill(tester, 'Año', '2018');
    await _fill(tester, 'Placa', 'ZA1234');
    await _fill(tester, 'Color', 'Amarillo');
    await _tapButton(tester, 'Continuar');
    expect(find.textContaining('3 letras'), findsOneWidget);
    await _fill(tester, 'Placa', 'zab1234');
    await _tapButton(tester, 'Continuar');

    // Step 3 is optional.
    expect(find.text('Documentos y cooperativa'), findsOneWidget);
    await _tapButton(tester, 'Revisar');

    expect(find.text('ZAB-1234'), findsOneWidget);
    expect(await repository.hasPendingApplication(), isFalse);
    await _tapButton(tester, 'Enviar registro');

    expect(find.text('Verificación pendiente'), findsOneWidget);
    expect(await repository.hasPendingApplication(), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the registration fits a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DriverOnboardingScreen(
          repository: InMemoryDriverRepository(),
          demoMode: true,
          pickPhoto: _fakePicker,
        ),
      ),
    );
    await tester.tap(find.text('Elegir foto').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
