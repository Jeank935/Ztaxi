import 'package:flutter/material.dart';

import 'trip_request.dart';

const _mutedText = Color(0xff52615a);

/// Bottom tray content while a request is active. It never invents a driver,
/// fare or arrival time.
class TripStatusPanel extends StatelessWidget {
  const TripStatusPanel({
    super.key,
    required this.trip,
    required this.onCancel,
  });

  final TripRequest trip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Buscando conductor…',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      const Text(
        'Solicitud simulada. En la demo no hay conductores conectados.',
        style: TextStyle(color: _mutedText),
      ),
      const SizedBox(height: 14),
      _point(Icons.trip_origin, 'Recogida', trip.pickup.label),
      _point(Icons.location_on_outlined, 'Destino', trip.destination.label),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
        child: const Text('Cancelar solicitud'),
      ),
    ],
  );

  Widget _point(IconData icon, String title, String label) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, size: 23),
    title: Text(title, style: const TextStyle(fontSize: 13)),
    subtitle: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}
