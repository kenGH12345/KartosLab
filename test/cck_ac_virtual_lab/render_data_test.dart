import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/cck_ac_virtual_lab/controller/cck_ac_controller.dart';
import 'package:kratos/cck_ac_virtual_lab/model/cck_vec.dart';
import 'package:kratos/cck_ac_virtual_lab/model/enums.dart';
import 'package:kratos/cck_ac_virtual_lab/render/cck_render_builder.dart';

void main() {
  test('render data copies brightness from model, not from painter', () {
    final c = CckAcController();
    c.spawn(CckElementKind.lightBulb, const CckVec(200, 200));
    final data = buildRenderData(c.circuit);
    expect(data.elements, hasLength(1));
    expect(data.elements.first.brightness, 0);
    expect(data.elements.first.kind, CckElementKind.lightBulb);
  });

  test('charges laid out after step on a loop', () {
    final c = CckAcController();
    final bat = c.spawn(CckElementKind.battery, const CckVec(100, 100));
    final res = c.spawn(CckElementKind.resistor, const CckVec(250, 100));
    c.circuit.connect(res!.start, bat!.end);
    final w1 = c.spawn(CckElementKind.wire, const CckVec(250, 180));
    c.circuit.connect(w1!.start, res.end);
    final w2 = c.spawn(CckElementKind.wire, const CckVec(100, 180));
    c.circuit.connect(w2!.start, w1.end);
    c.circuit.connect(w2.end, bat.start);
    c.circuit.step(1 / 60);
    expect(c.circuit.charges, isNotEmpty);
    final data = buildRenderData(c.circuit);
    expect(data.charges, isNotEmpty);
  });
}
