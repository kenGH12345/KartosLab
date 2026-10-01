import 'package:flutter/material.dart';

import '../controller/one_dimension_controller.dart';
import '../model/amplitude_direction.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import '../painters/mode_graph_painter.dart';
import '../render/nm_render_data.dart';
import 'nm_accordion.dart';

class SpectrumAccordion extends StatelessWidget {
  const SpectrumAccordion({
    super.key,
    required this.controller,
    required this.data,
  });

  final OneDimensionController controller;
  final NmRenderData data;

  @override
  Widget build(BuildContext context) {
    return NmAccordion(
      title: NormalModesStrings.normalModeSpectrum,
      expanded: controller.spectrumExpanded,
      onExpandedChanged: controller.setSpectrumExpanded,
      showTitleWhenExpanded: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _AxisLabels(data: data),
            const SizedBox(width: 8),
            for (var i = 0; i < data.numberOfMasses; i++)
              _ModeColumn(
                index: i,
                data: data,
                controller: controller,
              ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 160,
              color: NormalModesColors.separatorStroke,
            ),
            const SizedBox(width: 8),
            AmplitudeDirectionGroup(
              value: data.amplitudeDirection,
              onChanged: controller.setAmplitudeDirection,
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisLabels extends StatelessWidget {
  const _AxisLabels({required this.data});
  final NmRenderData data;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: NormalModesConstants.controlFontSize);
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 25),
          const Text(NormalModesStrings.normalMode, style: style),
          const SizedBox(height: 90),
          const Text(NormalModesStrings.amplitude, style: style),
          const SizedBox(height: 8),
          const Text(NormalModesStrings.frequency, style: style),
          if (data.phasesVisible) ...[
            const SizedBox(height: 24),
            const Text(NormalModesStrings.phase, style: style),
            const Text('+\u03C0', style: style),
            const Text('0', style: style),
            const Text('-\u03C0', style: style),
          ],
        ],
      ),
    );
  }
}

class _ModeColumn extends StatelessWidget {
  const _ModeColumn({
    required this.index,
    required this.data,
    required this.controller,
  });

  final int index;
  final NmRenderData data;
  final OneDimensionController controller;

  @override
  Widget build(BuildContext context) {
    final amp = data.amplitudes[index]
        .clamp(NormalModesConstants.minAmplitude, NormalModesConstants.maxAmplitude);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          StaticModeGraph(graph: data.staticGraphs[index]),
          Text(
            '${index + 1}',
            style: const TextStyle(fontSize: NormalModesConstants.controlFontSize),
          ),
          SizedBox(
            height: 100,
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                min: NormalModesConstants.minAmplitude,
                max: NormalModesConstants.maxAmplitude,
                value: amp.toDouble(),
                onChanged: (v) => controller.setModeAmplitude(index, v),
              ),
            ),
          ),
          Text(
            data.frequencyLabels[index],
            key: ValueKey('freq-label-$index'),
            style: const TextStyle(fontSize: NormalModesConstants.smallFontSize),
          ),
          if (data.phasesVisible)
            SizedBox(
              height: 80,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  min: NormalModesConstants.minPhase,
                  max: NormalModesConstants.maxPhase,
                  value: data.phases[index],
                  onChanged: (v) => controller.setModePhase(index, v),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AmplitudeDirectionGroup extends StatelessWidget {
  const AmplitudeDirectionGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AmplitudeDirection value;
  final ValueChanged<AmplitudeDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ArrowButton(
          horizontal: true,
          selected: value == AmplitudeDirection.horizontal,
          onTap: () => onChanged(AmplitudeDirection.horizontal),
        ),
        const SizedBox(height: 8),
        _ArrowButton(
          horizontal: false,
          selected: value == AmplitudeDirection.vertical,
          onTap: () => onChanged(AmplitudeDirection.vertical),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.horizontal,
    required this.selected,
    required this.onTap,
  });
  final bool horizontal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1 : 0.35,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(painter: _DoubleArrowPainter(horizontal: horizontal)),
          ),
        ),
      ),
    );
  }
}

class _DoubleArrowPainter extends CustomPainter {
  _DoubleArrowPainter({required this.horizontal});
  final bool horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NormalModesColors.axesArrowFill
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    if (horizontal) {
      canvas.drawLine(Offset(8, c.dy), Offset(size.width - 8, c.dy), paint);
      _head(canvas, Offset(size.width - 8, c.dy), const Offset(1, 0));
      _head(canvas, Offset(8, c.dy), const Offset(-1, 0));
    } else {
      canvas.drawLine(Offset(c.dx, 8), Offset(c.dx, size.height - 8), paint);
      _head(canvas, Offset(c.dx, 8), const Offset(0, -1));
      _head(canvas, Offset(c.dx, size.height - 8), const Offset(0, 1));
    }
  }

  void _head(Canvas canvas, Offset tip, Offset dir) {
    final n = Offset(-dir.dy, dir.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * 10 + n * 5).dx, (tip - dir * 10 + n * 5).dy)
      ..lineTo((tip - dir * 10 - n * 5).dx, (tip - dir * 10 - n * 5).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = NormalModesColors.axesArrowFill);
  }

  @override
  bool shouldRepaint(covariant _DoubleArrowPainter oldDelegate) =>
      oldDelegate.horizontal != horizontal;
}
