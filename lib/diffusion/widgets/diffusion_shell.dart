import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diffusion_constants.dart';
import '../model/diffusion_model.dart';
import '../painters/diffusion_play_area_painter.dart';
import '../painters/particle_flow_rate_painter.dart';

/// Diffusion screen shell — layout mirrors DiffusionScreenView @ 7a52c48.
///
/// Controls: NumberSpinner (not Slider) — GasPropertiesSpinner / DiffusionSettingsNode.
/// Divider toggle lives in the right control panel.
/// Data accordion sits above the container (default collapsed).
class DiffusionShell extends StatelessWidget {
  const DiffusionShell({super.key, required this.model});

  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return ColoredBox(
          color: const Color(0xFF2C2C2C),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _DataAccordion(model: model),
                      const SizedBox(height: 8),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final aspect =
                                DiffusionConstants.containerWidthPm /
                                    DiffusionConstants.containerHeightPm;
                            var w = constraints.maxWidth;
                            var h = w / aspect;
                            if (h > constraints.maxHeight) {
                              h = constraints.maxHeight;
                              w = h * aspect;
                            }
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: w,
                                    height: h,
                                    child: CustomPaint(
                                      painter: DiffusionPlayAreaPainter(
                                          model: model),
                                    ),
                                  ),
                                ),
                                if (model.stopwatchVisible)
                                  Positioned(
                                    left: 8,
                                    top: 8,
                                    child: _StopwatchReadout(model: model),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (model.particleFlowRateVisible) ...[
                        const SizedBox(height: 12),
                        ParticleFlowRateVectors(
                          flowRate1: model.particleFlowRate1,
                          flowRate2: model.particleFlowRate2,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _TimeBar(model: model),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 280,
                  child: _ControlPanel(model: model),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// DataAccordionBox — above container; default collapsed.
class _DataAccordion extends StatelessWidget {
  const _DataAccordion({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    final l = model.leftData;
    final r = model.rightData;
    String t(double? v) => v == null ? 'T̄' : 'T̄ = ${v.toStringAsFixed(0)} K';

    return Material(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey('data-${model.dataExpanded}'),
          initiallyExpanded: model.dataExpanded,
          onExpansionChanged: model.setDataExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: const Text(
            'Data',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          collapsedIconColor: Colors.white70,
          iconColor: Colors.white70,
          children: [
            Row(
              children: [
                Expanded(
                  child: _DataSide(
                    n1: l.numberOfParticles1,
                    n2: l.numberOfParticles2,
                    tLabel: t(l.averageTemperatureK),
                  ),
                ),
                Container(
                  width: 2,
                  height: 48,
                  color: const Color(0xFFE0E0E0),
                ),
                Expanded(
                  child: _DataSide(
                    n1: r.numberOfParticles1,
                    n2: r.numberOfParticles2,
                    tLabel: t(r.averageTemperatureK),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSide extends StatelessWidget {
  const _DataSide({
    required this.n1,
    required this.n2,
    required this.tLabel,
  });

  final int n1;
  final int n2;
  final String tLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ParticleDot(color: Color(DiffusionConstants.particle1Color)),
              const SizedBox(width: 4),
              Text('$n1',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const _ParticleDot(color: Color(DiffusionConstants.particle2Color)),
              const SizedBox(width: 4),
              Text('$n2',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(tLabel,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ParticleDot extends StatelessWidget {
  const _ParticleDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// GasPropertiesStopwatchNode — 1 decimal + ps; driven by model.stopwatchPs.
class _StopwatchReadout extends StatelessWidget {
  const _StopwatchReadout({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0E0E0),
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          model.stopwatchDisplay,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontFeatures: [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TimeBar extends StatelessWidget {
  const _TimeBar({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          onPressed: model.togglePlayPause,
          icon: Icon(model.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        IconButton.filledTonal(
          onPressed: model.stepForward,
          icon: const Icon(Icons.skip_next),
        ),
        const SizedBox(width: 12),
        _SpeedToggle(model: model),
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
    );
  }
}

class _SpeedToggle extends StatelessWidget {
  const _SpeedToggle({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    Widget item(DiffusionTimeSpeed s, String label) {
      final sel = model.timeSpeed == s;
      return InkWell(
        onTap: () => model.setTimeSpeed(s),
        child: Row(
          children: [
            Icon(
              sel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: sel ? const Color(0xFF64B5F6) : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      );
    }

    return Row(
      children: [
        item(DiffusionTimeSpeed.normal, 'Normal'),
        const SizedBox(width: 10),
        item(DiffusionTimeSpeed.slow, 'Slow'),
      ],
    );
  }
}

/// DiffusionControlPanel — settings + divider toggle + checkboxes.
class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuantityControl(
              label: 'Number of Particles',
              leftValue: model.leftSettings.numberOfParticles,
              rightValue: model.rightSettings.numberOfParticles,
              min: DiffusionConstants.numberOfParticlesMin,
              max: DiffusionConstants.numberOfParticlesMax,
              delta: DiffusionConstants.numberOfParticlesDelta,
              enabled: model.settingsEnabled,
              onLeft: model.setLeftCount,
              onRight: model.setRightCount,
            ),
            const SizedBox(height: 14),
            _QuantityControl(
              label: 'Mass (AMU)',
              leftValue: model.leftSettings.mass,
              rightValue: model.rightSettings.mass,
              min: DiffusionConstants.massMin,
              max: DiffusionConstants.massMax,
              delta: DiffusionConstants.massDelta,
              enabled: model.settingsEnabled,
              onLeft: model.setLeftMass,
              onRight: model.setRightMass,
            ),
            const SizedBox(height: 14),
            _QuantityControl(
              label: 'Radius (pm)',
              leftValue: model.leftSettings.radius,
              rightValue: model.rightSettings.radius,
              min: DiffusionConstants.radiusMin,
              max: DiffusionConstants.radiusMax,
              delta: DiffusionConstants.radiusDelta,
              enabled: model.settingsEnabled,
              onLeft: model.setLeftRadius,
              onRight: model.setRightRadius,
            ),
            const SizedBox(height: 14),
            _QuantityControl(
              label: 'Initial Temperature (K)',
              leftValue: model.leftSettings.initialTemperature,
              rightValue: model.rightSettings.initialTemperature,
              min: DiffusionConstants.temperatureMin,
              max: DiffusionConstants.temperatureMax,
              delta: DiffusionConstants.temperatureDelta,
              enabled: model.settingsEnabled,
              onLeft: model.setLeftTemperature,
              onRight: model.setRightTemperature,
            ),
            const SizedBox(height: 16),
            _DividerToggleButton(model: model),
            const Divider(color: Colors.white24, height: 28),
            _ViewToggles(model: model),
          ],
        ),
      ),
    );
  }
}

/// QuantityControl — label + left spinner (cyan) + right spinner (red).
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.min,
    required this.max,
    required this.delta,
    required this.enabled,
    required this.onLeft,
    required this.onRight,
  });

  final String label;
  final int leftValue;
  final int rightValue;
  final int min;
  final int max;
  final int delta;
  final bool enabled;
  final ValueChanged<int> onLeft;
  final ValueChanged<int> onRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const _ParticleDot(color: Color(DiffusionConstants.particle1Color)),
            const SizedBox(width: 6),
            Expanded(
              child: _NumberSpinner(
                value: leftValue,
                min: min,
                max: max,
                delta: delta,
                enabled: enabled,
                onChanged: onLeft,
              ),
            ),
            const SizedBox(width: 16),
            const _ParticleDot(color: Color(DiffusionConstants.particle2Color)),
            const SizedBox(width: 6),
            Expanded(
              child: _NumberSpinner(
                value: rightValue,
                min: min,
                max: max,
                delta: delta,
                enabled: enabled,
                onChanged: onRight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// GasPropertiesSpinner / NumberSpinner — display + up/down; keyboard entry.
class _NumberSpinner extends StatefulWidget {
  const _NumberSpinner({
    required this.value,
    required this.min,
    required this.max,
    required this.delta,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final int delta;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberSpinner> createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<_NumberSpinner> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant _NumberSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.value != oldWidget.value) {
      _controller.text = '${widget.value}';
    }
  }

  void _onFocus() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null) {
      _controller.text = '${widget.value}';
      return;
    }
    final snapped = _snap(parsed);
    _controller.text = '$snapped';
    if (snapped != widget.value) widget.onChanged(snapped);
  }

  int _snap(int v) {
    final c = v.clamp(widget.min, widget.max);
    if (widget.delta <= 1) return c;
    return ((c - widget.min) / widget.delta).round() * widget.delta +
        widget.min;
  }

  void _nudge(int dir) {
    if (!widget.enabled) return;
    widget.onChanged(_snap(widget.value + dir * widget.delta));
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onSubmitted: (_) => _commit(),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: enabled ? () => _nudge(1) : null,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(6, 2, 6, 0),
                    child: Icon(Icons.arrow_drop_up,
                        size: 20, color: Colors.white70),
                  ),
                ),
                InkWell(
                  onTap: enabled ? () => _nudge(-1) : null,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(6, 0, 6, 2),
                    child: Icon(Icons.arrow_drop_down,
                        size: 20, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// DividerToggleButton — in control panel; disabled when N==0.
class _DividerToggleButton extends StatelessWidget {
  const _DividerToggleButton({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    final enabled = model.dividerToggleEnabled;
    return Center(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF666666),
          foregroundColor: Colors.black87,
          disabledForegroundColor: Colors.black45,
          disabledBackgroundColor: const Color(0xFF555555),
        ),
        onPressed: enabled ? model.toggleDivider : null,
        child: Text(
          model.container.hasDivider ? 'Remove Divider' : 'Reset Divider',
        ),
      ),
    );
  }
}

class _ViewToggles extends StatelessWidget {
  const _ViewToggles({required this.model});
  final DiffusionModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Center of Mass',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          value: model.centerOfMassVisible,
          onChanged: (v) => model.setCenterOfMassVisible(v ?? false),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          secondary: const _FlowRateIcon(),
          title: const Text('Particle Flow Rate',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          value: model.particleFlowRateVisible,
          onChanged: (v) => model.setParticleFlowRateVisible(v ?? false),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Scale',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          value: model.scaleVisible,
          onChanged: (v) => model.setScaleVisible(v ?? false),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Stopwatch',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          value: model.stopwatchVisible,
          onChanged: (v) => model.setStopwatchVisible(v ?? false),
        ),
      ],
    );
  }
}

class _FlowRateIcon extends StatelessWidget {
  const _FlowRateIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: CustomPaint(painter: _FlowRateIconPainter()),
    );
  }
}

class _FlowRateIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(DiffusionConstants.particle1Color)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    void arrow(double x0, double x1) {
      final midY = size.height / 2;
      final head = x1 > x0 ? 6.0 : -6.0;
      final path = Path()
        ..moveTo(x0, midY - 3)
        ..lineTo(x1 - head, midY - 3)
        ..lineTo(x1 - head, midY - 6)
        ..lineTo(x1, midY)
        ..lineTo(x1 - head, midY + 6)
        ..lineTo(x1 - head, midY + 3)
        ..lineTo(x0, midY + 3)
        ..close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, stroke);
    }

    arrow(18, 0);
    arrow(21, 45);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
