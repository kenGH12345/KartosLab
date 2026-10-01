/// Chart Intro 衰变方程快照。只画最可能一条，不可点。
///
/// parent → arrow → daughter + plus + emitted
/// [已确认] `DecayEquationNode` / `DecayEquationModel`
library;

import '../../data/decay_type.dart';
import '../../data/nuclide_repository.dart';
import '../../data/nuclide_table.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_decay_spec.dart';
import '../model/chart_intro_state.dart';
import '../model/populated_cells.dart';

enum DecayEquationKind {
  /// 无格：不存在核素 / 空核。[已确认] `currentCellModel === null`
  hidden,

  /// 稳定。[已确认] `isStable` → 只显示 Stable
  stable,

  /// 不稳定但无已知衰变。[已确认] `decayType === null && !isStable`
  unknown,

  /// 有最可能衰变。[已确认] `currentCellModel.decayType`
  decay,
}

class DecayEquationNuclide {
  const DecayEquationNuclide({
    required this.protonNumber,
    required this.massNumber,
    required this.symbol,
  });

  final int protonNumber;
  final int massNumber;
  final String symbol;
}

class DecayEquationRender {
  const DecayEquationRender({
    required this.kind,
    required this.title,
    this.percentText,
    this.parent,
    this.daughter,
    this.emitted,
    this.decayType,
  });

  final DecayEquationKind kind;
  final String title;
  final String? percentText;
  final DecayEquationNuclide? parent;
  final DecayEquationNuclide? daughter;
  final DecayEquationNuclide? emitted;
  final NucleusDecayType? decayType;

  bool get showsEquation => kind != DecayEquationKind.hidden;

  bool get canDecay => decayType != null;

  factory DecayEquationRender.from(
    ChartIntroState state,
    NuclideRepository repository,
  ) {
    const title = ChartIntroVisuals.mostLikelyDecayType;
    final p = state.protonCount;
    final n = state.neutronCount;
    final cell = PopulatedCells.cellAt(p, n);
    if (cell == null) {
      return const DecayEquationRender(
        kind: DecayEquationKind.hidden,
        title: title,
      );
    }

    final elements = repository.table.elements;
    final parent = DecayEquationNuclide(
      protonNumber: p,
      massNumber: state.massNumber,
      symbol: _symbolAt(p, elements),
    );

    if (state.isStable) {
      return DecayEquationRender(
        kind: DecayEquationKind.stable,
        title: title,
        parent: parent,
      );
    }

    final branches = repository.availableDecays(p, n);
    if (branches.isEmpty) {
      return DecayEquationRender(
        kind: DecayEquationKind.unknown,
        title: title,
        parent: parent,
      );
    }

    final branch = branches.first;
    final spec = ChartIntroDecaySpec.of(branch.type);
    final daughterZ = p - spec.protonNumber;
    final daughterA = state.massNumber - spec.massNumber;
    return DecayEquationRender(
      kind: DecayEquationKind.decay,
      title: title,
      percentText: _percentText(branch.percent),
      parent: parent,
      daughter: DecayEquationNuclide(
        protonNumber: daughterZ,
        massNumber: daughterA,
        symbol: _symbolAt(daughterZ, elements),
      ),
      emitted: DecayEquationNuclide(
        protonNumber: spec.protonNumber,
        massNumber: spec.massNumber,
        symbol: spec.symbol,
      ),
      decayType: branch.type,
    );
  }

  static String _symbolAt(int z, List<ElementInfo> elements) {
    if (z < 0 || z >= elements.length) return '';
    return elements[z].symbol;
  }

  /// [已确认] null → `unknown `；再包进 `({{x}}%)`
  static String _percentText(double? percent) {
    final inner = percent == null
        ? ChartIntroVisuals.unknownPercentLiteral
        : (percent == percent.roundToDouble()
            ? '${percent.toInt()}'
            : '$percent');
    return '($inner%)';
  }
}
