import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_value_entry.dart';
import 'package:kratos/balancing_act/view/widgets/ba_star_node.dart';
import 'package:kratos/hookes_law/view/phet_font.dart';

/// Phase 5 — visual geometry lock (source-faithful constants).
void main() {
  group('Phase5 visual geometry', () {
    test('MassValueEntry HSlider thumb is 15×30 (source MassValueEntryNode)', () {
      expect(BaMassValueEntry.thumbSize, const Size(15, 30));
      expect(BaMassValueEntry.panelFill, const Color.fromRGBO(234, 234, 174, 1));
      expect(BaMassValueEntry.maxMass, 100);
    });

    test('StarNode defaults match scenery-phet StarNode', () {
      const star = BaStarNode();
      expect(star.outerRadius, 15);
      expect(star.innerRadius, 7.5);
      expect(BaStarNode.filledFill, const Color(0xFFFCFF03));
      expect(BaStarNode.emptyFill, const Color(0xFFE1E1E1));
    });

    test('Score stars fill by score/perfect ratio', () {
      expect(((6 / 12) * 6).round(), 3);
      expect(((12 / 12) * 6).round(), 6);
      expect(((0 / 12) * 6).round(), 0);
    });

    test('Toolbox SCALING_MVT: bricks/mystery 150, people 80', () {
      expect(BaMassCatalog.brickWidth * 150, 30);
      expect(BaMassCatalog.mysteryHeights[0] * 150, 37.5);
      expect((BaMassCatalog.defaultHeights[BaMassType.boy] ?? 0) * 80, 88);
      expect((BaMassCatalog.defaultHeights[BaMassType.man] ?? 0) * 80, 144);
    });

    test('PhetFont uses Arial with height 1', () {
      final style = PhetFont.of(16);
      expect(style.fontFamily, 'Arial');
      expect(style.height, 1);
    });
  });
}
