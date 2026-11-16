import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'driver_application.dart';
import 'photo_field.dart';

const _mutedText = Color(0xff52615a);
const _fieldGap = SizedBox(height: 12);

class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  final String title;
  final String subtitle;
  final String? progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (progress case final text?)
        Text(text, style: const TextStyle(color: _mutedText, fontSize: 13)),
      const SizedBox(height: 4),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: _mutedText)),
      const SizedBox(height: 20),
    ],
  );
}

class PersonalStep extends StatelessWidget {
  const PersonalStep({
    super.key,
    required this.name,
    required this.photo,
    required this.photoMissing,
    required this.onPickPhoto,
  });

  final TextEditingController name;
  final DriverPhoto? photo;
  final bool photoMissing;
  final ValueChanged<PhotoOrigin> onPickPhoto;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StepHeader(
        progress: 'Paso 1 de 3',
        title: 'Tus datos',
        subtitle: 'Así te verán los pasajeros.',
      ),
      TextFormField(
        controller: name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        decoration: const InputDecoration(labelText: 'Nombre completo'),
        validator: DriverValidators.name,
      ),
      const SizedBox(height: 20),
      PhotoField(
        label: 'Foto de perfil',
        helperText: 'Una foto clara de tu rostro.',
        photo: photo,
        onPick: onPickPhoto,
        errorText: photoMissing ? 'Agrega una foto tuya.' : null,
      ),
    ],
  );
}

class VehicleStep extends StatelessWidget {
  const VehicleStep({
    super.key,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.color,
  });

  final TextEditingController make;
  final TextEditingController model;
  final TextEditingController year;
  final TextEditingController plate;
  final TextEditingController color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StepHeader(
        progress: 'Paso 2 de 3',
        title: 'Tu vehículo',
        subtitle: 'Los datos del taxi que vas a conducir.',
      ),
      _textField(make, 'Marca', 'Escribe la marca.'),
      _fieldGap,
      _textField(model, 'Modelo', 'Escribe el modelo.'),
      _fieldGap,
      TextFormField(
        controller: year,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: const InputDecoration(labelText: 'Año'),
        validator: DriverValidators.year,
      ),
      _fieldGap,
      TextFormField(
        controller: plate,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Placa',
          hintText: 'ZAB-1234',
        ),
        validator: DriverValidators.plate,
      ),
      _fieldGap,
      _textField(color, 'Color', 'Escribe el color.'),
    ],
  );

  Widget _textField(
    TextEditingController controller,
    String label,
    String requiredMessage,
  ) => TextFormField(
    controller: controller,
    textCapitalization: TextCapitalization.sentences,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(labelText: label),
    validator: (value) => DriverValidators.requiredText(value, requiredMessage),
  );
}

class DocumentsStep extends StatelessWidget {
  const DocumentsStep({
    super.key,
    required this.license,
    required this.registration,
    required this.onPickLicense,
    required this.onPickRegistration,
    required this.onRemoveLicense,
    required this.onRemoveRegistration,
    required this.cooperative,
    required this.unitNumber,
  });

  final DriverPhoto? license;
  final DriverPhoto? registration;
  final ValueChanged<PhotoOrigin> onPickLicense;
  final ValueChanged<PhotoOrigin> onPickRegistration;
  final VoidCallback onRemoveLicense;
  final VoidCallback onRemoveRegistration;
  final TextEditingController cooperative;
  final TextEditingController unitNumber;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StepHeader(
        progress: 'Paso 3 de 3',
        title: 'Documentos y cooperativa',
        subtitle: 'Opcional. Puedes agregarlos ahora o más adelante.',
      ),
      PhotoField(
        label: 'Licencia de conducir',
        photo: license,
        onPick: onPickLicense,
        onRemove: onRemoveLicense,
      ),
      const SizedBox(height: 20),
      PhotoField(
        label: 'Matrícula del vehículo',
        photo: registration,
        onPick: onPickRegistration,
        onRemove: onRemoveRegistration,
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: cooperative,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Cooperativa'),
      ),
      _fieldGap,
      TextFormField(
        controller: unitNumber,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Número de unidad'),
      ),
    ],
  );
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.application,
    required this.demoMode,
  });

  final DriverApplication application;
  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    final vehicle = application.vehicle;
    final documents = [
      if (application.licensePhoto != null) 'Licencia',
      if (application.registrationPhoto != null) 'Matrícula',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeader(
          title: 'Revisa tu registro',
          subtitle: 'Confirma que los datos estén correctos antes de enviar.',
        ),
        Row(
          children: [
            ClipOval(
              child: Image.memory(
                application.photo.bytes,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, _, _) => const Icon(Icons.person_outline, size: 56),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                application.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _row('Vehículo', '${vehicle.make} ${vehicle.model} ${vehicle.year}'),
        _row('Placa', vehicle.plate),
        _row('Color', vehicle.color),
        _row(
          'Cooperativa',
          application.cooperative.isEmpty
              ? 'Sin indicar'
              : application.cooperative,
        ),
        _row(
          'Número de unidad',
          application.unitNumber.isEmpty
              ? 'Sin indicar'
              : application.unitNumber,
        ),
        _row(
          'Documentos',
          documents.isEmpty ? 'Ninguno' : documents.join(', '),
        ),
        if (demoMode)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Modo demo: el registro se guarda solo mientras la app está '
              'abierta y nadie lo revisa.',
              style: TextStyle(color: _mutedText),
            ),
          ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _mutedText, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
