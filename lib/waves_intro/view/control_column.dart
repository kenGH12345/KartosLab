import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../waves_intro_constants.dart';
import '../widgets/waves_intro_toolbox.dart';

/// Right control column — PhET hierarchy:
/// Toolbox → Frequency/Amplitude → Visualization options → Audio.
///
/// Time / Viewpoint / Reset live in [WavesIntroBottomBar], not here.
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
        return SizedBox(
          width: WavesIntroConstants.controlColumnWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // —— Tools ——
                _Panel(
                  child: WavesIntroToolbox(model: model),
                ),
                const SizedBox(height: 8),
                // —— Wave parameters ——
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Frequency', style: _labelStyle(context)),
                      SliderTheme(
                        data: _sliderTheme(context),
                        child: Slider(
                          value: scene.controlFrequency,
                          min: config.frequencyMin,
                          max: config.frequencyMax,
                          onChanged: model.setFrequency,
                        ),
                      ),
                      if (config.kind == SceneKind.light)
                        const _FrequencySpectrumBar()
                      else
                        const _MinMaxRow(),
                      const SizedBox(height: 4),
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
                      const _ZeroMaxRow(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // —— Visualization options ——
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                const SizedBox(height: 8),
                // —— Audio ——
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: model.audioState.muted ? 'Unmute' : 'Mute',
                            onPressed: () =>
                                model.setMute(!model.audioState.muted),
                            icon: Icon(
                              model.audioState.muted
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              size: 18,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: model.audioState.masterVolume,
                              onChanged: model.audioState.muted
                                  ? null
                                  : model.setMasterVolume,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: model.audioState.visualMeterLevel,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE5E5E5),
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static TextStyle _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium ??
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

  static SliderThemeData _sliderTheme(BuildContext context) =>
      SliderTheme.of(context).copyWith(
        trackHeight: 3,
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

class _MinMaxRow extends StatelessWidget {
  const _MinMaxRow();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('min', style: TextStyle(fontSize: 10, color: Colors.black54)),
        Text('max', style: TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

class _ZeroMaxRow extends StatelessWidget {
  const _ZeroMaxRow();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('0', style: TextStyle(fontSize: 10, color: Colors.black54)),
        Text('max', style: TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

/// Visible spectrum track for light frequency — [视觉已对齐] to PhET FrequencyControl.
class _FrequencySpectrumBar extends StatelessWidget {
  const _FrequencySpectrumBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B00FF),
            Color(0xFF0000FF),
            Color(0xFF00FFFF),
            Color(0xFF00FF00),
            Color(0xFFFFFF00),
            Color(0xFFFF7F00),
            Color(0xFFFF0000),
          ],
        ),
      ),
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

/// Bottom bar: Viewpoint · Play/Pause/Step · Normal/Slow · Reset.
class WavesIntroBottomBar extends StatelessWidget {
  const WavesIntroBottomBar({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return SizedBox(
          height: WavesIntroConstants.bottomBarHeight,
          child: Row(
            children: [
              _RadioPair<Viewpoint>(
                a: Viewpoint.top,
                b: Viewpoint.side,
                aLabel: 'Top View',
                bLabel: 'Side View',
                value: model.viewpoint,
                onChanged: model.setViewpoint,
              ),
              const Spacer(),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
                onPressed: model.togglePlayPause,
                icon: Icon(
                  model.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: model.manualStep,
                icon: const Icon(Icons.skip_next),
              ),
              const SizedBox(width: 16),
              _RadioPair<bool>(
                a: false,
                b: true,
                aLabel: 'Normal',
                bLabel: 'Slow',
                value: model.slowMotion,
                onChanged: model.setSlowMotion,
              ),
              const Spacer(),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                ),
                onPressed: model.reset,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        );
      },
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
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected ? const Color(0xFF2196F3) : Colors.black45,
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(a, aLabel),
        const SizedBox(width: 10),
        item(b, bLabel),
      ],
    );
  }
}
