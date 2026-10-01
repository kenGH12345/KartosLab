import 'package:flutter/material.dart';

import '../../diffusion/diffusion_constants.dart';
import '../../diffusion/model/diffusion_model.dart';
import '../../diffusion/widgets/diffusion_shell.dart';

/// Gas Properties · Diffusion tab — **reuses** `lib/diffusion` unchanged.
///
/// - Does not modify `lib/diffusion/**`
/// - Ideal / Explore / Energy may also import diffusion widgets/painters
///   when useful; this bridge is the Diffusion-screen entry.
class GasPropertiesDiffusionTab extends StatefulWidget {
  const GasPropertiesDiffusionTab({super.key, this.layoutScale = 1});

  /// Kept for API symmetry with Ideal shells; diffusion uses its own layout box.
  final double layoutScale;

  @override
  State<GasPropertiesDiffusionTab> createState() =>
      _GasPropertiesDiffusionTabState();
}

class _GasPropertiesDiffusionTabState extends State<GasPropertiesDiffusionTab> {
  late final DiffusionModel _model;

  @override
  void initState() {
    super.initState();
    _model = DiffusionModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.layoutScale.clamp(0.55, 1.0);
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: DiffusionConstants.layoutWidth * scale,
        height: DiffusionConstants.layoutHeight * scale,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: DiffusionConstants.layoutWidth,
            height: DiffusionConstants.layoutHeight,
            // Unmodified DiffusionShell — NumberSpinners / panels / play area.
            child: DiffusionShell(model: _model),
          ),
        ),
      ),
    );
  }
}
