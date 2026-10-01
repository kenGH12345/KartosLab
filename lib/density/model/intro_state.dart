import 'density_block.dart';
import 'density_material.dart';
import 'density_vec.dart';

/// Intro screen immutable state. Defaults from `DensityIntroModel.ts`.
class IntroState {
  const IntroState({
    required this.mode,
    required this.blockA,
    required this.blockB,
  });

  final TwoBlockMode mode;
  final DensityBlock blockA;
  final DensityBlock blockB;

  static IntroState initial() {
    return IntroState(
      mode: TwoBlockMode.oneBlock,
      blockA: const DensityBlock(
        id: 'introA',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        volume: 0.005,
        position: DensityVec(-0.2, 0.2),
        visible: true,
      ),
      blockB: const DensityBlock(
        id: 'introB',
        tag: 'B',
        materialId: DensityMaterialId.aluminum,
        volume: 0.005,
        position: DensityVec(0.2, 0.2),
        visible: false,
      ),
    );
  }

  IntroState copyWith({
    TwoBlockMode? mode,
    DensityBlock? blockA,
    DensityBlock? blockB,
  }) {
    return IntroState(
      mode: mode ?? this.mode,
      blockA: blockA ?? this.blockA,
      blockB: blockB ?? this.blockB,
    );
  }

  IntroState withMode(TwoBlockMode next) {
    return copyWith(
      mode: next,
      blockB: blockB.copyWith(visible: next == TwoBlockMode.twoBlocks),
    );
  }

  IntroState reset() => IntroState.initial();
}
