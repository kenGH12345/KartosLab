import 'package:flutter/material.dart';

import '../../density_strings.dart';

/// AC-F19: Adapted from PhET · GPL-3.0 · CC0 textures (assets/density/NOTICE.md).
void showDensityAboutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(DensityStrings.aboutTitle),
      content: const SingleChildScrollView(
        child: Text(DensityStrings.aboutBody),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
