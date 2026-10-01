import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/cck_ac_virtual_lab/solver/mna.dart';

void main() {
  test('PhET MNA battery 4V + resistor 2Ω', () {
    final battery = MnaBattery('0', '1', 4);
    final resistor = MnaResistor('1', '0', 2);
    final solution = MnaCircuit([battery], [resistor], []).solve();
    expect(solution.getNodeVoltage('0'), closeTo(0, 1e-6));
    expect(solution.getNodeVoltage('1'), closeTo(-4, 1e-6));
    expect(solution.getSolvedCurrent(battery), closeTo(2, 1e-6));
    expect(solution.getCurrentForResistor(resistor), closeTo(-2, 1e-6));
  });

  test('unconnected resistor does not disturb solved loop', () {
    final battery = MnaBattery('0', '1', 4);
    final r1 = MnaResistor('1', '0', 4);
    final r2 = MnaResistor('2', '3', 100);
    final solution = MnaCircuit([battery], [r1, r2], []).solve();
    expect(solution.getNodeVoltage('0'), closeTo(0, 1e-6));
    expect(solution.getNodeVoltage('1'), closeTo(-4, 1e-6));
    expect(solution.getSolvedCurrent(battery), closeTo(1, 1e-6));
    expect(solution.getNodeVoltage('2'), closeTo(0, 1e-6));
    expect(solution.getNodeVoltage('3'), closeTo(0, 1e-6));
  });
}