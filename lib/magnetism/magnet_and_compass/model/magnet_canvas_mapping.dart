import 'package:flutter/material.dart';

import '../magnet_and_compass_constants.dart';

/// Screen ↔ canvas mapping for Magnet & Compass.
///
/// Original `SimulationPage` / `MagnetAndCompassPage`:
/// - canvas **is** `MediaQuery.size` (full window, no AppBar, no NineGrid)
/// - there is **no** LAYOUT_BOUNDS, FittedBox, or Transform.scale
/// - magnet / compass / field-meter positions are fractions of that window
/// - object sizes are absolute logical pixels (1 px = 1 MagneticField unit)
///
/// Flutter play area is the NineGrid center slot. Positions stored in
/// [MagnetState] stay **center-local** (what `Positioned` and
/// `MagneticField.compute` already use). This helper only converts the
/// original window-fraction semantics into that local space by subtracting
/// the center slot's origin — a translation, not a scale.
class MagnetCanvasMapping {
  /// Original `_initPositions` fractions of `MediaQuery.size`.
  static const Offset magnetWindowFrac = Offset(0.42, 0.50);
  static const Offset compassWindowFrac = Offset(0.60, 0.66);

  /// Original `_initPositions` fraction of `MediaQuery.size` (independent
  /// of magnet — not a relative offset). Must match `FieldMeter` 260×192.
  static const Offset fieldMeterWindowFrac = Offset(0.28, 0.30);
  static const double fieldMeterWidth = 260.0;
  static const double fieldMeterHeight = 192.0;

  const MagnetCanvasMapping({
    required this.windowSize,
    required this.canvasSize,
    required this.canvasOriginInWindow,
  });

  final Size windowSize;
  final Size canvasSize;
  final Offset canvasOriginInWindow;

  Offset get magnetWindowPos => Offset(
        windowSize.width * magnetWindowFrac.dx,
        windowSize.height * magnetWindowFrac.dy,
      );

  Offset get compassWindowPos => Offset(
        windowSize.width * compassWindowFrac.dx,
        windowSize.height * compassWindowFrac.dy,
      );

  Offset get fieldMeterWindowPos => Offset(
        windowSize.width * fieldMeterWindowFrac.dx,
        windowSize.height * fieldMeterWindowFrac.dy,
      );

  /// Pure translation. Preserves pixel vectors between window-fraction objects.
  Offset windowToCanvas(Offset windowPos) =>
      windowPos - canvasOriginInWindow;

  Offset clampMagnet(Offset canvasPos) => Offset(
        canvasPos.dx.clamp(kMagnetWidth / 2, canvasSize.width - kMagnetWidth / 2),
        canvasPos.dy
            .clamp(kMagnetHeight / 2, canvasSize.height - kMagnetHeight / 2),
      );

  Offset clampCompass(Offset canvasPos) => Offset(
        canvasPos.dx.clamp(kCompassRadius, canvasSize.width - kCompassRadius),
        canvasPos.dy.clamp(kCompassRadius, canvasSize.height - kCompassRadius),
      );

  Offset clampFieldMeter(Offset canvasPos) => Offset(
        canvasPos.dx.clamp(
          fieldMeterWidth / 2,
          canvasSize.width - fieldMeterWidth / 2,
        ),
        canvasPos.dy.clamp(
          fieldMeterHeight / 2,
          canvasSize.height - fieldMeterHeight / 2,
        ),
      );

  Offset get magnetCanvasPos =>
      clampMagnet(windowToCanvas(magnetWindowPos));

  Offset get compassCanvasPos =>
      clampCompass(windowToCanvas(compassWindowPos));

  Offset get fieldMeterCanvasPos =>
      clampFieldMeter(windowToCanvas(fieldMeterWindowPos));
}
