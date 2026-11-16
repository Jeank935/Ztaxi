import 'package:flutter/material.dart';

/// Shown after a driver submits the registration.
class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key, this.demoMode = false});

  final bool demoMode;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu registro')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verificación pendiente',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Recibimos tus datos. Quedan pendientes de verificación y '
                  'todavía no puedes recibir viajes.',
                  textAlign: TextAlign.center,
                ),
                if (demoMode) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Modo demo: el registro se guardó solo en este dispositivo '
                    'mientras la app está abierta. Nadie lo revisará.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff52615a)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
