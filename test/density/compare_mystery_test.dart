import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/data/mystery_sets.dart';
import 'package:kratos/density/density_constants.dart';
import 'package:kratos/density/model/compare_state.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/mystery_state.dart';
import 'package:kratos/density/solver/density_relation.dart';

void main() {
  group('CompareConstraint', () {
    test('Same Mass locks 5 kg and volumes 0.01/0.005/0.0025/0.00125', () {
      final state = CompareState.initial();
      expect(state.blockSet, CompareBlockSet.sameMass);
      expect(state.lockedMass, 5);
      final blocks = state.visibleBlocks;
      expect(blocks, hasLength(4));
      expect(
        blocks.map((b) => b.volume).toList(),
        [0.01, 0.005, 0.0025, 0.00125],
      );
      expect(blocks.map((b) => b.tag).toList(), ['B', 'A', 'C', 'D']);
      for (final b in blocks) {
        expect(DensityRelation.massOf(b), closeTo(5, 1e-9));
      }
      expect(DensityRelation.densityOf(blocks[0]), closeTo(500, 1e-9));
      expect(DensityRelation.densityOf(blocks[1]), closeTo(1000, 1e-9));
      expect(DensityRelation.densityOf(blocks[2]), closeTo(2000, 1e-9));
      expect(DensityRelation.densityOf(blocks[3]), closeTo(4000, 1e-9));
    });

    test('Same Volume locks 0.005 m³ and masses 8/6/4/2', () {
      final blocks = CompareState.initial()
          .withBlockSet(CompareBlockSet.sameVolume)
          .visibleBlocks;
      expect(blocks.map((b) => b.tag).toList(), ['A', 'C', 'D', 'B']);
      for (final b in blocks) {
        expect(b.volume, closeTo(0.005, 1e-12));
      }
      expect(DensityRelation.massOf(blocks[0]), closeTo(8, 1e-9));
      expect(DensityRelation.massOf(blocks[1]), closeTo(6, 1e-9));
      expect(DensityRelation.massOf(blocks[2]), closeTo(4, 1e-9));
      expect(DensityRelation.massOf(blocks[3]), closeTo(2, 1e-9));
    });

    test('Same Density locks 500 with volumes 0.006/0.004/0.002/0.001', () {
      final state = CompareState.initial().withBlockSet(
        CompareBlockSet.sameDensity,
      );
      expect(state.lockedDensity, 500);
      final blocks = state.visibleBlocks;
      expect(blocks.map((b) => b.tag).toList(), ['B', 'A', 'C', 'D']);
      expect(
        blocks.map((b) => b.volume).toList(),
        [0.006, 0.004, 0.002, 0.001],
      );
      for (final b in blocks) {
        expect(DensityRelation.densityOf(b), 500);
      }
      expect(DensityRelation.massOf(blocks[0]), closeTo(3.0, 1e-9));
      expect(DensityRelation.massOf(blocks[1]), closeTo(2.0, 1e-9));
      expect(DensityRelation.massOf(blocks[2]), closeTo(1.0, 1e-9));
      expect(DensityRelation.massOf(blocks[3]), closeTo(0.5, 1e-9));
    });

    test('changing locked mass updates only Same Mass set densities', () {
      final before = CompareState.initial();
      final after = before.withLockedMass(10);
      expect(after.lockedMass, 10);
      for (final b in after.sameMassBlocks) {
        expect(DensityRelation.massOf(b), closeTo(10, 1e-9));
        expect(b.volume, before.sameMassBlocks[after.sameMassBlocks.indexOf(b)].volume);
      }
      expect(after.sameVolumeBlocks[0].volume, before.sameVolumeBlocks[0].volume);
      expect(
        DensityRelation.massOf(after.sameVolumeBlocks[0]),
        DensityRelation.massOf(before.sameVolumeBlocks[0]),
      );
    });

    test('switching mode keeps the other set until reset', () {
      final edited = CompareState.initial().withLockedMass(8);
      final switched = edited.withBlockSet(CompareBlockSet.sameVolume);
      expect(switched.blockSet, CompareBlockSet.sameVolume);
      expect(switched.sameMassBlocks, edited.sameMassBlocks);
      final reset = switched.reset();
      expect(reset.lockedMass, 5);
      expect(DensityRelation.massOf(reset.sameMassBlocks.first), closeTo(5, 1e-9));
    });

    test('same density range is 100–2000 not the 3000 base class default', () {
      final low = CompareState.initial().withLockedDensity(50);
      expect(low.lockedDensity, 100);
      final high = CompareState.initial().withLockedDensity(5000);
      expect(high.lockedDensity, 2000);
    });
  });

  group('MysterySets', () {
    test('Set 1 count volume density tags', () {
      final blocks = MysterySets.set1();
      expect(blocks, hasLength(5));
      expect(blocks.map((b) => b.tag).toList(), ['1D', '1B', '1E', '1C', '1A']);
      expect(blocks[0].volume, 0.005);
      expect(DensityRelation.densityOf(blocks[0]), 1000);
      expect(blocks[1].volume, 0.001);
      expect(DensityRelation.densityOf(blocks[1]), 400);
      expect(blocks[2].volume, 0.007);
      expect(DensityRelation.densityOf(blocks[2]), 400);
      expect(blocks[3].volume, 0.001);
      expect(DensityRelation.densityOf(blocks[3]), 19320);
      expect(blocks[4].volume, 0.0055);
      expect(DensityRelation.densityOf(blocks[4]), 3510);
    });

    test('Set 2 keeps 11340 not Lead catalog 11342', () {
      final blocks = MysterySets.set2();
      expect(blocks, hasLength(5));
      expect(DensityRelation.massOf(blocks[0]), closeTo(18, 1e-9));
      expect(DensityRelation.densityOf(blocks[0]), 4500);
      expect(DensityRelation.massOf(blocks[1]), closeTo(18, 1e-9));
      expect(DensityRelation.densityOf(blocks[1]), 11340);
      expect(DensityRelation.densityOf(blocks[1]), isNot(11342));
      expect(DensityMaterials.lead.density, 11342);
      expect(blocks[2].volume, 0.005);
      expect(DensityRelation.densityOf(blocks[2]), 8960);
      expect(DensityRelation.massOf(blocks[3]), closeTo(2.7, 1e-9));
      expect(DensityRelation.densityOf(blocks[3]), 2700);
      expect(DensityRelation.massOf(blocks[4]), closeTo(10.8, 1e-9));
      expect(DensityRelation.densityOf(blocks[4]), 2700);
    });

    test('Set 3 masses and densities', () {
      final blocks = MysterySets.set3();
      expect(blocks.map((b) => b.tag).toList(), ['3E', '3B', '3D', '3C', '3A']);
      expect(DensityRelation.massOf(blocks[0]), closeTo(6, 1e-9));
      expect(DensityRelation.densityOf(blocks[0]), 950);
      expect(DensityRelation.massOf(blocks[1]), closeTo(6, 1e-9));
      expect(DensityRelation.densityOf(blocks[1]), 1000);
      expect(DensityRelation.massOf(blocks[2]), closeTo(2, 1e-9));
      expect(DensityRelation.densityOf(blocks[2]), 400);
      expect(DensityRelation.massOf(blocks[3]), closeTo(23.4, 1e-9));
      expect(DensityRelation.densityOf(blocks[3]), 7800);
      expect(DensityRelation.massOf(blocks[4]), closeTo(2.85, 1e-9));
      expect(DensityRelation.densityOf(blocks[4]), 950);
    });

    test('Random: 5 blocks, volumes in 1–10 L, densities from table', () {
      final allowed = {
        for (final m in DensityMaterials.mysteryTableMaterials) m.density,
      };
      final blocks = MysterySets.randomSet(math.Random(42));
      expect(blocks, hasLength(5));
      expect(blocks.map((b) => b.tag).toList(), ['C', 'D', 'E', 'A', 'B']);
      for (final b in blocks) {
        expect(b.volume, inInclusiveRange(0.001, 0.01));
        expect(allowed.contains(DensityRelation.densityOf(b)), isTrue);
      }
      final liters = [
        for (final b in blocks)
          DensityConstants.litersFromCubicMeters(b.volume).round(),
      ];
      expect(liters, orderedEquals([...liters]..sort()));
      final small = liters.where((l) => l <= 6).length;
      final large = liters.where((l) => l >= 7).length;
      expect(small, 3);
      expect(large, 2);
    });

    test('Density Table 13 rows sorted kg/L 2 decimals', () {
      final rows = DensityTable.rows();
      expect(rows, hasLength(13));
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i].material.density! >= rows[i - 1].material.density!, isTrue);
      }
      expect(rows.first.material.id, DensityMaterialId.wood);
      expect(rows.first.kgPerLiterDisplay, '0.40');
      expect(rows.last.material.id, DensityMaterialId.gold);
      expect(rows.last.kgPerLiterDisplay, '19.32');
    });

    test('MysteryState defaults SET_1, table collapsed, mass labels off', () {
      final state = MysteryState.initial(random: math.Random(1));
      expect(state.blockSet, MysteryBlockSet.set1);
      expect(state.tableExpanded, isFalse);
      expect(state.massLabelsVisible, isFalse);
      expect(state.visibleBlocks.first.tag, '1D');
    });
  });
}
