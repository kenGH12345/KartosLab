import 'dart:math' as math;

import '../data/mystery_sets.dart';
import '../solver/mass_layout.dart';
import 'density_block.dart';

class MysteryState {
  const MysteryState({
    required this.blockSet,
    required this.set1,
    required this.set2,
    required this.set3,
    required this.randomBlocks,
    required this.tableExpanded,
    required this.massLabelsVisible,
  });

  final MysteryBlockSet blockSet;
  final List<DensityBlock> set1;
  final List<DensityBlock> set2;
  final List<DensityBlock> set3;
  final List<DensityBlock> randomBlocks;
  final bool tableExpanded;
  final bool massLabelsVisible;

  static MysteryState initial({math.Random? random}) {
    final rng = random ?? math.Random();
    return MysteryState(
      blockSet: MysteryBlockSet.set1,
      set1: MassLayout.mysteryPositions(MysteryBlockSet.set1, MysterySets.set1()),
      set2: MassLayout.mysteryPositions(MysteryBlockSet.set2, MysterySets.set2()),
      set3: MassLayout.mysteryPositions(MysteryBlockSet.set3, MysterySets.set3()),
      randomBlocks: MassLayout.mysteryPositions(
        MysteryBlockSet.random,
        MysterySets.randomSet(rng),
      ),
      tableExpanded: false,
      massLabelsVisible: false,
    );
  }

  List<DensityBlock> get visibleBlocks {
    switch (blockSet) {
      case MysteryBlockSet.set1:
        return set1;
      case MysteryBlockSet.set2:
        return set2;
      case MysteryBlockSet.set3:
        return set3;
      case MysteryBlockSet.random:
        return randomBlocks;
    }
  }

  MysteryState copyWith({
    MysteryBlockSet? blockSet,
    List<DensityBlock>? set1,
    List<DensityBlock>? set2,
    List<DensityBlock>? set3,
    List<DensityBlock>? randomBlocks,
    bool? tableExpanded,
    bool? massLabelsVisible,
  }) {
    return MysteryState(
      blockSet: blockSet ?? this.blockSet,
      set1: set1 ?? this.set1,
      set2: set2 ?? this.set2,
      set3: set3 ?? this.set3,
      randomBlocks: randomBlocks ?? this.randomBlocks,
      tableExpanded: tableExpanded ?? this.tableExpanded,
      massLabelsVisible: massLabelsVisible ?? this.massLabelsVisible,
    );
  }

  MysteryState withBlockSet(MysteryBlockSet next) => copyWith(blockSet: next);

  MysteryState refreshRandom(math.Random random) {
    return copyWith(
      randomBlocks: MassLayout.mysteryPositions(
        MysteryBlockSet.random,
        MysterySets.randomSet(random),
      ),
    );
  }

  /// Reset All also regenerates Random (`DensityMysteryModel.reset`).
  MysteryState reset({math.Random? random}) {
    return MysteryState.initial(random: random);
  }
}
