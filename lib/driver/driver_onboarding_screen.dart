import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'driver_application.dart';
import 'driver_onboarding_steps.dart';
import 'driver_repository.dart';
import 'photo_field.dart';
import 'verification_pending_screen.dart';

enum _Step { personal, vehicle, documents, review }

enum _PhotoSlot { profile, license, registration }

/// Driver registration: personal data, vehicle, optional documents, review.
class DriverOnboardingScreen extends StatefulWidget {
  const DriverOnboardingScreen({
    super.key,
    required this.repository,
    this.demoMode = false,
    this.pickPhoto = pickPhotoWithImagePicker,
  });

  final DriverRepository repository;
  final bool demoMode;
  final PhotoPicker pickPhoto;

  @override
  State<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends State<DriverOnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();
  final _color = TextEditingController();
  final _cooperative = TextEditingController();
  final _unitNumber = TextEditingController();
  final _scroll = ScrollController();

  DriverPhoto? _photo;
  DriverPhoto? _license;
  DriverPhoto? _registration;
  bool _photoMissing = false;
  bool _sending = false;
  _Step _step = _Step.personal;
  DriverApplication? _reviewed;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _make,
      _model,
      _year,
      _plate,
      _color,
      _cooperative,
      _unitNumber,
    ]) {
      controller.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  bool _currentStepIsValid() {
    final fieldsValid = _form.currentState?.validate() ?? false;
    if (_step != _Step.personal) return fieldsValid;
    setState(() => _photoMissing = _photo == null);
    return fieldsValid && _photo != null;
  }

  void _goTo(_Step step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _next() {
    switch (_step) {
      case _Step.personal || _Step.vehicle:
        if (_currentStepIsValid()) _goTo(_Step.values[_step.index + 1]);
      case _Step.documents:
        _reviewed = _buildApplication();
        _goTo(_reviewed == null ? _Step.personal : _Step.review);
      case _Step.review:
        final application = _reviewed;
        if (application != null) _submit(application);
    }
  }

  void _back() => _goTo(_Step.values[_step.index - 1]);

  // Steps 1 and 2 were validated with the same rules, so create() cannot
  // throw here. Null only if the profile photo is missing.
  DriverApplication? _buildApplication() {
    final photo = _photo;
    if (photo == null) return null;
    return DriverApplication.create(
      name: _name.text,
      photo: photo,
      make: _make.text,
      model: _model.text,
      year: _year.text,
      plate: _plate.text,
      color: _color.text,
      licensePhoto: _license,
      registrationPhoto: _registration,
      cooperative: _cooperative.text,
      unitNumber: _unitNumber.text,
    );
  }

  Future<void> _pick(_PhotoSlot slot, PhotoOrigin origin) async {
    final DriverPhoto? photo;
    try {
      photo = await widget.pickPhoto(origin);
    } on PlatformException catch (error, stackTrace) {
      log('Photo picker failed', error: error, stackTrace: stackTrace);
      _showError('No se pudo abrir la cámara o la galería.');
      return;
    }
    if (photo == null || !mounted) return;
    setState(() {
      switch (slot) {
        case _PhotoSlot.profile:
          _photo = photo;
          _photoMissing = false;
        case _PhotoSlot.license:
          _license = photo;
        case _PhotoSlot.registration:
          _registration = photo;
      }
    });
  }

  Future<void> _submit(DriverApplication application) async {
    // Two taps can arrive before the rebuild that disables the button.
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await widget.repository.submit(application);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => VerificationPendingScreen(demoMode: widget.demoMode),
        ),
      );
    } on DriverRegistrationException catch (error) {
      _showError(error.message);
    } on Exception catch (error, stackTrace) {
      log('Driver registration failed', error: error, stackTrace: stackTrace);
      _showError('No se pudo enviar el registro. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _currentStep() => switch ((_step, _reviewed)) {
    (_Step.personal, _) => PersonalStep(
      name: _name,
      photo: _photo,
      photoMissing: _photoMissing,
      onPickPhoto: (origin) => _pick(_PhotoSlot.profile, origin),
    ),
    (_Step.vehicle, _) => VehicleStep(
      make: _make,
      model: _model,
      year: _year,
      plate: _plate,
      color: _color,
    ),
    (_Step.documents, _) => DocumentsStep(
      license: _license,
      registration: _registration,
      onPickLicense: (origin) => _pick(_PhotoSlot.license, origin),
      onPickRegistration: (origin) => _pick(_PhotoSlot.registration, origin),
      onRemoveLicense: () => setState(() => _license = null),
      onRemoveRegistration: () => setState(() => _registration = null),
      cooperative: _cooperative,
      unitNumber: _unitNumber,
    ),
    (_Step.review, final application?) => ReviewStep(
      application: application,
      demoMode: widget.demoMode,
    ),
    (_Step.review, null) => const SizedBox.shrink(),
  };

  String get _actionLabel => switch (_step) {
    _Step.personal || _Step.vehicle => 'Continuar',
    _Step.documents => 'Revisar',
    _Step.review => 'Enviar registro',
  };

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _step == _Step.personal && !_sending,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_sending && _step != _Step.personal) _back();
    },
    child: Scaffold(
      appBar: AppBar(title: const Text('Registro de conductor')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(key: _form, child: _currentStep()),
                  ),
                ),
              ),
            ),
            _actions(),
          ],
        ),
      ),
    ),
  );

  Widget _actions() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (_step != _Step.personal) ...[
              TextButton(
                onPressed: _sending ? null : _back,
                child: const Text('Atrás'),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: FilledButton(
                onPressed: _sending ? null : _next,
                child:
                    _sending
                        ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(_actionLabel),
              ),
            ),
          ],
        ),
        if (widget.demoMode)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Modo demo · el registro no se envía a ningún servidor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xff52615a)),
            ),
          ),
      ],
    ),
  );
}
