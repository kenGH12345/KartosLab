import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/model/energy_graph_data.dart';
import 'package:kratos/hookes_law/model/energy_model.dart';
import 'package:kratos/hookes_law/model/hookes_law_numbers.dart';
import 'package:kratos/hookes_law/model/intro_model.dart';
import 'package:kratos/hookes_law/model/robotic_arm_drag.dart';
import 'package:kratos/hookes_law/model/systems_model.dart';

void main() {
  group('Spring relations', () {
    test('F = kx, spring force = -F, E = kx^2/2', () {
      final spring = IntroModel().system1.spring;
      // 50/200 = 1/4, which is exact in IEEE-754. 0.2 is not.
      spring.setAppliedForce(50);
      expect(spring.appliedForce, 50);
      expect(spring.displacement, 0.25);
      expect(spring.springForce, -50);
      expect(spring.potentialEnergy, 6.25);
    });

    test('negative displacement keeps energy non-negative', () {
      final spring = IntroModel().system1.spring;
      spring.setDisplacement(-0.25);
      expect(spring.appliedForce, -50);
      expect(spring.springForce, 50);
      expect(spring.potentialEnergy, 6.25);
    });

    test('x then F then the same x does not drift', () {
      final spring = IntroModel().system1.spring;
      spring.setDisplacement(1 / 3);
      final force = spring.appliedForce;
      final displacement = spring.displacement;
      expect(
        force,
        HookesLawNumbers.toFixedNumber(spring.springConstant * displacement, 10),
      );

      var forceWrites = 0;
      spring.appliedForceProperty.addListener((_) => forceWrites++);
      spring.setDisplacement(displacement);
      expect(forceWrites, 0);
      expect(spring.appliedForce, force);
      expect(spring.displacement, displacement);

      spring.setAppliedForce(force);
      expect(spring.appliedForce, force);
      expect(spring.displacement, displacement);
    });

    test('a fractional displacement settles within a few force writes', () {
      final spring = IntroModel().system1.spring;
      var forceWrites = 0;
      spring.appliedForceProperty.addListener((_) => forceWrites++);
      spring.setDisplacement(1 / 3);
      expect(forceWrites, inInclusiveRange(1, 6));
      final settled = spring.appliedForce;
      spring.setAppliedForce(settled);
      expect(spring.appliedForce, settled);
    });
  });

  group('ranges and clamp', () {
    test('Intro k and F ranges are inclusive, defaults are the reset values', () {
      final spring = IntroModel().system1.spring;
      expect(spring.springConstantRange.min, 100);
      expect(spring.springConstantRange.max, 1000);
      expect(spring.springConstantRange.defaultValue, 200);
      expect(spring.appliedForceRange.min, -100);
      expect(spring.appliedForceRange.max, 100);
      expect(spring.appliedForceRange.defaultValue, 0);
      // x = F/k at kMin, so the property range is wider than the default k allows.
      expect(spring.displacementRange.min, -1);
      expect(spring.displacementRange.max, 1);
      expect(spring.displacementRange.defaultValue, 0);
      expect(spring.maintainsAppliedForceWhenSpringConstantChanges, isTrue);

      spring.setSpringConstant(100);
      spring.setSpringConstant(1000);
      expect(spring.springConstant, 1000);
      spring.setAppliedForce(-100);
      spring.setAppliedForce(100);
      expect(spring.appliedForce, 100);
    });

    test('values outside range clamp, then F/x listeners run', () {
      final spring = IntroModel().system1.spring;
      spring.setAppliedForce(150);
      expect(spring.appliedForce, 100);
      expect(spring.displacement, 0.5);

      spring.setAppliedForce(-150);
      expect(spring.appliedForce, -100);
      expect(spring.displacement, -0.5);

      spring.setSpringConstant(50);
      expect(spring.springConstant, 100);
      spring.setSpringConstant(5000);
      expect(spring.springConstant, 1000);
    });

    test('Intro displacement past F/k is pulled back by the force clamp', () {
      final spring = IntroModel().system1.spring;
      // Property range allows ±1, but k = 200 cannot produce |F| > 100.
      spring.setDisplacement(5);
      expect(spring.appliedForce, 100);
      expect(spring.displacement, 0.5);
    });

    test('at k min, Intro can hold the full displacement range', () {
      final spring = IntroModel().system1.spring;
      spring.setSpringConstant(100);
      spring.setDisplacement(1);
      expect(spring.displacement, 1);
      expect(spring.appliedForce, 100);
      spring.setDisplacement(-1);
      expect(spring.displacement, -1);
      expect(spring.appliedForce, -100);
    });
  });

  group('changing k', () {
    test('Intro keeps F and recomputes x', () {
      final spring = IntroModel().system1.spring;
      spring.setAppliedForce(50);
      expect(spring.displacement, 0.25);
      spring.setSpringConstant(400);
      expect(spring.appliedForce, 50);
      expect(spring.displacement, 0.125);
      expect(spring.potentialEnergy, 3.125);
    });

    test('Energy keeps x and recomputes F', () {
      final energy = EnergyModel();
      final spring = energy.spring;
      expect(spring.maintainsAppliedForceWhenSpringConstantChanges, isFalse);
      expect(spring.displacementRange.min, -1);
      expect(spring.displacementRange.max, 1);
      expect(spring.appliedForceRange.min, -400);
      expect(spring.appliedForceRange.max, 400);

      spring.setDisplacement(0.5);
      expect(spring.appliedForce, 50);
      expect(spring.potentialEnergy, 12.5);
      spring.setSpringConstant(200);
      expect(spring.displacement, 0.5);
      expect(spring.appliedForce, 100);
      expect(spring.springForce, -100);
      expect(spring.potentialEnergy, 25);
    });

    test('Energy displacement endpoints are inclusive', () {
      final spring = EnergyModel().spring;
      spring.setDisplacement(-1);
      expect(spring.displacement, -1);
      expect(spring.appliedForce, -100);
      spring.setDisplacement(1);
      expect(spring.displacement, 1);
      expect(spring.appliedForce, 100);
      spring.setDisplacement(1.5);
      expect(spring.displacement, 1);
    });
  });

  group('Intro isolation', () {
    test('two systems do not share state', () {
      final intro = IntroModel();
      expect(identical(intro.system1, intro.system2), isFalse);
      expect(identical(intro.system1.spring, intro.system2.spring), isFalse);

      intro.system1.spring.setAppliedForce(25);
      intro.system1.spring.setSpringConstant(500);
      expect(intro.system2.spring.appliedForce, 0);
      expect(intro.system2.spring.springConstant, 200);
      expect(intro.system2.spring.displacement, 0);
      expect(intro.system2.spring.potentialEnergy, 0);
    });

    test('reset restores both systems', () {
      final intro = IntroModel();
      intro.system1.spring.setAppliedForce(10);
      intro.system2.spring.setSpringConstant(800);
      intro.reset();
      expect(intro.system1.spring.appliedForce, 0);
      expect(intro.system1.spring.springConstant, 200);
      expect(intro.system1.spring.displacement, 0);
      expect(intro.system2.spring.appliedForce, 0);
      expect(intro.system2.spring.springConstant, 200);
      expect(intro.system2.spring.displacement, 0);
    });

    test('a fixed left end cannot move', () {
      final spring = IntroModel().system1.spring;
      expect(() => spring.leftProperty.value = 1, throwsStateError);
    });
  });

  group('Systems', () {
    test('series: equal forces and harmonic k', () {
      final series = SystemsModel().seriesSystem;
      expect(series.equivalentSpring.springConstant, 100);
      expect(series.leftSpring.equilibriumLength, 0.75);
      expect(series.equivalentSpring.equilibriumLength, 1.5);

      series.equivalentSpring.setAppliedForce(50);
      expect(series.leftSpring.appliedForce, 50);
      expect(series.rightSpring.appliedForce, 50);
      expect(series.leftSpring.displacement, 0.25);
      expect(series.rightSpring.displacement, 0.25);
      expect(
        series.leftSpring.displacement + series.rightSpring.displacement,
        series.equivalentSpring.displacement,
      );
      expect(series.equivalentSpring.springForce, -50);
      expect(series.leftSpring.springForce, -50);
      expect(series.rightSpring.springForce, -50);

      series.leftSpring.setSpringConstant(400);
      expect(
        series.equivalentSpring.springConstant,
        1 / ((1 / 400) + (1 / 200)),
      );
      expect(series.leftSpring.appliedForce, series.equivalentSpring.appliedForce);
      expect(series.rightSpring.appliedForce, series.equivalentSpring.appliedForce);
    });

    test('series x1 + x2 stays within one rounding ulp of xeq', () {
      final series = SystemsModel().seriesSystem;
      // 20 N is not a dyadic fraction of k, so F/k is not a binary-exact metre.
      series.equivalentSpring.setAppliedForce(20);
      final sum =
          series.leftSpring.displacement + series.rightSpring.displacement;
      final gap = (sum - series.equivalentSpring.displacement).abs();
      // Source rounds F to 10 decimals, then sets x = F/k. The leftover is
      // about 1 ulp. 1e-12 m is still far below the 0.001 m display quantum.
      expect(gap, lessThan(1e-12));
      expect(series.leftSpring.appliedForce, series.equivalentSpring.appliedForce);
      expect(series.rightSpring.appliedForce, series.equivalentSpring.appliedForce);
    });

    test('parallel: equal displacement and summed k', () {
      final parallel = SystemsModel().parallelSystem;
      expect(parallel.equivalentSpring.springConstant, 400);
      expect(parallel.topSpring.equilibriumLength, 1.5);

      parallel.equivalentSpring.setDisplacement(0.25);
      expect(parallel.topSpring.displacement, 0.25);
      expect(parallel.bottomSpring.displacement, 0.25);
      expect(parallel.equivalentSpring.appliedForce, 100);
      expect(parallel.topSpring.appliedForce, 50);
      expect(parallel.bottomSpring.appliedForce, 50);
      expect(
        parallel.topSpring.appliedForce + parallel.bottomSpring.appliedForce,
        parallel.equivalentSpring.appliedForce,
      );
      expect(parallel.topSpring.springForce, -50);
      expect(parallel.bottomSpring.springForce, -50);
      expect(parallel.equivalentSpring.springForce, -100);
      expect(
        parallel.topSpring.potentialEnergy + parallel.bottomSpring.potentialEnergy,
        parallel.equivalentSpring.potentialEnergy,
      );

      parallel.bottomSpring.setSpringConstant(500);
      expect(parallel.equivalentSpring.springConstant, 200 + 500);
      expect(parallel.topSpring.displacement, parallel.bottomSpring.displacement);
      expect(
        parallel.topSpring.displacement,
        parallel.equivalentSpring.displacement,
      );
    });

    test('component forces stay available while the equivalent force exists', () {
      final systems = SystemsModel();
      systems.parallelSystem.equivalentSpring.setAppliedForce(40);
      expect(systems.parallelSystem.topSpring.springForce, isNonZero);
      expect(systems.parallelSystem.bottomSpring.springForce, isNonZero);
      expect(systems.parallelSystem.equivalentSpring.springForce, isNonZero);
      // No display-mode flag: both representations are just these properties.
      expect(
        systems.parallelSystem.topSpring.appliedForce,
        isNot(systems.parallelSystem.equivalentSpring.appliedForce),
      );
    });

    test('series and parallel do not share springs', () {
      final systems = SystemsModel();
      systems.parallelSystem.topSpring.setSpringConstant(600);
      systems.seriesSystem.equivalentSpring.setAppliedForce(-30);
      expect(systems.seriesSystem.leftSpring.springConstant, 200);
      expect(systems.parallelSystem.equivalentSpring.appliedForce, 0);
    });

    test('reset restores the system that is not the default view', () {
      final systems = SystemsModel();
      // Default view is parallel. Series is the hidden one.
      systems.seriesSystem.leftSpring.setSpringConstant(600);
      systems.seriesSystem.equivalentSpring.setAppliedForce(15);
      systems.parallelSystem.bottomSpring.setSpringConstant(450);
      systems.parallelSystem.equivalentSpring.setDisplacement(0.05);

      systems.reset();

      expect(systems.seriesSystem.leftSpring.springConstant, 200);
      expect(systems.seriesSystem.rightSpring.springConstant, 200);
      expect(systems.seriesSystem.equivalentSpring.springConstant, 100);
      expect(systems.seriesSystem.equivalentSpring.appliedForce, 0);
      expect(systems.seriesSystem.equivalentSpring.displacement, 0);
      expect(systems.seriesSystem.leftSpring.displacement, 0);
      expect(systems.parallelSystem.topSpring.springConstant, 200);
      expect(systems.parallelSystem.bottomSpring.springConstant, 200);
      expect(systems.parallelSystem.equivalentSpring.springConstant, 400);
      expect(systems.parallelSystem.equivalentSpring.displacement, 0);
      expect(systems.parallelSystem.equivalentSpring.appliedForce, 0);
    });
  });

  group('screens do not share models', () {
    test('mutating one screen leaves the others at defaults', () {
      final intro = IntroModel();
      final systems = SystemsModel();
      final energy = EnergyModel();

      intro.system1.spring.setAppliedForce(50);
      systems.parallelSystem.topSpring.setSpringConstant(300);
      energy.spring.setDisplacement(0.5);

      expect(energy.spring.displacement, 0.5);
      expect(intro.system1.spring.displacement, 0.25);
      expect(systems.seriesSystem.equivalentSpring.appliedForce, 0);
      expect(systems.parallelSystem.equivalentSpring.displacement, 0);

      intro.reset();
      expect(intro.system1.spring.appliedForce, 0);
      expect(energy.spring.displacement, 0.5);
      expect(systems.parallelSystem.topSpring.springConstant, 300);
    });
  });

  group('robotic arm drag', () {
    test('0.01 m snap is applied before the arm moves, not inside setDisplacement', () {
      final system = IntroModel().system1;
      final proposed = system.spring.equilibriumX + 0.237;
      applyRoboticArmPointerLeft(
        arm: system.roboticArm,
        springRightRange: system.spring.rightRange,
        proposedLeft: proposed,
      );
      final snapped = HookesLawNumbers.roundToInterval(
        proposed,
        HookesLawConstants.roboticArmDisplacementInterval,
      );
      expect(system.roboticArm.left, snapped);
      expect(system.spring.displacement, snapped - system.spring.equilibriumX);
      expect(
        system.spring.appliedForce,
        HookesLawNumbers.toFixedNumber(
          system.spring.springConstant * system.spring.displacement,
          10,
        ),
      );
    });

    test('drag past the right-end range clamps before snapping', () {
      final system = IntroModel().system1;
      final range = system.spring.rightRange;
      applyRoboticArmPointerLeft(
        arm: system.roboticArm,
        springRightRange: range,
        proposedLeft: range.max + 2,
      );
      final snapped = HookesLawNumbers.roundToInterval(
        range.max,
        HookesLawConstants.roboticArmDisplacementInterval,
      );
      expect(system.roboticArm.left, snapped);
    });

    test('state does not move again after the drag write', () {
      final spring = IntroModel().system1.spring;
      spring.setDisplacement(0.2);
      final x = spring.displacement;
      final force = spring.appliedForce;
      final energy = spring.potentialEnergy;
      expect(spring.displacement, x);
      expect(spring.appliedForce, force);
      expect(spring.potentialEnergy, energy);
    });
  });

  group('interaction steps from source', () {
    test('slider, arrow, and keyboard intervals', () {
      expect(HookesLawConstants.appliedForceArrowInterval, 1);
      expect(HookesLawConstants.appliedForceSliderInterval, 5);
      expect(HookesLawConstants.appliedForceKeyboardStep, 10);
      expect(HookesLawConstants.appliedForcePageKeyboardStep, 25);
      expect(HookesLawConstants.springConstantArrowInterval, 1);
      expect(HookesLawConstants.springConstantSliderInterval, 10);
      expect(HookesLawConstants.springConstantKeyboardStep, 20);
      expect(HookesLawConstants.springConstantPageKeyboardStep, 100);
      expect(HookesLawConstants.displacementArrowInterval, 0.01);
      expect(HookesLawConstants.displacementSliderInterval, 0.05);
      expect(HookesLawConstants.displacementKeyboardStep, 0.10);
      expect(HookesLawConstants.displacementPageKeyboardStep, 0.20);
      expect(HookesLawConstants.roboticArmDisplacementInterval, 0.01);
    });
  });

  group('energy graph data', () {
    test('bar, parabola controls, and force-plot triangle', () {
      final spring = EnergyModel().spring;
      final restingBar = EnergyGraphData.energyBar(spring);
      expect(restingBar.visible, isFalse);
      expect(restingBar.energy, 0);

      spring.setDisplacement(1);
      spring.setSpringConstant(100);
      expect(spring.displacement, 1);
      expect(spring.appliedForce, 100);
      expect(spring.potentialEnergy, 50);

      final bar = EnergyGraphData.energyBar(spring);
      expect(bar.visible, isTrue);
      expect(bar.height, 50 * 1.1);

      final curve = EnergyGraphData.energyPlotBezier(spring);
      expect(curve.d1, 1);
      expect(curve.d2, 0.5);
      expect(curve.e1, 50);
      expect(curve.e2, 12.5);
      expect(curve.e3, 0);
      expect(curve.x1, 225);
      expect(curve.x2, 112.5);
      expect(curve.y1, -HookesLawConstants.unitEnergyY * curve.e1);
      expect(curve.y2, -HookesLawConstants.unitEnergyY * curve.e2);
      expect(curve.cpx, 112.5);
      expect(curve.cpy, 0);
      expect(curve.viewMinX, 225 * 1.1 * -1);
      expect(curve.viewMaxX, 225 * 1.1);
      expect(curve.viewMaxY, 250);

      final line = EnergyGraphData.forcePlotLine(spring);
      expect(line.x0, 225 * -1);
      expect(line.x1, 225);
      expect(line.y0, -0.25 * 100 * -1);
      expect(line.y1, -0.25 * 100 * 1);
      expect(line.viewMinY, -125);
      expect(line.viewMaxY, 125);

      final triangle = EnergyGraphData.forcePlotEnergyTriangle(spring);
      expect(triangle.visible, isTrue);
      expect(triangle.x, 225);
      expect(triangle.y, -100 * 0.25);

      spring.setDisplacement(0.0004);
      expect(
        EnergyGraphData.forcePlotEnergyTriangle(spring).visible,
        isFalse,
      );
    });

    test('energyAt and forceAt do not mutate the spring', () {
      final spring = EnergyModel().spring;
      spring.setDisplacement(0.25);
      expect(EnergyGraphData.energyAt(spring, 1), 50);
      expect(EnergyGraphData.forceAt(spring, 1), 100);
      expect(spring.displacement, 0.25);
    });
  });
}
