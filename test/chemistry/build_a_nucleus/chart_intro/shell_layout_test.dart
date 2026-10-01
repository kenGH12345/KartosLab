import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/energy_level.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/shell_layout.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

void main() {
  group('MVT', () {
    test('viewX = x * 30，viewY = 200 - y * 100', () {
      expect(ShellLayout.viewWidth, 150);
      expect(ShellLayout.viewHeight, 200);
      expect(ShellLayout.unboundCenter(0, 0), const Offset(0, 200));
      expect(ShellLayout.unboundCenter(5, 0), const Offset(150, 200));
      expect(ShellLayout.unboundCenter(0, 2), const Offset(0, 0));
      expect(ShellLayout.unboundCenter(2, 0), const Offset(60, 200));
      expect(ShellLayout.unboundCenter(3, 0), const Offset(90, 200));
    });

    test('更高能级在屏幕上方（Y 更小）', () {
      expect(
        ShellLayout.unboundCenter(0, 2).dy <
            ShellLayout.unboundCenter(0, 1).dy,
        isTrue,
      );
      expect(
        ShellLayout.unboundCenter(0, 1).dy <
            ShellLayout.unboundCenter(0, 0).dy,
        isTrue,
      );
    });
  });

  group('能级线', () {
    test('三层都有线，空层也在', () {
      for (final level in EnergyLevel.levels) {
        final line = ShellLayout.energyLine(level);
        expect(line.$1.dy, line.$2.dy);
        expect(line.$2.dx > line.$1.dx, isTrue);
      }
    });

    test('n0 线从 x=2 座左缘到 x=3 座右缘', () {
      final line = ShellLayout.energyLine(EnergyLevel.n0);
      expect(line.$1.dx, 60 - ChartIntroVisuals.nucleonRadius);
      expect(line.$2.dx, 90 + ChartIntroVisuals.nucleonRadius);
      expect(line.$1.dy, 200 + ChartIntroVisuals.nucleonRadius);
    });

    test('线在核子下方一个半径', () {
      final line = ShellLayout.energyLine(EnergyLevel.n1);
      expect(
        line.$1.dy,
        ShellLayout.unboundCenter(0, 1).dy + ChartIntroVisuals.nucleonRadius,
      );
    });
  });

  group('occupancy / 描边', () {
    test('空核：三层 occupancy 0，线宽 1，黑色', () {
      for (final level in EnergyLevel.levels) {
        expect(ShellLayout.occupancy(level, 0), 0);
        expect(ShellLayout.energyStrokeWidth(level, 0), 1);
        expect(
          ShellLayout.energyStroke(
            type: NucleonType.proton,
            level: level,
            count: 0,
          ),
          ChartIntroVisuals.emptyEnergyLevel,
        );
      }
    });

    test('2 个：n0 满层加粗，n1/n2 仍空', () {
      expect(ShellLayout.occupancy(EnergyLevel.n0, 2), 2);
      expect(ShellLayout.occupancy(EnergyLevel.n1, 2), 0);
      expect(ShellLayout.energyStrokeWidth(EnergyLevel.n0, 2), 4);
      expect(ShellLayout.energyStrokeWidth(EnergyLevel.n1, 2), 1);
    });

    test('3 个：n0 仍满，n1 occupancy 1', () {
      expect(ShellLayout.occupancy(EnergyLevel.n0, 3), 2);
      expect(ShellLayout.occupancy(EnergyLevel.n1, 3), 1);
      expect(ShellLayout.occupancy(EnergyLevel.n2, 3), 0);
    });

    test('质子满层色 = 质子橙', () {
      expect(
        ShellLayout.energyStroke(
          type: NucleonType.proton,
          level: EnergyLevel.n0,
          count: 2,
        ),
        ChartIntroVisuals.proton,
      );
    });
  });

  group('绑定位置', () {
    test('未绑定用座位中心', () {
      final c = ShellLayout.nucleonCenter(
        index: 0,
        xPosition: 2,
        yPosition: 0,
        bound: false,
      );
      expect(c, const Offset(60, 200));
    });

    test('n0 绑定后向层中心靠拢', () {
      final a = ShellLayout.boundCenter(
        index: 0,
        yPosition: 0,
        xPosition: 2,
      );
      final b = ShellLayout.boundCenter(
        index: 1,
        yPosition: 0,
        xPosition: 3,
      );
      expect(a.dy, 200);
      expect(b.dy, 200);
      expect(a.dx, closeTo(65, 0.01));
      expect(b.dx, closeTo(90 - 150 / 17 + 5, 0.01));
      expect(a.dx < b.dx, isTrue);
      expect((b.dx - a.dx) < 30, isTrue);
    });

    test('n2 不走绑定公式（调用方 bound=false）', () {
      final c = ShellLayout.nucleonCenter(
        index: 8,
        xPosition: 0,
        yPosition: 2,
        bound: false,
      );
      expect(c, const Offset(0, 0));
    });
  });
}
