import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showMapCredits(BuildContext context) => showDialog<void>(
  context: context,
  builder:
      (context) => AlertDialog(
        title: const Text('Mapas y licencias'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MapLibre muestra el mapa. OpenFreeMap sirve los datos de '
                'OpenStreetMap con el esquema de OpenMapTiles.',
              ),
              for (final entry
                  in const {
                    '© OpenStreetMap contributors':
                        'https://www.openstreetmap.org/copyright',
                    '© OpenMapTiles': 'https://openmaptiles.org/',
                    'OpenFreeMap': 'https://openfreemap.org/',
                    'MapLibre · licencia BSD':
                        'https://pub.dev/packages/maplibre_gl/versions/0.27.1/license',
                  }.entries)
                TextButton(
                  onPressed: () async {
                    final opened = await launchUrl(Uri.parse(entry.value));
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Puedes visitar ${entry.value}'),
                        ),
                      );
                    }
                  },
                  child: Text(entry.key),
                ),
              TextButton(
                onPressed:
                    () => showLicensePage(
                      context: context,
                      applicationName: 'Ztaxi',
                    ),
                child: const Text('Licencias de la aplicación'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
);
