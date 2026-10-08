/// Bloch scene — prep | divider | measurement (BlochSphereScreenView).
library;

import 'package:flutter/material.dart';

import '../../common/qm_visual.dart';
import '../composer/bloch_composer.dart';
import '../model/bloch_sphere_model.dart';
import '../components/bloch_sphere_view.dart';
import '../components/bloch_state_equation.dart';
import '../components/measurement_controls.dart';
import '../components/state_preset_controls.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class BlochScene extends StatelessWidget {
  const BlochScene({
    super.key,
    required this.model,
    required this.geometry,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final BlochLayoutGeometry geometry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final prep = model.preparation;
    final meas = model.singleMeasurement;
    final sphereR = 100.0 * geometry.measureSphereScale;

    return Stack(
      children: [
        // Dividing line
        Positioned(
          left: geometry.dividerRect.left,
          top: geometry.dividerRect.top,
          child: QmExperimentDividingLine(height: geometry.dividerRect.height),
        ),

        // ── Prep (left of divider) ──
        Positioned(
          left: geometry.prepArea.left + 16,
          top: geometry.prepArea.top,
          width: geometry.prepArea.width - 24,
          child: BlochStateEquation(
            polar: prep.polarAngle,
            azimuthal: prep.azimuthalAngle,
          ),
        ),
        PositionedBlochSphere(
          designCenter: geometry.prepSphereCenter,
          polar: prep.polarAngle,
          azimuthal: prep.azimuthalAngle,
          scale: geometry.prepSphereScale,
          drawKets: true,
          drawAngleIndicators: true,
          drawAxesLabels: true,
        ),
        Positioned(
          left: geometry.prepSphereCenter.dx - 135,
          top: geometry.prepSphereCenter.dy +
              100 * geometry.prepSphereScale +
              20,
          child: StatePresetControls(model: model, onChanged: onChanged),
        ),

        // ── Measurement: equation + Basis (single mode) ──
        Positioned(
          left: geometry.measurementArea.left,
          top: geometry.measurementArea.top,
          child: BlochMeasureEquationPanel(
            model: model,
            onChanged: onChanged,
          ),
        ),

        // Single / multi Bloch spheres
        if (model.isSingleMeasurementMode)
          PositionedBlochSphere(
            designCenter: geometry.measureSphereCenter,
            polar: meas.polarAngle,
            azimuthal: meas.azimuthalAngle,
            scale: geometry.measureSphereScale,
            drawKets: false,
            drawAngleIndicators: true,
            drawAxesLabels: true,
          )
        else
          ..._multiSpheres(),

        // SystemUnderTest (Atom chamber) under measure sphere
        Positioned(
          left: geometry.measureSphereCenter.dx - 75,
          top: geometry.measureSphereCenter.dy + sphereR + 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (model.magneticFieldEnabled)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _MagneticStrengthPanel(
                    model: model,
                    onChanged: onChanged,
                  ),
                ),
              BlochSystemUnderTest(
                isSingle: model.isSingleMeasurementMode,
                showField: model.magneticFieldEnabled,
                fieldStrength: model.magneticFieldStrength,
              ),
            ],
          ),
        ),

        // Magnetic Field checkbox — centered under atom (PhET)
        Positioned(
          left: geometry.measureSphereCenter.dx - 70,
          top: geometry.measureSphereCenter.dy + sphereR + 12 + 160 + 12,
          child: QmCheckbox(
            value: model.magneticFieldEnabled,
            label: QmStrings.magneticField,
            onChanged: (v) {
              model.setMagneticFieldEnabled(v);
              onChanged();
            },
          ),
        ),

        // Right column: histogram + eraser + atoms/axis + Observe
        Positioned(
          left: geometry.controlsOrigin.dx,
          top: geometry.controlsOrigin.dy,
          child: MeasurementControls(model: model, onChanged: onChanged),
        ),
      ],
    );
  }

  List<Widget> _multiSpheres() {
    const spacing = 70.0;
    const lattice = [3, 2, 3, 2];
    var row = 0;
    var col = 0.0;
    final widgets = <Widget>[];
    for (var i = 0; i < model.multipleMeasurements.length; i++) {
      final s = model.multipleMeasurements[i];
      final cx = geometry.measureSphereCenter.dx - spacing + col * spacing;
      final cy = geometry.measureSphereCenter.dy - 40 + row * spacing;
      widgets.add(
        PositionedBlochSphere(
          designCenter: Offset(cx, cy),
          polar: s.polarAngle,
          azimuthal: s.azimuthalAngle,
          scale: 0.3,
          drawKets: false,
          drawAngleIndicators: true,
          drawAxesLabels: false,
        ),
      );
      col += 1;
      if (col >= lattice[row % lattice.length]) {
        col = lattice[row % lattice.length] == 3 ? 0.5 : 0;
        row++;
      }
    }
    return widgets;
  }
}

/// Compact B-field strength control beside Atom chamber (MagneticFieldControl).
class _MagneticStrengthPanel extends StatelessWidget {
  const _MagneticStrengthPanel({
    required this.model,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                model.magneticFieldStrength.toStringAsFixed(1),
                style: const TextStyle(fontSize: 13),
              ),
              const Text('B', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
