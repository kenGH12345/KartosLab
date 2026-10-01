/// PhET Back Button — navigates back to the simulation catalog.
library;

import 'package:flutter/material.dart';
import '../controls/phet_icon_button.dart';

class PhetBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PhetBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PhetIconButton(
      icon: Icons.arrow_back,
      tooltip: 'Back',
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      size: 24,
    );
  }
}
