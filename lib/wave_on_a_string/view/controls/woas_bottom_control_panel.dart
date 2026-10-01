import 'package:flutter/material.dart';

import '../../model/woas_mode.dart';
import '../../model/woas_model.dart';
import '../../woas_constants.dart';
import 'woas_number_control.dart';

/// PhET `BottomControlPanel` — mode-conditional NumberControls + tool checkboxes.
class WoasBottomControlPanel extends StatelessWidget {
  const WoasBottomControlPanel({super.key, required this.model});

  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    final mode = model.waveMode;
    return Container(
      key: const Key('woas_bottom_control_panel'),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9FCC5),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54, width: 2 / 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._modeControls(mode),
          Container(
            width: 1,
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.black54,
          ),
          _CheckboxColumn(model: model),
        ],
      ),
    );
  }

  List<Widget> _modeControls(WoasMode mode) {
    final damping = WoasNumberControl(
      key: const Key('damping_control'),
      title: 'Damping',
      value: model.damping * 100,
      min: dampingMin * 100,
      max: dampingMax * 100,
      delta: 1,
      decimalPlaces: 0,
      unitSuffix: '%',
      onChanged: (v) => model.setDamping(v / 100),
    );
    final tension = WoasNumberControl(
      key: const Key('tension_control'),
      title: 'Tension',
      value: model.tension * 100,
      min: tensionMin * 100,
      max: tensionMax * 100,
      delta: 1,
      decimalPlaces: 0,
      unitSuffix: '%',
      onChanged: (v) => model.setTension(v / 100),
    );
    final amplitude = WoasNumberControl(
      key: const Key('amplitude_control'),
      title: 'Amplitude',
      value: model.amplitudeCm,
      min: amplitudeMinCm,
      max: maxStartAmplitudeCm,
      delta: 0.01,
      decimalPlaces: 2,
      unitSuffix: ' cm',
      onChanged: model.setAmplitudeCm,
    );
    final frequency = WoasNumberControl(
      key: const Key('frequency_control'),
      title: 'Frequency',
      value: model.frequencyHz,
      min: frequencyMinHz,
      max: frequencyMaxHz,
      delta: 0.01,
      decimalPlaces: 2,
      unitSuffix: ' Hz',
      onChanged: model.setFrequencyHz,
    );
    final pulseWidth = WoasNumberControl(
      key: const Key('pulse_width_control'),
      title: 'Pulse Width',
      value: model.pulseWidthS,
      min: pulseWidthMinS,
      max: pulseWidthMaxS,
      delta: 0.01,
      decimalPlaces: 2,
      unitSuffix: ' s',
      onChanged: model.setPulseWidthS,
    );

    Widget spaced(Widget w) => Padding(
          padding: const EdgeInsets.only(right: 35),
          child: w,
        );

    switch (mode) {
      case WoasMode.manual:
        return [spaced(damping), tension];
      case WoasMode.oscillate:
        return [
          spaced(amplitude),
          spaced(frequency),
          spaced(damping),
          tension,
        ];
      case WoasMode.pulse:
        return [
          spaced(amplitude),
          spaced(pulseWidth),
          spaced(damping),
          tension,
        ];
    }
  }
}

class _CheckboxColumn extends StatelessWidget {
  const _CheckboxColumn({required this.model});
  final WoasModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CheckRow(
          key: const Key('rulers_checkbox'),
          label: 'Rulers',
          value: model.rulersVisible,
          onChanged: model.setRulersVisible,
        ),
        _CheckRow(
          key: const Key('stopwatch_checkbox'),
          label: 'Stopwatch',
          value: model.stopwatch.isVisible,
          onChanged: model.setStopwatchVisible,
        ),
        _CheckRow(
          key: const Key('reference_line_checkbox'),
          label: 'Reference Line',
          value: model.referenceLineVisible,
          onChanged: model.setReferenceLineVisible,
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(18, 18),
              painter: _CheckPainter(checked: value),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.checked});
  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (checked) {
      final p = Path()
        ..moveTo(size.width * 0.2, size.height * 0.55)
        ..lineTo(size.width * 0.42, size.height * 0.75)
        ..lineTo(size.width * 0.8, size.height * 0.28);
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.checked != checked;
}
