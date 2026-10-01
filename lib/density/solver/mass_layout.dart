import '../model/density_block.dart';
import '../model/density_vec.dart';
import '../render/density_mvt.dart';
import 'density_relation.dart';

/// `DensityBuoyancyModel.positionMasses*` / `positionStack*`.
class MassLayout {
  MassLayout._();

  static const spacing = 0.01;

  static List<DensityBlock> positionLeft(List<DensityBlock> masses) {
    var cursor = DensityMvt.poolMinX;
    final out = <DensityBlock>[];
    for (final mass in masses) {
      final side = DensityRelation.cubeSideLength(mass.volume);
      final x = cursor - spacing - side / 2;
      cursor -= spacing + side;
      out.add(
        mass.copyWith(
          position: DensityVec(x, side / 2),
          velocity: DensityVec.zero,
        ),
      );
    }
    return out;
  }

  static List<DensityBlock> positionRight(List<DensityBlock> masses) {
    var cursor = DensityMvt.poolMaxX;
    final out = <DensityBlock>[];
    for (final mass in masses) {
      final side = DensityRelation.cubeSideLength(mass.volume);
      final x = cursor + spacing + side / 2;
      cursor += spacing + side;
      out.add(
        mass.copyWith(
          position: DensityVec(x, side / 2),
          velocity: DensityVec.zero,
        ),
      );
    }
    return out;
  }

  /// Stacks largest-volume first at the bottom (`positionStack`).
  static List<DensityBlock> positionStack(List<DensityBlock> masses, double x) {
    final sorted = [...masses]..sort((a, b) => b.volume.compareTo(a.volume));
    var y = 0.0;
    final placed = <String, DensityBlock>{};
    for (final mass in sorted) {
      final side = DensityRelation.cubeSideLength(mass.volume);
      placed[mass.id] = mass.copyWith(
        position: DensityVec(x, y + side / 2),
        velocity: DensityVec.zero,
      );
      y += side;
    }
    return [for (final m in masses) placed[m.id]!];
  }

  static List<DensityBlock> positionStackLeft(List<DensityBlock> masses) {
    final maxSide = masses
        .map((m) => DensityRelation.cubeSideLength(m.volume))
        .fold<double>(0, (a, b) => a > b ? a : b);
    return positionStack(masses, DensityMvt.poolMinX - spacing - maxSide / 2);
  }

  static List<DensityBlock> positionStackRight(List<DensityBlock> masses) {
    final maxSide = masses
        .map((m) => DensityRelation.cubeSideLength(m.volume))
        .fold<double>(0, (a, b) => a > b ? a : b);
    return positionStack(masses, DensityMvt.poolMaxX + spacing + maxSide / 2);
  }

  static List<DensityBlock> comparePositions(
    CompareBlockSet set,
    List<DensityBlock> blocks,
  ) {
    final result = List<DensityBlock>.from(blocks);
    void write(List<int> indices, List<DensityBlock> laid) {
      for (var i = 0; i < indices.length; i++) {
        result[indices[i]] = laid[i];
      }
    }

    switch (set) {
      case CompareBlockSet.sameMass:
      case CompareBlockSet.sameDensity:
        write([0, 1], positionLeft([blocks[0], blocks[1]]));
        write([2, 3], positionRight([blocks[2], blocks[3]]));
        return result;
      case CompareBlockSet.sameVolume:
        write([3, 0], positionLeft([blocks[3], blocks[0]]));
        write([1, 2], positionRight([blocks[1], blocks[2]]));
        return result;
    }
  }

  static List<DensityBlock> mysteryPositions(
    MysteryBlockSet set,
    List<DensityBlock> blocks,
  ) {
    final result = List<DensityBlock>.from(blocks);
    void write(List<int> indices, List<DensityBlock> laid) {
      for (var i = 0; i < indices.length; i++) {
        result[indices[i]] = laid[i];
      }
    }

    if (set == MysteryBlockSet.random) {
      write([3, 4], positionStackLeft([blocks[3], blocks[4]]));
      write([0, 1, 2], positionStackRight([blocks[0], blocks[1], blocks[2]]));
    } else {
      write([1, 4], positionStackLeft([blocks[1], blocks[4]]));
      write([2, 3, 0], positionStackRight([blocks[2], blocks[3], blocks[0]]));
    }
    return result;
  }
}
