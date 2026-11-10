import 'package:flutter/material.dart';

import '../home.dart';

/// Isolated local preview. It never signs into Firebase or sends an SMS.
class MapDemoLogin extends StatefulWidget {
  const MapDemoLogin({super.key});

  @override
  State<MapDemoLogin> createState() => _MapDemoLoginState();
}

class _MapDemoLoginState extends State<MapDemoLogin> {
  final _phone = TextEditingController(text: '0990000000');
  final _code = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _verifying = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_form.currentState!.validate()) return;
    if (!_verifying) {
      setState(() => _verifying = true);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(demoMode: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ztaxi',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text('Muévete por Zamora.'),
                  const SizedBox(height: 48),
                  Text(
                    _verifying
                        ? 'Un paso más y listo.'
                        : 'Tu viaje empieza aquí.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_verifying)
                    TextFormField(
                      key: const ValueKey('demo-code'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Código de prueba',
                        helperText: 'Código demo: 123456. No se envía un SMS.',
                      ),
                      validator:
                          (value) =>
                              value == '123456'
                                  ? null
                                  : 'Escribe el código de prueba 123456.',
                      onFieldSubmitted: (_) => _continue(),
                    )
                  else
                    TextFormField(
                      key: const ValueKey('demo-phone'),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de prueba',
                        helperText:
                            'Usa 0990000000. No necesitas tu número real.',
                      ),
                      validator:
                          (value) =>
                              value?.trim() == '0990000000'
                                  ? null
                                  : 'Usa el teléfono de prueba 0990000000.',
                      onFieldSubmitted: (_) => _continue(),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _continue,
                    child: Text(_verifying ? 'Entrar al mapa' : 'Continuar'),
                  ),
                  if (_verifying)
                    TextButton(
                      onPressed:
                          () => setState(() {
                            _verifying = false;
                            _code.clear();
                            _form.currentState?.reset();
                          }),
                      child: const Text('Cambiar teléfono'),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Acceso simulado para probar el mapa.\nSin cuenta, viajes ni cobros reales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff52615a)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
