import 'package:elite_taxi_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('preview keeps phone access before showing the map', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Teléfono de prueba'), findsOneWidget);
    expect(find.text('Modo demo · sin viajes ni cobros'), findsNothing);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Código de prueba'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('demo-code')), '000000');
    await tester.tap(find.text('Entrar al mapa'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe el código de prueba 123456.'), findsOneWidget);
    expect(find.text('Modo demo · sin viajes ni cobros'), findsNothing);
  });

  testWidgets(
    'preview rejects personal phone numbers and fits a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.enterText(
        find.byKey(const ValueKey('demo-phone')),
        '0991234567',
      );
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Usa el teléfono de prueba 0990000000.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
