import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'geo_coordinate.dart';

/// The renderer adapter. MapLibre types stay inside this widget.
class ZamoraMap extends StatefulWidget {
  const ZamoraMap({
    super.key,
    this.pickup,
    this.destination,
    required this.onSelect,
  });

  final GeoCoordinate? pickup;
  final GeoCoordinate? destination;
  final ValueChanged<GeoCoordinate> onSelect;

  @override
  State<ZamoraMap> createState() => ZamoraMapState();
}

class ZamoraMapState extends State<ZamoraMap> {
  late Future<String> _style = rootBundle.loadString(
    'assets/zamora-night.json',
  );
  MapLibreMapController? _controller;
  final List<Circle> _markers = [];
  Future<void> _pending = Future.value();
  bool _ready = false;
  bool _disposed = false;
  String? _markerError;
  Timer? _loadTimer;
  bool _loadTimedOut = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _watchLoad();
  }

  void _watchLoad() {
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_ready) setState(() => _loadTimedOut = true);
    });
  }

  void _retry() {
    setState(() {
      _generation++;
      _ready = false;
      _controller = null;
      _loadTimedOut = false;
      _markerError = null;
      _markers.clear();
      _style = rootBundle.loadString('assets/zamora-night.json');
    });
    _watchLoad();
  }

  @override
  void didUpdateWidget(covariant ZamoraMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickup != widget.pickup ||
        oldWidget.destination != widget.destination) {
      _scheduleMarkers();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadTimer?.cancel();
    super.dispose();
  }

  void selectCenter() {
    final center = _controller?.cameraPosition?.target;
    if (!_ready || center == null) return;
    widget.onSelect(GeoCoordinate(center.latitude, center.longitude));
  }

  void recenter() {
    if (!_ready) return;
    unawaited(
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(zamoraCenter.latitude, zamoraCenter.longitude),
          14.5,
        ),
      ),
    );
  }

  void _scheduleMarkers() {
    _pending = _pending.then((_) async {
      final generation = _generation;
      final controller = _controller;
      if (_disposed || !_ready || controller == null) return;
      try {
        if (_markers.isNotEmpty) {
          await controller.removeCircles(List.of(_markers));
          if (_disposed || generation != _generation) return;
          _markers.clear();
        }
        for (final entry in [
          (widget.pickup, '#a9dfbf'),
          (widget.destination, '#ffffff'),
        ]) {
          if (_disposed || !_ready) return;
          final point = entry.$1;
          if (point == null) continue;
          final marker = await controller.addCircle(
            CircleOptions(
              geometry: LatLng(point.latitude, point.longitude),
              circleColor: entry.$2,
              circleRadius: 8,
              circleStrokeColor: '#17251f',
              circleStrokeWidth: 3,
            ),
          );
          if (_disposed || generation != _generation) return;
          _markers.add(marker);
        }
        if (mounted && _markerError != null) {
          setState(() => _markerError = null);
        }
      } catch (_) {
        if (mounted && generation == _generation) {
          setState(
            () =>
                _markerError =
                    'No se pudo actualizar el punto. Vuelve a tocar el mapa.',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _style,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudo abrir el mapa.'),
              TextButton(onPressed: _retry, child: const Text('Reintentar')),
            ],
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        children: [
          MapLibreMap(
            key: ValueKey(_generation),
            styleString: snapshot.data!,
            initialCameraPosition: CameraPosition(
              target: LatLng(zamoraCenter.latitude, zamoraCenter.longitude),
              zoom: 14.5,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(11, 19),
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: const LatLng(-4.14, -79.02),
                northeast: const LatLng(-4.00, -78.88),
              ),
            ),
            trackCameraPosition: true,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            compassEnabled: false,
            // The map viewport ends before the sheet: its attribution remains
            // accessible. Full notices are also available from the app menu.
            attributionButtonPosition: AttributionButtonPosition.bottomRight,
            onMapCreated: (controller) => _controller = controller,
            onStyleLoadedCallback: () {
              if (!mounted) return;
              _loadTimer?.cancel();
              _markers.clear();
              setState(() {
                _ready = true;
                _loadTimedOut = false;
              });
              _scheduleMarkers();
            },
            onMapClick:
                (_, point) => widget.onSelect(
                  GeoCoordinate(point.latitude, point.longitude),
                ),
            onMapLongClick:
                (_, point) => widget.onSelect(
                  GeoCoordinate(point.latitude, point.longitude),
                ),
          ),
          if (!_ready)
            Positioned(
              bottom: 48,
              left: 16,
              right: 16,
              child: Material(
                color: const Color(0xfff8faf8),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child:
                      _loadTimedOut
                          ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'El mapa tarda en cargar. Comprueba tu conexión.',
                              ),
                              TextButton(
                                onPressed: _retry,
                                child: const Text('Reintentar mapa'),
                              ),
                            ],
                          )
                          : const Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Cargando mapa de Zamora…'),
                            ],
                          ),
                ),
              ),
            ),
          if (_markerError != null)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_markerError!),
                ),
              ),
            ),
        ],
      );
    },
  );
}
