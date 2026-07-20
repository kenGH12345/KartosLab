import 'package:flutter/material.dart';

import '../models/optics_state.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLens = state.mode == SimMode.lens;
    return Material(
      color: const Color(0xFFE2F5FB),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 820;
            final content = [
              _RayModeControls(state: state, onChanged: onChanged),
              const _Divider(),
              _SliderControl(
                label: '曲率半径',
                value: state.radius,
                min: isLens ? 40 : 150,
                max: isLens ? 120 : 300,
                unit: '厘米',
                onChanged: (value) => onChanged(state.copyWith(radius: value)),
              ),
              if (isLens)
                _SliderControl(
                  label: '折射率',
                  value: state.refractiveIndex,
                  min: 1.2,
                  max: 1.8,
                  divisions: 60,
                  fractionDigits: 2,
                  onChanged: (value) =>
                      onChanged(state.copyWith(refractiveIndex: value)),
                ),
              _SliderControl(
                label: '直径',
                value: state.diameter,
                min: 60,
                max: 120,
                unit: '厘米',
                onChanged: (value) =>
                    onChanged(state.copyWith(diameter: value)),
              ),
              const _Divider(),
              _DisplayToggles(state: state, onChanged: onChanged),
            ];

            if (compact) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final child in content)
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: child,
                      ),
                  ],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 14, child: content[0]),
                content[1],
                Expanded(flex: 19, child: content[2]),
                if (isLens) Expanded(flex: 19, child: content[3]),
                Expanded(flex: 19, child: content[isLens ? 4 : 3]),
                content[isLens ? 5 : 4],
                Expanded(flex: 16, child: content[isLens ? 6 : 5]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RayModeControls extends StatelessWidget {
  const _RayModeControls({required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return _PanelColumn(
      title: '光线',
      children: [
        for (final mode in RayMode.values)
          RadioMenuButton<RayMode>(
            value: mode,
            groupValue: state.rayMode,
            onChanged: (value) => onChanged(state.copyWith(rayMode: value)),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(mode.label),
          ),
      ],
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '',
    this.divisions,
    this.fractionDigits = 0,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final int? divisions;
  final int fractionDigits;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveDivisions = divisions ?? (max - min).round();
    final display = '${value.toStringAsFixed(fractionDigits)}$unit';
    return _PanelColumn(
      title: label,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(
              icon: Icons.arrow_left_rounded,
              onPressed: () => onChanged((value - _step).clamp(min, max)),
            ),
            Container(
              width: 82,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
              child: Text(display, overflow: TextOverflow.ellipsis),
            ),
            _StepButton(
              icon: Icons.arrow_right_rounded,
              onPressed: () => onChanged((value + _step).clamp(min, max)),
            ),
          ],
        ),
        Slider(
          min: min,
          max: max,
          divisions: effectiveDivisions,
          value: value.clamp(min, max),
          onChanged: onChanged,
        ),
      ],
    );
  }

  double get _step => fractionDigits == 0 ? 1 : 0.01;
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _DisplayToggles extends StatelessWidget {
  const _DisplayToggles({required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return _PanelColumn(
      title: '显示',
      children: [
        CheckboxMenuButton(
          value: state.showFocalPoints,
          onChanged: (value) =>
              onChanged(state.copyWith(showFocalPoints: value)),
          child: const Text('焦点(F)'),
        ),
        CheckboxMenuButton(
          value: state.showVirtualImage,
          onChanged: (value) =>
              onChanged(state.copyWith(showVirtualImage: value)),
          child: const Text('虚像'),
        ),
        CheckboxMenuButton(
          value: state.showLabels,
          onChanged: (value) => onChanged(state.copyWith(showLabels: value)),
          child: const Text('标注'),
        ),
        CheckboxMenuButton(
          value: state.showSecondPoint,
          onChanged: (value) =>
              onChanged(state.copyWith(showSecondPoint: value)),
          child: const Text('第二个物点'),
        ),
      ],
    );
  }
}

class _PanelColumn extends StatelessWidget {
  const _PanelColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 112,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF86A6B5),
    );
  }
}
