import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
import '../keplers_motion.dart';
import '../model/orbit_types.dart';
import '../model/target_orbit.dart';
import 'first_law_graph.dart';
import 'third_law_graph.dart';

class KeplersPanel extends StatelessWidget {
  const KeplersPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KeplersLawsColors.panelFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: KeplersLawsColors.panelStroke),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

class VisibilityPanel extends StatelessWidget {
  const VisibilityPanel({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    final v = controller.visible;
    Widget box({
      required bool value,
      required String label,
      required ValueChanged<bool> onChanged,
      Widget? icon,
    }) {
      return Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (x) {
                onChanged(x ?? false);
                controller.bump();
              },
              side: const BorderSide(color: Colors.white70),
              fillColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? const Color(0xFF60A9DD)
                    : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (icon != null) ...[const SizedBox(width: 4), icon],
        ],
      );
    }

    return KeplersPanel(
      child: AnimatedSize(
        duration: KeplersMotion.duration,
        curve: KeplersMotion.curve,
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.hasFirstLawFeatures ||
                controller.hasThirdLawFeatures) ...[
              Text(
                KeplersLawsStrings.targetOrbit,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              DropdownButton<TargetOrbit>(
                isExpanded: true,
                dropdownColor: KeplersLawsColors.panelFill,
                value: controller.targetOrbit,
                items: [
                  for (final o in TargetOrbit.comboItems)
                    DropdownMenuItem(
                      value: o,
                      child: Text(
                        o.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
                onChanged: (o) {
                  if (o != null) controller.setTargetOrbit(o);
                },
              ),
            ],
            if (controller.isFirstLaw ||
                (controller.isAllLaws && controller.isFirstLaw)) ...[
              box(
                value: v.fociVisible,
                label: KeplersLawsStrings.foci,
                onChanged: (x) => v.fociVisible = x,
                icon: const _FociLegendIcon(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: box(
                  value: v.stringChecked,
                  label: KeplersLawsStrings.string,
                  onChanged: (x) => v.stringChecked = x,
                  icon: const _DashedLineIcon(color: KeplersLawsColors.foci),
                ),
              ),
              box(
                value: v.axesVisible,
                label: KeplersLawsStrings.axes,
                onChanged: (x) => v.axesVisible = x,
                icon: const _AxisLegendIcon(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: box(
                  value: v.semiaxesChecked,
                  label: KeplersLawsStrings.semiaxes,
                  onChanged: (x) => v.semiaxesChecked = x,
                ),
              ),
              box(
                value: v.eccentricityVisible,
                label: KeplersLawsStrings.eccentricity,
                onChanged: (x) => v.eccentricityVisible = x,
                icon: const _EccLegendIcon(),
              ),
            ],
            if (controller.isSecondLaw) ...[
              box(
                value: v.apoapsisVisible,
                label: KeplersLawsStrings.apoapsis,
                onChanged: (x) => v.apoapsisVisible = x,
              ),
              box(
                value: v.periapsisVisible,
                label: KeplersLawsStrings.periapsis,
                onChanged: (x) => v.periapsisVisible = x,
              ),
            ],
            if (controller.isThirdLaw) ...[
              box(
                value: v.semiMajorAxisVisible,
                label: KeplersLawsStrings.semiMajorAxis,
                onChanged: (x) => v.semiMajorAxisVisible = x,
              ),
            box(
              value: v.periodVisible,
              label: KeplersLawsStrings.period,
              onChanged: (x) {
                v.periodVisible = x;
                if (!x) controller.periodTracker.timerReset();
              },
            ),
            ],
            const Divider(color: Color(0xFF8E9097), thickness: 2),
            box(
              value: controller.alwaysCircular,
              label: KeplersLawsStrings.alwaysCircular,
              onChanged: controller.setAlwaysCircular,
            ),
            box(
              value: v.speedVisible,
              label: KeplersLawsStrings.speed,
              onChanged: (x) => v.speedVisible = x,
            ),
            box(
              value: v.velocityVisible,
              label: KeplersLawsStrings.velocity,
              onChanged: (x) => v.velocityVisible = x,
              icon: const _VectorLegendIcon(color: KeplersLawsColors.velocity),
            ),
            box(
              value: v.gravityVisible,
              label: KeplersLawsStrings.gravityForce,
              onChanged: (x) => v.gravityVisible = x,
              icon: const _VectorLegendIcon(color: KeplersLawsColors.gravity),
            ),
            if (v.gravityVisible)
              SliderTheme(
                data: const SliderThemeData(
                  thumbColor: Color(0xFF3282D7),
                  activeTrackColor: Colors.white70,
                ),
                child: Slider(
                  min: -2,
                  max: 8,
                  divisions: 10,
                  value: controller.gravityForceScalePower.clamp(-2, 8),
                  onChanged: controller.setGravityScalePower,
                ),
              ),
            const Divider(color: Color(0xFF8E9097), thickness: 2),
            box(
              value: v.gridVisible,
              label: KeplersLawsStrings.grid,
              onChanged: (x) => v.gridVisible = x,
              icon: const _GridLegendIcon(),
            ),
            box(
              value: v.measuringTapeVisible,
              label: KeplersLawsStrings.measuringTape,
              onChanged: (x) => v.measuringTapeVisible = x,
              icon: const _TapeLegendIcon(),
            ),
            box(
              value: v.stopwatchVisible,
              label: KeplersLawsStrings.stopwatch,
              onChanged: (x) {
                v.stopwatchVisible = x;
                if (!x) {
                  controller.stopwatchRunning = false;
                  controller.stopwatchTime = 0;
                }
              },
              icon: const _StopwatchLegendIcon(),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class FirstLawSidePanel extends StatelessWidget {
  const FirstLawSidePanel({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isFirstLaw) return const SizedBox.shrink();
    final e = controller.engine;
    final show = controller.visible.eccentricityVisible;
    return AnimatedSize(
      duration: KeplersMotion.duration,
      curve: KeplersMotion.curve,
      alignment: Alignment.topLeft,
      child: show
          ? KeplersPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: [
                TextSpan(text: '${KeplersLawsStrings.eccentricity} = '),
                TextSpan(
                  text: 'c',
                  style: TextStyle(color: KeplersLawsColors.focalDistance),
                ),
                const TextSpan(text: ' / '),
                TextSpan(
                  text: 'a',
                  style: TextStyle(color: KeplersLawsColors.semiMajorAxis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FirstLawGraph(controller: controller),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: KeplersLawsColors.panelStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.3),
                    children: [
                      TextSpan(
                        text: 'a',
                        style: TextStyle(
                          color: KeplersLawsColors.semiMajorAxis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' = ${e.a.toStringAsFixed(2)} AU',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.3),
                    children: [
                      TextSpan(
                        text: 'c',
                        style: TextStyle(
                          color: KeplersLawsColors.focalDistance,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' = ${e.c.toStringAsFixed(2)} AU',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
          : const SizedBox(width: double.infinity),
    );
  }
}

class SecondLawSidePanel extends StatelessWidget {
  const SecondLawSidePanel({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isSecondLaw) return const SizedBox.shrink();
    final v = controller.visible;
    return KeplersPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            KeplersLawsStrings.periodDivision,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SpinnerButton(
                label: '−',
                onPressed: () => controller
                    .setPeriodDivisions(controller.periodDivisions - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${controller.periodDivisions}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              _SpinnerButton(
                label: '+',
                onPressed: () => controller
                    .setPeriodDivisions(controller.periodDivisions + 1),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: v.areaValuesVisible,
                onChanged: (x) {
                  v.areaValuesVisible = x ?? false;
                  controller.bump();
                },
                side: const BorderSide(color: Colors.white70),
              ),
              const Flexible(
                child: Text(
                  KeplersLawsStrings.areaValues,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: v.timeValuesVisible,
                onChanged: (x) {
                  v.timeValuesVisible = x ?? false;
                  controller.bump();
                },
                side: const BorderSide(color: Colors.white70),
              ),
              const Flexible(
                child: Text(
                  KeplersLawsStrings.timeValues,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThirdLawSidePanel extends StatelessWidget {
  const ThirdLawSidePanel({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isThirdLaw) return const SizedBox.shrink();
    final result = controller.thirdLawEquationResult;
    final ok = controller.correctPowersSelected;
    return KeplersPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result == null
                ? 'T / a = —'
                : 'T^${controller.selectedPeriodPower} / a^${controller.selectedAxisPower} = ${result.toStringAsFixed(2)}',
            style: TextStyle(
              color: ok ? const Color(0xFF7CFC00) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              for (final p in [1, 2, 3])
                OutlinedButton(
                  onPressed: () => controller.setPeriodPower(p),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: controller.selectedPeriodPower == p
                          ? const Color(0xFF60A9DD)
                          : Colors.white54,
                      width: controller.selectedPeriodPower == p ? 3 : 1,
                    ),
                  ),
                  child: Text(p == 1 ? 'T' : 'T$p'),
                ),
            ],
          ),
          Wrap(
            spacing: 4,
            children: [
              for (final p in [1, 2, 3])
                OutlinedButton(
                  onPressed: () => controller.setAxisPower(p),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: controller.selectedAxisPower == p
                          ? const Color(0xFF60A9DD)
                          : Colors.white54,
                      width: controller.selectedAxisPower == p ? 3 : 1,
                    ),
                  ),
                  child: Text(p == 1 ? 'a' : 'a$p'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            KeplersLawsStrings.starMass,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: KeplersLawsColors.sun,
              activeTrackColor: Colors.white70,
            ),
            child: Slider(
              min: 100,
              max: 400,
              value: controller.sun.mass.clamp(100, 400),
              onChangeStart: (_) => controller.beginUserMass(),
              onChanged: controller.setSunMass,
              onChangeEnd: (_) => controller.endUserMass(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '0.5        Our Sun        2.0',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ThirdLawGraph(controller: controller),
          ),
        ],
      ),
    );
  }
}

class OrbitalWarningBanner extends StatelessWidget {
  const OrbitalWarningBanner({super.key, required this.controller});

  final KeplersLawsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.engine.allowedOrbit) return const SizedBox.shrink();
    final msg = controller.engine.orbitType == OrbitType.crash
        ? KeplersLawsStrings.warningCrash
        : KeplersLawsStrings.warningEscape;
    return Text(
      msg,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SpinnerButton extends StatelessWidget {
  const _SpinnerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF5A5A5A),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _VectorLegendIcon extends StatelessWidget {
  const _VectorLegendIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 10),
      painter: _ArrowPainter(color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width - 5, size.height / 2),
      p,
    );
    final tip = Path()
      ..moveTo(size.width - 7, 1)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 7, size.height - 1)
      ..close();
    canvas.drawPath(tip, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FociLegendIcon extends StatelessWidget {
  const _FociLegendIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 12),
      painter: _FociPainter(),
    );
  }
}

class _FociPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KeplersLawsColors.foci
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    void xMark(Offset c) {
      canvas.drawLine(c + const Offset(-4, -4), c + const Offset(4, 4), paint);
      canvas.drawLine(c + const Offset(-4, 4), c + const Offset(4, -4), paint);
    }

    xMark(Offset(size.width * 0.28, size.height / 2));
    xMark(Offset(size.width * 0.72, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLineIcon extends StatelessWidget {
  const _DashedLineIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 8),
      painter: _DashedPainter(color),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6;
    const dash = 3.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset((x + dash).clamp(0, size.width), y), p);
      x += dash * 1.8;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AxisLegendIcon extends StatelessWidget {
  const _AxisLegendIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 12),
      painter: _AxisPainter(),
    );
  }
}

class _AxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final major = Paint()
      ..color = KeplersLawsColors.semiMajorAxis
      ..strokeWidth = 2;
    final minor = Paint()
      ..color = KeplersLawsColors.semiMinorAxis
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(1, size.height / 2),
      Offset(size.width - 1, size.height / 2),
      major,
    );
    canvas.drawLine(
      Offset(size.width / 2, 1),
      Offset(size.width / 2, size.height - 1),
      minor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridLegendIcon extends StatelessWidget {
  const _GridLegendIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(18, 14), painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final t = i / 2;
      canvas.drawLine(Offset(0, size.height * t), Offset(size.width, size.height * t), p);
      canvas.drawLine(Offset(size.width * t, 0), Offset(size.width * t, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TapeLegendIcon extends StatelessWidget {
  const _TapeLegendIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 16), painter: _TapeIconPainter());
  }
}

class _TapeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width * 0.62, size.height * 0.7),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFF5E000));
    canvas.drawCircle(
      Offset(size.width * 0.31, size.height * 0.5),
      size.height * 0.22,
      Paint()..color = const Color(0xFF4AA3E0),
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      Paint()
        ..color = const Color(0xFFCCCCCC)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StopwatchLegendIcon extends StatelessWidget {
  const _StopwatchLegendIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 16),
      painter: _StopwatchIconPainter(),
    );
  }
}

class _StopwatchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height * 0.2),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF5082E6));
    canvas.drawRRect(
      r.deflate(2),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EccLegendIcon extends StatelessWidget {
  const _EccLegendIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'e',
      style: TextStyle(
        color: KeplersLawsColors.orbit,
        fontSize: 14,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
