/// Measurement controls — histogram, eraser, atoms, axis, Observe (BlochSphereMeasurementArea).
library;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/qm_typography.dart';
import '../../common/qm_visual.dart';
import '../model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

const _controlFont = QmTypography.control;

class MeasurementControls extends StatelessWidget {
  const MeasurementControls({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final BlochSphereModel model;
  final VoidCallback onChanged;

  String get _buttonLabel {
    if (model.measurementState == BlochMeasurementState.observed) {
      return QmStrings.reprepare;
    }
    if (model.magneticFieldEnabled) return QmStrings.start;
    return QmStrings.observe;
  }

  Color get _buttonColor {
    if (model.measurementState == BlochMeasurementState.observed) {
      return QuantumMeasurementColors.experimentButton;
    }
    return QuantumMeasurementColors.startMeasurementButton;
  }

  String get _axisLetter {
    switch (model.measurementAxis) {
      case MeasurementAxis.x:
        return 'x';
      case MeasurementAxis.y:
        return 'y';
      case MeasurementAxis.z:
        return 'z';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = model.upMeasurementCount + model.downMeasurementCount;
    final upFrac = total == 0 ? 0.0 : model.upMeasurementCount / total;
    final downFrac = total == 0 ? 0.0 : model.downMeasurementCount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // QuantumMeasurementHistogram — T axes + two bars
        SizedBox(
          width: 200,
          height: 160,
          child: CustomPaint(
            painter: BlochHistogramPainter(
              upFrac: upFrac,
              downFrac: downFrac,
              upCount: model.upMeasurementCount,
              downCount: model.downMeasurementCount,
              axisLetter: _axisLetter,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // EraserButton (yellow + glyph) — resetCounts only
        _BlochEraserButton(
          onPressed: () {
            model.erase();
            onChanged();
          },
        ),
        const SizedBox(height: 10),
        Container(
          width: 210,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF777777)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(QmStrings.numberOfAtoms, style: _controlFont),
              const SizedBox(height: 6),
              _AtomCountRadio(
                selected: model.isSingleMeasurementMode,
                timesLabel: '×1',
                onTap: () {
                  model.isSingleMeasurementMode = true;
                  model.reprepare();
                  onChanged();
                },
              ),
              const SizedBox(height: 6),
              _AtomCountRadio(
                selected: !model.isSingleMeasurementMode,
                timesLabel: '×10',
                onTap: () {
                  model.isSingleMeasurementMode = false;
                  model.reprepare();
                  onChanged();
                },
              ),
              const SizedBox(height: 12),
              Text(QmStrings.spinMeasurementAxis, style: _controlFont),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final axis in MeasurementAxis.values) ...[
                    QmAquaRadio(
                      selected: model.measurementAxis == axis,
                      label: axis.name.toUpperCase(),
                      onTap: () {
                        model.measurementAxis = axis;
                        onChanged();
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              if (model.magneticFieldEnabled) ...[
                const SizedBox(height: 10),
                Text(
                  QmStrings.measurementDelay,
                  style: _controlFont,
                ),
                Slider(
                  value: model.measurementDelay.clamp(0.0, 1.0),
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    model.measurementDelay = v;
                    onChanged();
                  },
                ),
                if (model.measurementState ==
                    BlochMeasurementState.timingObservation)
                  LinearProgressIndicator(
                    value: model.measurementDelay <= 0
                        ? 1
                        : (model.timeElapsed / model.measurementDelay)
                            .clamp(0.0, 1.0),
                    color: const Color(0xFFCC00CC),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 210,
          child: QmPhetTextButton(
            label: _buttonLabel,
            enabled: model.measurementState !=
                BlochMeasurementState.timingObservation,
            baseColor: _buttonColor,
            onPressed: () {
              if (model.measurementState == BlochMeasurementState.prepared) {
                model.initiateObservation();
              } else {
                model.reprepare();
              }
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}

class _AtomCountRadio extends StatelessWidget {
  const _AtomCountRadio({
    required this.selected,
    required this.timesLabel,
    required this.onTap,
  });

  final bool selected;
  final String timesLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: QmAquaRadio.ring, width: 2),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: QmAquaRadio.ring,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.35),
                colors: [Color(0xFFFFAAAA), Color(0xFFE53935)],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(timesLabel, style: QmTypography.title),
        ],
      ),
    );
  }
}

/// PhET EraserButton — yellow rect + eraser glyph (no Material Icons).
class _BlochEraserButton extends StatelessWidget {
  const _BlochEraserButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF422),
      borderRadius: BorderRadius.circular(4),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: const SizedBox(
          width: 44,
          height: 36,
          child: CustomPaint(painter: _EraserGlyphPainter()),
        ),
      ),
    );
  }
}

class _EraserGlyphPainter extends CustomPainter {
  const _EraserGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.4);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-11, -5, 18, 10),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFCC80));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, -5, 6, 10),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFFE91E63),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// T-axis histogram matching QuantumMeasurementHistogram (vertical).
class BlochHistogramPainter extends CustomPainter {
  BlochHistogramPainter({
    required this.upFrac,
    required this.downFrac,
    required this.upCount,
    required this.downCount,
    required this.axisLetter,
  });

  final double upFrac;
  final double downFrac;
  final int upCount;
  final int downCount;
  final String axisLetter;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final ox = size.width / 2;
    final oy = size.height - 28;
    final axisH = size.height - 40;
    final axisW = size.width - 24;

    // Y axis (up) + X axis (T shape)
    canvas.drawLine(Offset(ox, oy), Offset(ox, oy - axisH), axisPaint);
    canvas.drawLine(
      Offset(ox - axisW / 2, oy),
      Offset(ox + axisW / 2, oy),
      axisPaint,
    );
    // Tick marks on Y
    for (final t in [0.33, 0.66, 1.0]) {
      final y = oy - axisH * t;
      canvas.drawLine(Offset(ox - 4, y), Offset(ox + 4, y), axisPaint);
    }

    final barW = axisW / 6;
    final leftCx = ox - axisW * 0.28;
    final rightCx = ox + axisW * 0.28;
    final upH = axisH * upFrac;
    final downH = axisH * downFrac;

    if (upH > 0.5) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(leftCx, oy - upH / 2),
          width: barW,
          height: upH,
        ),
        Paint()..color = Colors.black,
      );
    }
    if (downH > 0.5) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(rightCx, oy - downH / 2),
          width: barW,
          height: downH,
        ),
        Paint()..color = const Color(0xFFCC00CC),
      );
    }

    // Count labels above bars
    final tp = TextPainter(textDirection: TextDirection.ltr);
    void label(String s, Offset c, Color color) {
      tp.text = TextSpan(
        text: s,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      );
      tp.layout();
      tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
    }

    if (upCount + downCount > 0) {
      label('$upCount', Offset(leftCx, oy - upH - 10), Colors.black);
      label('$downCount', Offset(rightCx, oy - downH - 10), const Color(0xFFCC00CC));
    }

    // Ket labels under X axis
    label('|↑$axisLetter⟩', Offset(leftCx, oy + 14), Colors.black);
    label('|↓$axisLetter⟩', Offset(rightCx, oy + 14), Colors.black);
  }

  @override
  bool shouldRepaint(covariant BlochHistogramPainter oldDelegate) =>
      oldDelegate.upFrac != upFrac ||
      oldDelegate.downFrac != downFrac ||
      oldDelegate.upCount != upCount ||
      oldDelegate.downCount != downCount ||
      oldDelegate.axisLetter != axisLetter;
}
