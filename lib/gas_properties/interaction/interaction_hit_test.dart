import 'dart:ui' show Offset, Rect;

import '../layout/ideal_layout_slots.dart';
import '../render/gas_render_state.dart';
import '../transform/gas_coordinate_transform.dart';

/// Hit regions in **reference** view space (1008×618).
/// Visual bounds and hit bounds may differ (slightly larger touch targets).
class InteractionHitTest {
  InteractionHitTest(this.transform);

  final GasCoordinateTransform transform;

  /// Lid handle — PhET places HandleNode at the **right** end of the lid base.
  Rect lidHit(GasRenderState state) {
    if (!state.lidIsOn) return Rect.zero;
    final right = transform.modelToViewX(state.containerRight);
    final y = transform.modelToViewY(state.containerTop);
    // Grip sits just left of the right wall, above the lid bar.
    return Rect.fromCenter(
      center: Offset(right - 8, y - 18),
      width: 56,
      height: 44,
    );
  }

  /// Left wall resize handle — vertical strip around left wall mid.
  Rect wallHit(GasRenderState state) {
    final x = transform.modelToViewX(state.containerLeft);
    final top = transform.modelToViewY(state.containerTop);
    final bottom = transform.modelToViewY(state.containerBottom);
    final midY = (top + bottom) / 2;
    return Rect.fromCenter(
      center: Offset(x, midY),
      width: 36,
      height: 80,
    );
  }

  Rect pumpHandleHit({
    required double pumpLeft,
    required double pumpTop,
    required double pumpW,
    required double pumpH,
  }) {
    // Handle near top of pump graphic
    return Rect.fromLTWH(
      pumpLeft + pumpW * 0.35,
      pumpTop,
      pumpW * 0.5,
      pumpH * 0.45,
    );
  }

  Rect heaterHit({
    required double left,
    required double top,
    required double w,
    required double h,
  }) =>
      Rect.fromLTWH(left, top, w, h);

  Rect eraserHit({required double left, required double top}) =>
      Rect.fromLTWH(left, top, 40, 40);

  /// Temperature unit combo on thermometer readout card.
  Rect temperatureUnitHit(GasRenderState state) {
    final (cx, bottom) = IdealLayoutSlots.thermometerAnchor(
      transform,
      state.containerTop,
    );
    const thermW = 72.0;
    const thermH = 150.0;
    return Rect.fromLTWH(cx - thermW / 2, bottom - thermH, 72, 26);
  }

  /// Pressure unit combo under gauge dial.
  Rect pressureUnitHit(GasRenderState state) {
    final (left, cy) = IdealLayoutSlots.pressureGaugeAnchor(
      transform,
      state.containerTop,
    );
    return Rect.fromLTWH(left + 10, cy + 48, 80, 28);
  }
}
