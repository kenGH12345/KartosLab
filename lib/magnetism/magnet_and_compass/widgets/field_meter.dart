import 'dart:math';
import 'package:flutter/material.dart';

import '../model/magnetic_field.dart';
import '../model/magnet_state.dart';
import '../magnet_and_compass_constants.dart';

/// Draggable field-meter panel that shows |B|, θ, Bx, By at the current
/// cursor position.
///
/// Extracted from `_buildFieldMeter` method
/// (`simulations/magnet_and_compass.dart:454-522`) and converted to a
/// standalone widget.
///
/// The parent owns [MagnetState] and calls `setState` via [onPositionChanged].
class FieldMeter extends StatelessWidget {
  final MagnetState state;
  final Size screenSize;
  final ValueChanged<Offset> onPositionChanged;

  const FieldMeter({
    super.key,
    required this.state,
    required this.screenSize,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    const w = 260.0, h = 192.0;
    final b = MagneticField.compute(
      state.fieldMeterPos,
      state.magnetPos,
      state.magnetAngle,
      kMagnetWidth / 2,
      state.strength,
      state.flipped,
      state.earthField,
    );
    final mag = MagneticField.magnitude(b);
    final deg = MagneticField.fieldAngle(b) * 180 / pi;
    final cx = state.fieldMeterPos.dx;
    final cy = state.fieldMeterPos.dy;

    return Positioned(
      left: cx - w / 2,
      top: cy - h / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = state.fieldMeterPos;
          final nx = (cur.dx + d.delta.dx).clamp(w / 2, screenSize.width - w / 2);
          final ny = (cur.dy + d.delta.dy).clamp(h / 2, screenSize.height - h / 2);
          onPositionChanged(Offset(nx, ny));
        },
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xff0d2255).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlueAccent.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'B = ${mag.toStringAsFixed(3)} T',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'θ = ${deg.toStringAsFixed(1)}°',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Bx= ${b.dx.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                'By= ${b.dy.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const Spacer(),
              const Icon(Icons.gps_fixed, color: Colors.lightBlueAccent, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
