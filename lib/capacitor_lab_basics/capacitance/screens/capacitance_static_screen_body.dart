import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../../common/model/clb_model.dart';
import '../../common/render/circuit_render_data.dart';
import '../../common/widgets/static_circuit_view.dart';
import '../model/capacitance_model.dart';

/// Capacitance screen static body for screenshot / QA (not Home).
///
/// 1024×618 FittedBox + [ClbColors.screenBackground] + [StaticCircuitView].
class CapacitanceStaticScreenBody extends StatelessWidget {
  const CapacitanceStaticScreenBody({
    super.key,
    this.model,
    this.data,
  }) : assert(model != null || data != null);

  final CapacitanceModel? model;
  final CircuitRenderData? data;

  @override
  Widget build(BuildContext context) {
    final ClbModel? m = model;
    final render = data ??
        (m != null
            ? CircuitRenderData.fromClbModel(m)
            : (throw StateError('model or data required')));

    return ColoredBox(
      color: ClbColors.screenBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: ClbConstants.canvasWidth,
          height: ClbConstants.canvasHeight,
          child: ColoredBox(
            color: ClbColors.screenBackground,
            child: StaticCircuitView(
              data: render,
              // Phase 3 static QA showed body/probes at model origin
              showVoltmeterOverlays: true,
            ),
          ),
        ),
      ),
    );
  }
}
