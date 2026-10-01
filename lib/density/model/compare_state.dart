import '../solver/compare_constraint.dart';
import '../solver/mass_layout.dart';
import 'density_block.dart';

/// Compare screen. Three preallocated sets; switching visibility keeps per-set state.
class CompareState {
  const CompareState({
    required this.blockSet,
    required this.lockedMass,
    required this.lockedVolume,
    required this.lockedDensity,
    required this.sameMassBlocks,
    required this.sameVolumeBlocks,
    required this.sameDensityBlocks,
  });

  final CompareBlockSet blockSet;
  final double lockedMass;
  final double lockedVolume;
  final double lockedDensity;
  final List<DensityBlock> sameMassBlocks;
  final List<DensityBlock> sameVolumeBlocks;
  final List<DensityBlock> sameDensityBlocks;

  static CompareState initial() {
    return CompareState(
      blockSet: CompareBlockSet.sameMass,
      lockedMass: CompareConstraint.sameMassValue,
      lockedVolume: CompareConstraint.sameVolumeValue,
      lockedDensity: CompareConstraint.sameDensityValue,
      sameMassBlocks: MassLayout.comparePositions(
        CompareBlockSet.sameMass,
        CompareConstraint.createSet(
          set: CompareBlockSet.sameMass,
          lockedMass: CompareConstraint.sameMassValue,
          lockedVolume: CompareConstraint.sameVolumeValue,
          lockedDensity: CompareConstraint.sameDensityValue,
        ),
      ),
      sameVolumeBlocks: MassLayout.comparePositions(
        CompareBlockSet.sameVolume,
        CompareConstraint.createSet(
          set: CompareBlockSet.sameVolume,
          lockedMass: CompareConstraint.sameMassValue,
          lockedVolume: CompareConstraint.sameVolumeValue,
          lockedDensity: CompareConstraint.sameDensityValue,
        ),
      ),
      sameDensityBlocks: MassLayout.comparePositions(
        CompareBlockSet.sameDensity,
        CompareConstraint.createSet(
          set: CompareBlockSet.sameDensity,
          lockedMass: CompareConstraint.sameMassValue,
          lockedVolume: CompareConstraint.sameVolumeValue,
          lockedDensity: CompareConstraint.sameDensityValue,
        ),
      ),
    );
  }

  List<DensityBlock> get visibleBlocks {
    switch (blockSet) {
      case CompareBlockSet.sameMass:
        return sameMassBlocks;
      case CompareBlockSet.sameVolume:
        return sameVolumeBlocks;
      case CompareBlockSet.sameDensity:
        return sameDensityBlocks;
    }
  }

  CompareState copyWith({
    CompareBlockSet? blockSet,
    double? lockedMass,
    double? lockedVolume,
    double? lockedDensity,
    List<DensityBlock>? sameMassBlocks,
    List<DensityBlock>? sameVolumeBlocks,
    List<DensityBlock>? sameDensityBlocks,
  }) {
    return CompareState(
      blockSet: blockSet ?? this.blockSet,
      lockedMass: lockedMass ?? this.lockedMass,
      lockedVolume: lockedVolume ?? this.lockedVolume,
      lockedDensity: lockedDensity ?? this.lockedDensity,
      sameMassBlocks: sameMassBlocks ?? this.sameMassBlocks,
      sameVolumeBlocks: sameVolumeBlocks ?? this.sameVolumeBlocks,
      sameDensityBlocks: sameDensityBlocks ?? this.sameDensityBlocks,
    );
  }

  CompareState withBlockSet(CompareBlockSet next) => copyWith(blockSet: next);

  CompareState withLockedMass(double mass) {
    final clamped = mass.clamp(
      CompareConstraint.sameMassMin,
      CompareConstraint.sameMassMax,
    );
    return copyWith(
      lockedMass: clamped,
      sameMassBlocks: CompareConstraint.applyLocked(
        set: CompareBlockSet.sameMass,
        blocks: sameMassBlocks,
        lockedMass: clamped,
        lockedVolume: lockedVolume,
        lockedDensity: lockedDensity,
      ),
    );
  }

  CompareState withLockedVolume(double volume) {
    final clamped = volume.clamp(
      CompareConstraint.sameVolumeMin,
      CompareConstraint.sameVolumeMax,
    );
    return copyWith(
      lockedVolume: clamped,
      sameVolumeBlocks: CompareConstraint.applyLocked(
        set: CompareBlockSet.sameVolume,
        blocks: sameVolumeBlocks,
        lockedMass: lockedMass,
        lockedVolume: clamped,
        lockedDensity: lockedDensity,
      ),
    );
  }

  CompareState withLockedDensity(double density) {
    final clamped = density.clamp(
      CompareConstraint.sameDensityMin,
      CompareConstraint.sameDensityMax,
    );
    return copyWith(
      lockedDensity: clamped,
      sameDensityBlocks: CompareConstraint.applyLocked(
        set: CompareBlockSet.sameDensity,
        blocks: sameDensityBlocks,
        lockedMass: lockedMass,
        lockedVolume: lockedVolume,
        lockedDensity: clamped,
      ),
    );
  }

  CompareState reset() => CompareState.initial();
}
