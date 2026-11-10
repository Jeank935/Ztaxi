import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/auth_controller.dart';
import '../home.dart';
import '../maps/geo_coordinate.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final _form = GlobalKey<FormState>();
  final _auth = Get.find<AuthController>();
  late final _name = TextEditingController(text: _auth.myUser.value.name ?? '');
  final _locations = <String, GeoCoordinate?>{};
  final _labels = <String, String>{};
  File? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.myUser.value;
    _locations.addAll({
      'home': user.homeAddress,
      'business': user.businessAddress,
      'shopping': user.shoppingAddress,
    });
    _labels.addAll({
      'home': user.hAddress ?? '',
      'business': user.bAddress ?? '',
      'shopping': user.mallAddress ?? '',
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick(String field, String title) async {
    final point = await Navigator.push<GeoCoordinate>(
      context,
      MaterialPageRoute(
        builder:
            (_) => HomeScreen(
              pointPickerTitle: title,
              initialPoint: _locations[field],
            ),
      ),
    );
    if (point != null && mounted) {
      setState(() {
        _locations[field] = point;
        _labels[field] = point.label;
      });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_locations.values.any((point) => point == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona las tres ubicaciones en el mapa.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _auth.storeUserInfo(
        _photo,
        _name.text.trim(),
        _labels['home']!,
        _labels['business']!,
        _labels['shopping']!,
        url: _auth.myUser.value.image ?? '',
        homeLatLng: _locations['home'],
        businessLatLng: _locations['business'],
        shoppingLatLng: _locations['shopping'],
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar el perfil. Inténtalo de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu perfil')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: IconButton(
                  tooltip: 'Elegir foto de perfil',
                  icon:
                      _photo == null
                          ? const Icon(Icons.add_a_photo_outlined, size: 48)
                          : CircleAvatar(
                            radius: 40,
                            backgroundImage: FileImage(_photo!),
                          ),
                  onPressed:
                      _saving
                          ? null
                          : () async {
                            final image = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1024,
                            );
                            if (image != null && mounted) {
                              setState(() => _photo = File(image.path));
                            }
                          },
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        (value?.trim().length ?? 0) < 2
                            ? 'Escribe tu nombre.'
                            : null,
              ),
              const SizedBox(height: 24),
              for (final entry
                  in const {
                    'home': 'Casa',
                    'business': 'Trabajo',
                    'shopping': 'Compras',
                  }.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value),
                  subtitle: Text(
                    _labels[entry.key]!.isEmpty
                        ? 'Seleccionar en el mapa'
                        : _labels[entry.key]!,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap:
                      _saving
                          ? null
                          : () => _pick(
                            entry.key,
                            'Ubicación de ${entry.value.toLowerCase()}',
                          ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Guardando…' : 'Guardar perfil'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
