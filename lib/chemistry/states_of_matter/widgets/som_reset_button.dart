import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../som_strings.dart';

/// SoM wrapper around L0 [KratosResetAllButton].
class SomResetButton extends StatelessWidget {
  const SomResetButton({
    super.key,
    required this.onPressed,
    this.radius = 17,
  });

  final VoidCallback onPressed;
  final double radius;

  static const Color baseColor = KratosResetAllButton.baseColor;

  @override
  Widget build(BuildContext context) {
    return KratosResetAllButton(
      onPressed: onPressed,
      radius: radius,
      tooltip: SomStrings.resetAll,
    );
  }
}
