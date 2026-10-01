
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_z_order.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

void main() {
  group('EfacIntroZOrder (EFACIntroScreenView.ts)', () {
    test('block completely to the right is in front', () {
      const left = ModelRect(0, 0, 1, 1);
      const right = ModelRect(2, 0, 3, 1);
      expect(EfacIntroZOrder.compareBlocks(right, left), greaterThan(0));
      expect(EfacIntroZOrder.compareBlocks(left, right), lessThan(0));
    });

    test('overlapping X: higher minY is in front', () {
      const lower = ModelRect(0, 0, 1, 1);
      const upper = ModelRect(0.2, 0.5, 1.2, 1.5);
      expect(EfacIntroZOrder.compareBlocks(upper, lower), greaterThan(0));
    });

    test('applyBlockZIndices assigns increasing front order', () {
      final iron = ThermalBlock(
        id: 'iron',
        blockType: BlockType.iron,
        position: const Offset(0, 0),
      );
      final brick = ThermalBlock(
        id: 'brick',
        blockType: BlockType.brick,
        position: const Offset(0.1, 0),
      );
      EfacIntroZOrder.applyBlockZIndices([iron, brick]);
      // brick is to the right → higher zIndex
      expect(brick.zIndex, greaterThan(iron.zIndex));
    });

    test('raised block over another gets higher zIndex', () {
      final base = ThermalBlock(
        id: 'iron',
        blockType: BlockType.iron,
        position: const Offset(0, 0),
      );
      final onTop = ThermalBlock(
        id: 'brick',
        blockType: BlockType.brick,
        position: const Offset(0, 0.05),
      );
      EfacIntroZOrder.applyBlockZIndices([base, onTop]);
      expect(onTop.zIndex, greaterThan(base.zIndex));
    });

    test('beakersBackToFront: higher centerY last (in front)', () {
      final low = Beaker(
        id: 'water',
        beakerType: BeakerType.water,
        position: const Offset(0, 0),
      );
      final high = Beaker(
        id: 'oliveOil',
        beakerType: BeakerType.oliveOil,
        position: const Offset(0.2, 0.05),
      );
      final ordered = EfacIntroZOrder.beakersBackToFront([high, low]);
      expect(ordered.first, same(low));
      expect(ordered.last, same(high));
    });

    test('model moveBlock refreshes zIndex', () {
      final m = EfacIntroModel();
      final iron = m.blocks.firstWhere((b) => b.id == 'iron');
      final brick = m.blocks.firstWhere((b) => b.id == 'brick');
      // Place iron to the right of brick.
      m.moveBlock(iron, Offset(brick.position.dx + 0.1, 0));
      expect(iron.zIndex, greaterThan(brick.zIndex));
    });
  });
}
