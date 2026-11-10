import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller/auth_controller.dart';
import 'firebase_options.dart';
import 'views/login_screen.dart';
import 'views/map_demo_login.dart';

// The preview has its own navigation and never creates a Firebase session.
const demoMode = bool.fromEnvironment('ZTAXI_DEMO', defaultValue: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Elite Taxi · base de Ztaxi',
    ], await rootBundle.loadString('LICENSE'));
  });
  String? configurationError;
  if (!demoMode) {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.startsWith('YOUR_')) {
        throw StateError('Configura primero tu proyecto propio de Firebase.');
      }
      await Firebase.initializeApp(options: options);
    } catch (_) {
      configurationError =
          'Falta configurar Firebase para usar el acceso real. '
          'La prueba del mapa está disponible con ZTAXI_DEMO=true.';
    }
  }
  runApp(MyApp(configurationError: configurationError));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.configurationError});
  final String? configurationError;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Ztaxi',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff8faf8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff214e39),
      ).copyWith(
        primary: const Color(0xff214e39),
        onPrimary: Colors.white,
        surface: const Color(0xfff8faf8),
        onSurface: const Color(0xff17251f),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xffedf2ee),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    home:
        configurationError != null
            ? Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(configurationError!),
                  ),
                ),
              ),
            )
            : demoMode
            ? const MapDemoLogin()
            : const _LiveEntry(),
  );
}

class _LiveEntry extends StatefulWidget {
  const _LiveEntry();
  @override
  State<_LiveEntry> createState() => _LiveEntryState();
}

class _LiveEntryState extends State<_LiveEntry> {
  @override
  void initState() {
    super.initState();
    final auth = Get.put(AuthController());
    WidgetsBinding.instance.addPostFrameCallback((_) => auth.decideRoute());
  }

  @override
  Widget build(BuildContext context) => LoginScreen();
}
