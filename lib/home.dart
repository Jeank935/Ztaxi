import 'package:flutter/material.dart';

import 'maps/geo_coordinate.dart';
import 'maps/map_credits.dart';
import 'maps/trip_selection.dart';
import 'maps/zamora_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.demoMode = false,
    this.pointPickerTitle,
    this.initialPoint,
    this.onOpenProfile,
  });

  final bool demoMode;
  final String? pointPickerTitle;
  final GeoCoordinate? initialPoint;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapKey = GlobalKey<ZamoraMapState>();
  late TripSelection _selection = TripSelection(pickup: widget.initialPoint);
  bool get _pickingOne => widget.pointPickerTitle != null;

  void _choose(GeoCoordinate point) {
    try {
      setState(() => _selection = _selection.choose(point));
    } on ArgumentError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige un punto dentro del área de prueba de Zamora.'),
        ),
      );
    }
  }

  void _continue() {
    if (_pickingOne) {
      Navigator.pop(context, _selection.pickup);
    } else if (_selection.target == SelectionTarget.pickup) {
      setState(
        () => _selection = _selection.selecting(SelectionTarget.destination),
      );
    } else if (_selection.isComplete) {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder:
            (context) => SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus puntos en Zamora',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Text('Recogida\n${_selection.pickup!.label}'),
                    const SizedBox(height: 20),
                    Text('Destino\n${_selection.destination!.label}'),
                    const SizedBox(height: 24),
                    const Text(
                      'La ruta por calles y la solicitud de taxi aún están pendientes de conectar. No se ha solicitado un viaje.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Seguir editando'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickingPickup = _selection.target == SelectionTarget.pickup;
    final hasActivePoint =
        pickingPickup
            ? _selection.pickup != null
            : _selection.destination != null;
    final canContinue =
        hasActivePoint && (pickingPickup || _selection.isComplete);
    return Scaffold(
      backgroundColor: const Color(0xff414650),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ZamoraMap(
                    key: _mapKey,
                    pickup: _selection.pickup,
                    destination: _selection.destination,
                    onSelect: _choose,
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_pickingOne) ...[
                          IconButton.filledTonal(
                            tooltip: 'Volver',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ztaxi',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Zamora, Ecuador',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xffe1e7e4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Volver al centro de Zamora',
                          onPressed: () => _mapKey.currentState?.recenter(),
                          icon: const Icon(Icons.center_focus_strong),
                        ),
                        if (!_pickingOne)
                          PopupMenuButton<String>(
                            tooltip: 'Menú de Ztaxi',
                            color: const Color(0xfff8faf8),
                            iconColor: Colors.white,
                            onSelected: (value) {
                              if (value == 'profile') {
                                widget.onOpenProfile?.call();
                              }
                              if (value == 'credits') showMapCredits(context);
                              if (value == 'exit') Navigator.pop(context);
                            },
                            itemBuilder:
                                (_) => [
                                  if (widget.onOpenProfile != null)
                                    const PopupMenuItem(
                                      value: 'profile',
                                      child: Text('Tu perfil'),
                                    ),
                                  const PopupMenuItem(
                                    value: 'credits',
                                    child: Text('Mapas y licencias'),
                                  ),
                                  if (widget.demoMode)
                                    const PopupMenuItem(
                                      value: 'exit',
                                      child: Text('Salir de la demo'),
                                    ),
                                ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xfff8faf8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.60,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.pointPickerTitle ??
                            (pickingPickup
                                ? '¿Dónde te recogemos?'
                                : '¿A dónde vamos?'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toca un punto en el mapa.',
                        style: TextStyle(color: Color(0xff52615a)),
                      ),
                      const SizedBox(height: 14),
                      _pointRow(
                        'Recogida',
                        _selection.pickup,
                        SelectionTarget.pickup,
                        Icons.trip_origin,
                      ),
                      if (!_pickingOne) ...[
                        const SizedBox(height: 4),
                        _pointRow(
                          'Destino',
                          _selection.destination,
                          SelectionTarget.destination,
                          Icons.location_on_outlined,
                        ),
                      ],
                      TextButton.icon(
                        onPressed: () => _mapKey.currentState?.selectCenter(),
                        icon: const Icon(
                          Icons.add_location_alt_outlined,
                          size: 18,
                        ),
                        label: const Text('Usar el centro del mapa'),
                      ),
                      if (_selection.pickup != null &&
                          _selection.pickup == _selection.destination)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'El destino debe ser diferente de la recogida.',
                            style: TextStyle(color: Color(0xffa02a24)),
                          ),
                        ),
                      FilledButton(
                        onPressed: canContinue ? _continue : null,
                        child: Text(
                          _pickingOne
                              ? 'Guardar ubicación'
                              : pickingPickup
                              ? 'Confirmar recogida'
                              : 'Revisar puntos',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.demoMode
                            ? 'Modo demo · sin viajes ni cobros'
                            : 'Vista previa del mapa · sin solicitud de viaje',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff52615a),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointRow(
    String title,
    GeoCoordinate? point,
    SelectionTarget target,
    IconData icon,
  ) {
    final active = _selection.target == target;
    return Material(
      color: active ? const Color(0xffe6eee9) : const Color(0xfff0f3f0),
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        selected: active,
        selectedColor: const Color(0xff18372a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, size: 23),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        subtitle: Text(
          point?.label ?? 'Elige en el mapa',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          size: 18,
        ),
        onTap: () => setState(() => _selection = _selection.selecting(target)),
      ),
    );
  }
}
