import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'driver_application.dart';

enum PhotoOrigin { camera, gallery }

/// Returns the chosen photo, or null if the driver cancels. Injected so tests
/// do not depend on the platform picker.
typedef PhotoPicker = Future<DriverPhoto?> Function(PhotoOrigin origin);

const _maxPhotoWidth = 1600.0;
const _photoQuality = 85;

Future<DriverPhoto?> pickPhotoWithImagePicker(PhotoOrigin origin) async {
  final file = await ImagePicker().pickImage(
    source:
        origin == PhotoOrigin.camera ? ImageSource.camera : ImageSource.gallery,
    maxWidth: _maxPhotoWidth,
    imageQuality: _photoQuality,
  );
  if (file == null) return null;
  return DriverPhoto(
    bytes: await file.readAsBytes(),
    mimeType: file.mimeType ?? 'image/jpeg',
  );
}

class PhotoField extends StatelessWidget {
  const PhotoField({
    super.key,
    required this.label,
    required this.photo,
    required this.onPick,
    this.onRemove,
    this.helperText,
    this.errorText,
  });

  final String label;
  final DriverPhoto? photo;
  final ValueChanged<PhotoOrigin> onPick;
  final VoidCallback? onRemove;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = photo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (helperText case final helper?)
          Text(helper, style: const TextStyle(color: Color(0xff52615a))),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.square(
                dimension: 72,
                child:
                    current == null
                        ? const ColoredBox(
                          color: Color(0xffedf2ee),
                          child: Icon(Icons.photo_camera_outlined),
                        )
                        : Image.memory(
                          current.bytes,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder:
                              (_, _, _) =>
                                  const Icon(Icons.broken_image_outlined),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 4,
                children: [
                  if (!kIsWeb)
                    TextButton.icon(
                      onPressed: () => onPick(PhotoOrigin.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Tomar foto'),
                    ),
                  TextButton.icon(
                    onPressed: () => onPick(PhotoOrigin.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Elegir foto'),
                  ),
                  if (current != null && onRemove != null)
                    TextButton(
                      onPressed: onRemove,
                      child: const Text('Quitar'),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (errorText case final error?)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
