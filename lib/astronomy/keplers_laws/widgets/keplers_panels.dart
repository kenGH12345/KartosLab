import 'package:flutter/material.dart';

import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_strings.dart';
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
          if (icon != null) ...[icon, const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      );
    }

    return KeplersPanel(
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: box(
                  value: v.stringChecked,
                  label: KeplersLawsStrings.string,
                  onChanged: (x) => v.stringChecked = x,
                ),
              ),
              box(
                value: v.axesVisible,
                label: KeplersLawsStrings.axes,
                onChanged: (x) => v.axesVisible = x,
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
              icon: const Icon(Icons.arrow_right_alt,
                  color: Color(0xFF00CC00), size: 16),
            ),
            box(
              value: v.gravityVisible,
              label: KeplersLawsStrings.gravityForce,
              onChanged: (x) => v.gravityVisible = x,
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
            ),
            box(
              value: v.measuringTapeVisible,
              label: KeplersLawsStrings.measuringTape,
              onChanged: (x) => v.measuringTapeVisible = x,
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
            ),
          ],
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
    return KeplersPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${KeplersLawsStrings.eccentricity} = c / a',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            e.eccentricityDisplay.toStringAsFixed(2),
            style: const TextStyle(color: Color(0xFFFF00FF), fontSize: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: FirstLawGraph(controller: controller),
          ),
          const SizedBox(height: 8),
          Text(
            'a = ${e.a.toStringAsFixed(2)} AU',
            style: const TextStyle(color: Color(0xFFFF9500), fontSize: 14),
          ),
          Text(
            'b = ${e.b.toStringAsFixed(2)} AU',
            style: const TextStyle(color: Color(0xFFB0EE86), fontSize: 14),
          ),
          Text(
            'c = ${e.c.toStringAsFixed(2)} AU',
            style: const TextStyle(color: Color(0xFFE6C7FF), fontSize: 14),
          ),
        ],
      ),
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
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => controller
                    .setPeriodDivisions(controller.periodDivisions - 1),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                '${controller.periodDivisions}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => controller
                    .setPeriodDivisions(controller.periodDivisions + 1),
                icon: const Icon(Icons.chevron_right, color: Colors.white),
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
