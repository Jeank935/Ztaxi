import 'dart:async';

import 'package:flutter/material.dart';

import 'package:ztaxi/driver/driver_onboarding_screen.dart';
import 'package:ztaxi/driver/driver_repository.dart';
import 'package:ztaxi/driver/verification_pending_screen.dart';
import 'package:ztaxi/home.dart';
import 'package:ztaxi/trips/trip_repository.dart';

const _mutedText = Color(0xff52615a);

/// Demo: choose between the passenger map and the driver registration.
/// Registrations and trip requests live in memory while this screen is open.
class RoleChoiceScreen extends StatefulWidget {
  const RoleChoiceScreen({super.key});

  @override
  State<RoleChoiceScreen> createState() => _RoleChoiceScreenState();
}

class _RoleChoiceScreenState extends State<RoleChoiceScreen> {
  final _drivers = InMemoryDriverRepository();
  final _trips = InMemoryTripRepository();

  @override
  void dispose() {
    unawaited(_trips.dispose());
    super.dispose();
  }

  void _openPassenger() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => HomeScreen(demoMode: true, tripRepository: _trips),
    ),
  );

  Future<void> _openDriver() async {
    final pending = await _drivers.hasPendingApplication();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (_) =>
                pending
                    ? const VerificationPendingScreen(demoMode: true)
                    : DriverOnboardingScreen(
                      repository: _drivers,
                      demoMode: true,
                    ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ztaxi',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Cómo vas a usar Ztaxi?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _RoleCard(
                  icon: Icons.hail_rounded,
                  title: 'Soy pasajero',
                  subtitle: 'Elige recogida y destino en el mapa.',
                  onTap: _openPassenger,
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.local_taxi_outlined,
                  title: 'Soy conductor',
                  subtitle: 'Registra tus datos y tu vehículo.',
                  onTap: _openDriver,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Modo demo · sin cuentas, viajes ni cobros reales',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _mutedText),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xffedf2ee),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: _mutedText)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
