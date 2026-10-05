import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import '../widgets/waves_intro_toolbox.dart';

/// Right stack — PhET ToolboxPanel + WaveInterferenceControlPanel.
class WavesIntroControlColumn extends StatelessWidget {
  const WavesIntroControlColumn({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final scene = model.scene;
        final config = scene.config;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WavesIntroToolbox(model: model),
            const SizedBox(height: WavesIntroConstants.layoutSpacing),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Frequency', style: _labelStyle(context)),
                  if (config.kind == SceneKind.light)
                    _SpectrumFrequencySlider(
                      value: scene.controlFrequency,
                      min: config.frequencyMin,
                      max: config.frequencyMax,
                      onChanged: model.setFrequency,
                    )
                  else ...[
                    SliderTheme(
                      data: _sliderTheme(context),
                      child: Slider(
                        value: scene.controlFrequency,
                        min: config.frequencyMin,
                        max: config.frequencyMax,
                        onChanged: model.setFrequency,
                      ),
                    ),
                    const _TickRuler(left: 'min', right: 'max'),
                  ],
                  const SizedBox(height: 7),
                  Text('Amplitude', style: _labelStyle(context)),
                  SliderTheme(
                    data: _sliderTheme(context),
                    child: Slider(
                      value: scene.controlAmplitude,
                      min: WavesIntroConstants.amplitudeMin,
                      max: WavesIntroConstants.amplitudeMax,
                      onChanged: model.setAmplitude,
                    ),
                  ),
                  const _TickRuler(left: '0', right: 'max'),
                  const SizedBox(height: 8),
                  const Divider(height: 14, color: Color(0xFF646464)),
                  _Check(
                    label: 'Graph',
                    value: model.showGraph,
                    onChanged: model.setShowGraph,
                  ),
                  if (config.kind == SceneKind.sound)
                    _Check(
                      label: 'Play Tone',
                      value: model.audioState.isTonePlaying,
                      onChanged: model.setTonePlaying,
                    ),
                  if (config.kind == SceneKind.light) ...[
                    _Check(
                      label: 'Screen',
                      value: model.showScreen,
                      onChanged: model.setShowScreen,
                    ),
                    _Check(
                      label: 'Sound Effect',
                      value: model.audioState.soundEffectEnabled,
                      onChanged: model.setSoundEffectEnabled,
                    ),
                  ],
                  if (config.kind == SceneKind.sound) ...[
                    const SizedBox(height: 4),
                    _RadioColumn<SoundViewType>(
                      groupValue: scene.soundViewType,
                      onChanged: model.setSoundViewType,
                      items: const [
                        (SoundViewType.waves, 'Waves'),
                        (SoundViewType.particles, 'Particles'),
                        (SoundViewType.both, 'Both'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium ??
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

  static SliderThemeData _sliderTheme(BuildContext context) =>
      SliderTheme.of(context).copyWith(
        trackHeight: 1,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F2),
      elevation: 1,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: child,
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _RadioColumn<T> extends StatelessWidget {
  const _RadioColumn({
    required this.groupValue,
    required this.onChanged,
    required this.items,
  });
  final T groupValue;
  final ValueChanged<T> onChanged;
  final List<(T, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (value, label) in items)
          InkWell(
            onTap: () => onChanged(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    value == groupValue
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: value == groupValue
                        ? const Color(0xFF2196F3)
                        : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TickRuler extends StatelessWidget {
  const _TickRuler({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
          width: double.infinity,
          child: CustomPaint(painter: _TickPainter()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left, style: const TextStyle(fontSize: 10, color: Colors.black54)),
            Text(right, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ],
    );
  }
}

class _TickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), p);
    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final h = i % 5 == 0 ? size.height : size.height * 0.45;
      canvas.drawLine(Offset(x, size.height - h), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpectrumFrequencySlider extends StatelessWidget {
  const _SpectrumFrequencySlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFF8B00FF),
                    ],
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 14,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Color(
                    WavesIntroConstants.wavelengthToArgb(
                      WavesIntroConstants.wavelength(
                        waveSpeedValue: WavesIntroConstants.lightWaveSpeed,
                        frequency: value,
                      ),
                    ),
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Continuous / Pulse — left of wave area (PhET DisturbanceTypeRadioButtonGroup).
class DisturbanceTypeToggle extends StatelessWidget {
  const DisturbanceTypeToggle({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final type = model.scene.disturbanceType;
        return Column(
          children: [
            _IconToggle(
              selected: type == DisturbanceType.continuous,
              onTap: () => model.setDisturbanceType(DisturbanceType.continuous),
              child: CustomPaint(
                size: const Size(36, 28),
                painter: _WaveIconPainter(pulse: false),
              ),
            ),
            const SizedBox(height: 6),
            _IconToggle(
              selected: type == DisturbanceType.pulse,
              onTap: () => model.setDisturbanceType(DisturbanceType.pulse),
              child: CustomPaint(
                size: const Size(36, 28),
                painter: _WaveIconPainter(pulse: true),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IconToggle extends StatelessWidget {
  const _IconToggle({
    required this.selected,
    required this.onTap,
    required this.child,
  });
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? const Color(0xFF2196F3) : Colors.black26,
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _WaveIconPainter extends CustomPainter {
  _WaveIconPainter({required this.pulse});
  final bool pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    if (pulse) {
      path.moveTo(2, size.height / 2);
      path.lineTo(size.width * 0.35, size.height / 2);
      path.cubicTo(
        size.width * 0.45,
        size.height / 2,
        size.width * 0.5,
        4,
        size.width * 0.55,
        size.height / 2,
      );
      path.cubicTo(
        size.width * 0.6,
        size.height - 4,
        size.width * 0.65,
        size.height / 2,
        size.width * 0.7,
        size.height / 2,
      );
      path.lineTo(size.width - 2, size.height / 2);
    } else {
      path.moveTo(2, size.height / 2);
      for (var i = 0; i <= 24; i++) {
        final x = 2 + i / 24 * (size.width - 4);
        final sy = size.height / 2 +
            size.height * 0.32 * math.sin(i / 24 * math.pi * 2);
        if (i == 0) {
          path.moveTo(x, sy);
        } else {
          path.lineTo(x, sy);
        }
      }
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WaveIconPainter old) => old.pulse != pulse;
}

/// PhET ViewpointRadioButtonGroup — vertical, left-aligned with wave area.
class ViewpointRadioGroup extends StatelessWidget {
  const ViewpointRadioGroup({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return _RadioPair<Viewpoint>(
      a: Viewpoint.top,
      b: Viewpoint.side,
      aLabel: 'Top View',
      bLabel: 'Side View',
      value: model.viewpoint,
      onChanged: model.setViewpoint,
    );
  }
}

/// PhET TimeControlNode — play/pause/step + vertical Normal/Slow.
class TimeControlCluster extends StatelessWidget {
  const TimeControlCluster({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RoundTimeButton(
          size: 50,
          onPressed: model.togglePlayPause,
          child: Icon(
            model.isRunning ? Icons.pause : Icons.play_arrow,
            color: Colors.black87,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        _RoundTimeButton(
          size: 38,
          onPressed: model.manualStep,
          child: const Icon(
            Icons.skip_next,
            color: Colors.black87,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        _RadioPair<bool>(
          a: false,
          b: true,
          aLabel: 'Normal',
          bLabel: 'Slow',
          value: model.slowMotion,
          onChanged: model.setSlowMotion,
        ),
      ],
    );
  }
}

class _RadioPair<T> extends StatelessWidget {
  const _RadioPair({
    required this.a,
    required this.b,
    required this.aLabel,
    required this.bLabel,
    required this.value,
    required this.onChanged,
  });
  final T a;
  final T b;
  final String aLabel;
  final String bLabel;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(T v, String label) {
      final selected = value == v;
      return InkWell(
        onTap: () => onChanged(v),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(16, 16),
              painter: _RadioDotPainter(selected: selected),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item(a, aLabel),
        const SizedBox(height: 4),
        item(b, bLabel),
      ],
    );
  }
}

class _RoundTimeButton extends StatelessWidget {
  const _RoundTimeButton({
    required this.size,
    required this.onPressed,
    required this.child,
  });

  final double size;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: const Color(0xFF6DCEF8),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RadioDotPainter extends CustomPainter {
  _RadioDotPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      6.5,
      Paint()
        ..color = const Color(0xFF333333)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (selected) {
      canvas.drawCircle(c, 3.8, Paint()..color = const Color(0xFF333333));
    }
  }

  @override
  bool shouldRepaint(covariant _RadioDotPainter old) => old.selected != selected;
}
