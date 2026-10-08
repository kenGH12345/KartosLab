/// Magnetic field checkbox + strength slider (MagneticFieldControl).
library;

import 'package:flutter/material.dart';

import '../../common/qm_visual.dart';
import '../model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

const _controlFont = TextStyle(fontSize: 14, color: Colors.black);

class MagneticFieldControl extends StatelessWidget {
  const MagneticFieldControl({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (model.magneticFieldEnabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF777777)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 110,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: model.magneticFieldStrength,
                      min: -1,
                      max: 1,
                      divisions: 20,
                      onChanged: (v) {
                        model.setMagneticFieldStrength(v);
                        onChanged();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      model.magneticFieldStrength.toStringAsFixed(1),
                      style: _controlFont,
                    ),
                    CustomPaint(
                      size: const Size(16, 80),
                      painter: _FieldArrowPainter(
                        strength: model.magneticFieldStrength,
                      ),
                    ),
                    const Text('B', style: _controlFont),
                  ],
                ),
              ],
            ),
          ),
        QmCheckbox(
          value: model.magneticFieldEnabled,
          label: QmStrings.magneticField,
          onChanged: (v) {
            model.setMagneticFieldEnabled(v);
            onChanged();
          },
        ),
      ],
    );
  }
}

class _FieldArrowPainter extends CustomPainter {
  _FieldArrowPainter({required this.strength});
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final mid = size.height / 2;
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, 4), Offset(cx, size.height - 4), paint);
    // Arrow tip direction follows strength sign (source MagneticFieldArrowNode).
    final tipY = strength >= 0 ? 4.0 : size.height - 4;
    final baseY = tipY + (strength >= 0 ? 10 : -10);
    final path = Path()
      ..moveTo(cx, tipY)
      ..lineTo(cx - 5, baseY)
      ..lineTo(cx + 5, baseY)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.red);
    // Ghost midline
    canvas.drawLine(
      Offset(cx - 4, mid),
      Offset(cx + 4, mid),
      Paint()..color = Colors.grey,
    );
  }

  @override
  bool shouldRepaint(covariant _FieldArrowPainter oldDelegate) =>
      oldDelegate.strength != strength;
}
