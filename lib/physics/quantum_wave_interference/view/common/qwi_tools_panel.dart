import 'package:flutter/material.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// PhET HI/SP right-column `toolsPanel` checkboxes.
///
/// Measuring Tape + Stopwatch + Time/Position plots are wired.
class QwiToolsPanel extends StatelessWidget {
  const QwiToolsPanel({
    super.key,
    required this.keyPrefix,
    required this.measuringTape,
    required this.onMeasuringTape,
    this.stopwatch = false,
    this.onStopwatch,
    this.timePlot = false,
    this.onTimePlot,
    this.positionPlot = false,
    this.onPositionPlot,
    this.detectorProbe,
    this.onDetectorProbe,
  });

  final String keyPrefix;
  final bool measuringTape;
  final ValueChanged<bool> onMeasuringTape;
  final bool stopwatch;
  final ValueChanged<bool>? onStopwatch;
  final bool timePlot;
  final ValueChanged<bool>? onTimePlot;
  final bool positionPlot;
  final ValueChanged<bool>? onPositionPlot;
  final bool? detectorProbe;
  final ValueChanged<bool>? onDetectorProbe;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          key: Key('${keyPrefix}_tape_checkbox'),
          label: QwiStrings.measuringTape,
          value: measuringTape,
          onChanged: onMeasuringTape,
        ),
        _row(
          key: Key('${keyPrefix}_stopwatch_checkbox'),
          label: QwiStrings.stopwatch,
          value: stopwatch,
          onChanged: onStopwatch ?? (_) {},
        ),
        _row(
          key: Key('${keyPrefix}_time_plot_checkbox'),
          label: QwiStrings.timePlot,
          value: timePlot,
          onChanged: onTimePlot ?? (_) {},
        ),
        _row(
          key: Key('${keyPrefix}_position_plot_checkbox'),
          label: QwiStrings.positionPlot,
          value: positionPlot,
          onChanged: onPositionPlot ?? (_) {},
        ),
        if (detectorProbe != null && onDetectorProbe != null)
          _row(
            key: Key('${keyPrefix}_probe_checkbox'),
            label: QwiStrings.detectorProbe,
            value: detectorProbe!,
            onChanged: onDetectorProbe!,
          ),
      ],
    );
  }

  static Widget _row({
    required Key key,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              key: key,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              value: value,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontFamily: 'Arial', fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
