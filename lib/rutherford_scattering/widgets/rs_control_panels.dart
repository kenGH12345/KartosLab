import 'package:flutter/material.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/model/rutherford_atom_model.dart';
import 'package:kratos/rutherford_scattering/rs_assets.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_phet_slider.dart';

/// Shared dark panel chrome.
class RsPanel extends StatelessWidget {
  const RsPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RsLayout.panelWidth,
      decoration: BoxDecoration(
        color: RsColors.panel,
        border: Border.all(color: RsColors.panelBorder),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: RsConstants.panelXMargin,
        vertical: RsConstants.panelYMargin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: RsColors.panelTitle,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: RsConstants.panelChildSpacing),
          child,
        ],
      ),
    );
  }
}

class RsAlphaParticlePanel extends StatelessWidget {
  const RsAlphaParticlePanel({super.key, required this.controller});

  final RsSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final trackW = RsConstants.panelMinWidth * RsLayout.sliderTrackWidthFactor;

    return RsPanel(
      title: RsStrings.alphaParticleProperties,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            RsStrings.energy,
            style: TextStyle(
              color: RsColors.panelLabel,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: trackW + 48,
            child: Column(
              children: [
                RsPhetSlider(
                  width: trackW,
                  value: m.alphaParticleEnergy,
                  min: RsConstants.minAlphaEnergy,
                  max: RsConstants.maxAlphaEnergy,
                  thumbColor: RsLayout.energyThumb,
                  onChanged: controller.setAlphaParticleEnergy,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      RsStrings.minEnergy,
                      style: TextStyle(
                        color: RsColors.panelSliderLabel,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      RsStrings.maxEnergy,
                      style: TextStyle(
                        color: RsColors.panelSliderLabel,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: m.showTraces,
                  activeColor: RsColors.panelTitle,
                  side: const BorderSide(color: RsColors.panelLabel),
                  onChanged: (v) => controller.setShowTraces(v ?? false),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                RsStrings.showTraces,
                style: TextStyle(
                  color: RsColors.panelLabel,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RsAtomPropertiesPanel extends StatelessWidget {
  const RsAtomPropertiesPanel({super.key, required this.controller});

  final RsSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return RsPanel(
      title: RsStrings.atom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NucleonControl(
            label: RsStrings.protons,
            labelColor: RsColors.protonsLabel,
            value: m.protonCount,
            min: RsConstants.minProtonCount,
            max: RsConstants.maxProtonCount,
            thumbColor: RsLayout.protonsThumb,
            onChangeStart: () => controller.setUserInteraction(true),
            onChanged: controller.setProtonCount,
            onChangeEnd: () => controller.setUserInteraction(false),
          ),
          const SizedBox(height: RsConstants.panelChildSpacing * 2),
          _NucleonControl(
            label: RsStrings.neutrons,
            labelColor: RsColors.neutronsLabel,
            value: m.neutronCount,
            min: RsConstants.minNeutronCount,
            max: RsConstants.maxNeutronCount,
            thumbColor: RsLayout.neutronsThumb,
            onChangeStart: () => controller.setUserInteraction(true),
            onChanged: controller.setNeutronCount,
            onChangeEnd: () => controller.setUserInteraction(false),
          ),
        ],
      ),
    );
  }
}

/// NumberControl-like row: title + value display + PhET slider with ticks.
class _NucleonControl extends StatelessWidget {
  const _NucleonControl({
    required this.label,
    required this.labelColor,
    required this.value,
    required this.min,
    required this.max,
    required this.thumbColor,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final Color labelColor;
  final int value;
  final int min;
  final int max;
  final Color thumbColor;
  final VoidCallback onChangeStart;
  final ValueChanged<int> onChanged;
  final VoidCallback onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final trackW = RsConstants.panelMinWidth * RsLayout.sliderTrackWidthFactor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _NumberDisplay(value: value, color: labelColor),
            const SizedBox(width: 4),
            _StepButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            _StepButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
        const SizedBox(height: 3),
        RsPhetSlider(
          width: trackW,
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          thumbColor: thumbColor,
          centerLine: true,
          onChangeStart: (_) => onChangeStart(),
          onChanged: (v) => onChanged(v.round()),
          onChangeEnd: (_) => onChangeEnd(),
        ),
        SizedBox(
          width: trackW,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$min',
                style: const TextStyle(
                  color: RsColors.panelSliderLabel,
                  fontSize: 12,
                ),
              ),
              Text(
                '$max',
                style: const TextStyle(
                  color: RsColors.panelSliderLabel,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberDisplay extends StatelessWidget {
  const _NumberDisplay({required this.value, required this.color});
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: RsColors.panelLabel,
        disabledColor: RsColors.panelBorder,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

/// Left vertical Atomic / Nuclear scene buttons (PhET RectangularRadioButtonGroup).
class RsSceneRadio extends StatelessWidget {
  const RsSceneRadio({
    super.key,
    required this.scene,
    required this.onChanged,
  });

  final RutherfordScene scene;
  final ValueChanged<RutherfordScene> onChanged;

  @override
  Widget build(BuildContext context) {
    // Width matches foil (targetMaterialNode.width) in PhET.
    return SizedBox(
      width: RsLayout.foilW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SceneChoice(
            selected: scene == RutherfordScene.atom,
            onTap: () => onChanged(RutherfordScene.atom),
            child: Image.asset(
              RsAssets.atom,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: RsLayout.sceneSpacing),
          _SceneChoice(
            selected: scene == RutherfordScene.nucleus,
            onTap: () => onChanged(RutherfordScene.nucleus),
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _NucleusIconPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneChoice extends StatelessWidget {
  const _SceneChoice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: RsLayout.foilW,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: RsColors.panel,
          border: Border.all(
            color: selected
                ? RsColors.radioButtonBorder
                : RsColors.panelBorder,
            width: selected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _NucleusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const offsets = [
      Offset(-6, -5),
      Offset(6, -5),
      Offset(-6, 6),
      Offset(6, 6),
      Offset(0, 0),
      Offset(0, -8),
      Offset(0, 8),
    ];
    for (var i = 0; i < offsets.length; i++) {
      final proton = i.isEven;
      canvas.drawCircle(
        c + offsets[i],
        4.5,
        Paint()..color = proton ? RsColors.proton : RsColors.neutron,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RsTimeControls extends StatelessWidget {
  const RsTimeControls({super.key, required this.controller});

  final RsSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final running = controller.model.running;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          diameter: 46,
          color: RsColors.playButton,
          icon: running ? Icons.pause : Icons.play_arrow,
          onPressed: controller.toggleRunning,
        ),
        const SizedBox(width: 12),
        _RoundIconButton(
          diameter: 30,
          color: running ? RsColors.panelBorder : const Color(0xFF777777),
          icon: Icons.skip_next,
          onPressed: running ? null : controller.manualStep,
        ),
      ],
    );
  }
}

class RsLegendPanel extends StatelessWidget {
  const RsLegendPanel({super.key, required this.entries});

  final List<(Widget icon, String label)> entries;

  @override
  Widget build(BuildContext context) {
    return RsPanel(
      title: RsStrings.legend,
      child: Column(
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(width: 28, height: 18, child: Center(child: e.$1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.$2,
                      style: const TextStyle(
                        color: RsColors.panelLabel,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget nucleusDot() => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: RsColors.nucleus,
          shape: BoxShape.circle,
        ),
      );

  static Widget energyLevelIcon() => CustomPaint(
        size: const Size(22, 6),
        painter: _DashedLinePainter(),
      );

  static Widget traceArrow() => CustomPaint(
        size: const Size(22, 10),
        painter: _TraceArrowPainter(),
      );

  static Widget electronDot() => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: RsColors.electron,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 0.5),
        ),
      );

  static Widget protonDot() => Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: RsColors.proton,
          shape: BoxShape.circle,
        ),
      );

  static Widget neutronDot() => Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: RsColors.neutron,
          shape: BoxShape.circle,
        ),
      );

  static Widget alphaCluster() => SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(painter: _NucleusIconPainter()),
      );

  static Widget positiveChargeIcon() => Image.asset(
        RsAssets.plumPuddingIcon,
        width: 22,
        height: 18,
        fit: BoxFit.contain,
      );
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RsColors.energyLevel
      ..strokeWidth = 1.5;
    const dash = 4.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TraceArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RsColors.particleAlpha
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width - 6, y), paint);
    final path = Path()
      ..moveTo(size.width - 8, y - 4)
      ..lineTo(size.width, y)
      ..lineTo(size.width - 8, y + 4);
    canvas.drawPath(
      path,
      Paint()
        ..color = RsColors.particleAlpha
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.color,
    required this.icon,
    required this.onPressed,
    this.diameter = 40,
  });

  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Icon(icon, color: Colors.white, size: diameter * 0.5),
        ),
      ),
    );
  }
}
