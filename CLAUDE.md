# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Ztaxi is a passenger/driver taxi app for Zamora, Ecuador, built on a fork of the MIT-licensed Elite Taxi Flutter app (see `IMPORTACION-ZTAXI.md`). Android is the first target and iOS is not yet validated. It is not production-ready. Right now the only working flow is a simulated login followed by a MapLibre map where the user picks pickup and destination points. There are no real trips, routes, drivers, fares, or payments yet.

`MAPAS.md`, `PRODUCT.md` and `DESIGN.md` are the current source of truth. Most of `README.md`, plus `ARCHITECTURE.md`, `SETUP.md` and `CONTRIBUTING.md`, describe the original Elite Taxi project: Google Maps, the `packages/google_api_headers` package (since removed), and `polyline_handler.dart` (since removed). Treat them as historical.

The Dart package name is still `elite_taxi_app`, so imports look like `package:elite_taxi_app/...`. The utilities folder is spelled `lib/utlis/`, not `utils`.

## Commands

```powershell
flutter pub get
flutter run -d chrome                                  # default: isolated demo (phone 0990000000, code 123456)
flutter run -d chrome --dart-define=ZTAXI_DEMO=false   # original Firebase login path
flutter run -d <device-id>                             # Android device/emulator (see `flutter devices`)

flutter test                                           # all tests
flutter test test/trip_selection_test.dart             # one file
flutter test --plain-name "requires distinct points"   # one test by name substring

flutter analyze lib test        # global analyze still reports warnings in legacy modules (payments, driver)
flutter build web --release

dart run build_runner build --delete-conflicting-outputs   # regenerates lib/gen/assets.gen.dart (flutter_gen)
```

Toolchain: Dart SDK `>=3.7`. Android builds need SDK API 36 and JDK 21 (AGP 8.13.2, Gradle 8.13, Kotlin 2.4.10). The iOS minimum is 15 because of Firebase. Running in Chrome only checks the UI through MapLibre GL JS. It says nothing about native performance or compatibility.

## Architecture

### Two entry modes (`lib/main.dart`)

`const demoMode = bool.fromEnvironment('ZTAXI_DEMO', defaultValue: true)` decides which mode the app starts in:

- **Demo (default):** `MapDemoLogin` → `HomeScreen(demoMode: true)`. Firebase is **never initialized** and no SMS is sent. The phone number and code are hard-coded test values. Navigation uses plain `Navigator`.
- **Live (`ZTAXI_DEMO=false`):** initializes Firebase and shows a configuration error if the options still contain `YOUR_` placeholders. It then `Get.put(AuthController())` and calls `decideRoute()`, which reads `users/{uid}` and sends the user to `HomeScreen`, `ProfileSettingScreen`, or `DriverProfileSetup`. This path uses GetX navigation (`Get.to`/`Get.offAll`).

Keep demo code free of Firebase calls. The widget tests pump `MyApp()` with no Firebase setup and rely on that.

### Map layer (`lib/maps/`)

The layers are deliberately separated so the map renderer and the database can each be replaced:

- `GeoCoordinate` is a plain lat/lng value with no SDK dependencies. It also defines `zamoraCenter` and `isInZamoraPreview()`, a rectangular test viewport. That rectangle is not an administrative boundary or an approved service area.
- `TripSelection` is an immutable value object for pickup, destination, and which of the two is active. `choose()` throws `ArgumentError` for invalid or out-of-area points and leaves the previous selection untouched. `isComplete` requires the two points to be different.
- `ZamoraMap` is the **only** place MapLibre types may appear. It loads the `assets/zamora-night.json` style, whose tiles are served by OpenFreeMap. Parents control it through `GlobalKey<ZamoraMapState>` (`recenter()`, `selectCenter()`). Marker updates go through a `_pending` future chain with a `_generation` counter, so quick taps and map retries can't race each other. Keep that pattern when adding layers or markers.
- `map_credits.dart` holds the attribution dialog. The OSM/OpenMapTiles/OpenFreeMap attribution must stay visible (ODbL requirement).

The Zamora bounds appear in two places: `isInZamoraPreview()` and `cameraTargetBounds` in `zamora_map.dart`. Keep them in sync.

### `HomeScreen` is used two ways (`lib/home.dart`)

- As the **trip picker** (default): the user picks pickup and then destination, and a review sheet opens. It does not request a trip.
- As the **single-point picker**, when `pointPickerTitle` is set. `ProfileSettingScreen` pushes it and receives the chosen `GeoCoordinate` from `Navigator.pop`.

### Persistence

User profiles live in the Firestore document `users/{uid}`. Saved places (`home_latlng`, `business_latlng`, `shopping_latlng`) are stored as Firestore `GeoPoint`s. `UserModel._coordinate` converts them to `GeoCoordinate` by duck typing and returns `null` for malformed data. Keep the `GeoPoint` format so existing data needs no migration.

## Constraints and known hazards

- **Map stack:** use native MapLibre through `maplibre_gl` 0.27.1 (exact pin). Don't rewrite the app in React, don't embed mapcn or other web maps in a WebView, and don't bring Google Maps or Directions back.
- **Routes and addresses:** never draw a straight line and present it as a route. Points are shown as coordinates until a geocoding or routing service is added. Don't connect public geocoding or routing APIs before reviewing their terms of use and capacity limits.
- **Payments:** the legacy card code (`AuthController.storeUserCard`, `views/payment.dart`, `add_payment_*`) writes card number and CVV to Firestore. Don't extend it or route users to it. Replace it with a tokenizing payment gateway before enabling payments.
- **Firebase config:** `lib/firebase_options.dart` and `firebase.json` still point at the origin project (`elitetaxi-61f40`). They must be regenerated with `flutterfire configure` against Ztaxi's own project.
- **Android:** release builds currently sign with the debug config, and the application ID is still `com.example.elite_taxi_app`. Neither is acceptable for distribution.
- **Legacy code:** `lib/driver/`, the OTP widgets, and `AppConstant` are inherited English/Arabic code that hasn't been validated yet.

## UI conventions (from `DESIGN.md` / `PRODUCT.md`)

- All user-facing text is in **Spanish** and kept simple.
- The map is dark blue-grey with few labels, no 3D buildings, readable main roads, and muted green for points of interest.
- Color tokens: ground `#414650`, water `#303741`, roads `#525b66`/`#7a858e`, references `#a9cfbc`, surface `#f8faf8`, text `#17251f`, primary action `#214e39`.
- Use the platform font. Don't download a font.
- Controls are at least 48 px. The bottom sheet must scroll on small screens. Map credits stay outside the sheet.
- Design for these states: simulated access, pickup pending, destination pending, identical points, out-of-area point, point review, credits, map load error/timeout, and marker error.
