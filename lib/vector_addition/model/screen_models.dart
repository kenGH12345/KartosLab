import 'dart:ui';

import '../vector_addition_constants.dart';
import 'enums.dart';
import 'graph.dart';
import 'resultant_vector.dart';
import 'va_vec.dart';
import 'vector.dart';
import 'vector_set.dart';
import 'view_properties.dart';

/// One scene inside a screen (horizontal/vertical or cartesian/polar).
class VaScene {
  VaScene({
    required this.name,
    required this.graph,
    required this.coordinateSnapMode,
    required this.vectorSets,
  });

  final String name;
  final Graph graph;
  final CoordinateSnapMode coordinateSnapMode;
  final List<VaVectorSet> vectorSets;

  VaVector? selected;

  void reset() {
    graph.reset();
    selected = null;
    for (final s in vectorSets) {
      s.reset();
    }
  }

  void erase() {
    selected = null;
    for (final s in vectorSets) {
      s.erase();
    }
  }
}

/// Base screen model — independent per Screen.
abstract class VaScreenModel {
  VaScreenModel();

  final VaViewProperties view = VaViewProperties();
  final VaComponentStyleState componentStyle = VaComponentStyleState();

  late final List<VaScene> scenes;
  int sceneIndex = 0;

  VaScene get scene => scenes[sceneIndex];

  void selectScene(int index) {
    sceneIndex = index.clamp(0, scenes.length - 1);
  }

  void reset() {
    componentStyle.reset();
    for (final s in scenes) {
      s.reset();
    }
    sceneIndex = 0;
    resetView();
  }

  void resetView();

  void erase() => scene.erase();
}

class Explore1DModel extends VaScreenModel {
  Explore1DModel() {
    scenes = [
      _build(
        name: 'Horizontal',
        orientation: GraphOrientation.horizontal,
        bounds: VaBounds.explore1dCentered(),
        palette: VaPalettes.explore1dH,
        symbols: const ['a', 'b', 'c'],
        xy: const VaVec(5, 0),
      ),
      _build(
        name: 'Vertical',
        orientation: GraphOrientation.vertical,
        bounds: VaBounds.explore1dCentered(),
        palette: VaPalettes.explore1dV,
        symbols: const ['d', 'e', 'f'],
        xy: const VaVec(0, 5),
      ),
    ];
    view.resetExplore();
  }

  VaScene _build({
    required String name,
    required GraphOrientation orientation,
    required VaBounds bounds,
    required VaColorPalette palette,
    required List<String> symbols,
    required VaVec xy,
  }) {
    final graph = Graph(initialBounds: bounds, orientation: orientation);
    final set = VaVectorSet.sum(
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      palette: palette,
      styleState: componentStyle,
      resultantSymbol: 's',
      specs: [
        for (final sym in symbols)
          VaVectorSpec(symbol: sym, tail: VaVec.zero, xy: xy),
      ],
    );
    return VaScene(
      name: name,
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      vectorSets: [set],
    );
  }

  @override
  void resetView() => view.resetExplore();
}

class Explore2DModel extends VaScreenModel {
  Explore2DModel() {
    scenes = [_cartesian(), _polar()];
    view.resetExplore();
  }

  VaScene _cartesian() {
    final graph = Graph(
      initialBounds: VaBounds.defaultGraph,
      orientation: GraphOrientation.twoDimensional,
    );
    final set = VaVectorSet.sum(
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      palette: VaPalettes.explore2dC,
      styleState: componentStyle,
      resultantSymbol: 's',
      specs: const [
        VaVectorSpec(symbol: 'a', tail: VaVec.zero, xy: VaVec(6, 8)),
        VaVectorSpec(symbol: 'b', tail: VaVec.zero, xy: VaVec(8, 6)),
        VaVectorSpec(symbol: 'c', tail: VaVec.zero, xy: VaVec(0, -10)),
      ],
    );
    return VaScene(
      name: 'Cartesian',
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      vectorSets: [set],
    );
  }

  VaScene _polar() {
    final graph = Graph(
      initialBounds: VaBounds.defaultGraph,
      orientation: GraphOrientation.twoDimensional,
    );
    final set = VaVectorSet.sum(
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.polar,
      palette: VaPalettes.explore2dP,
      styleState: componentStyle,
      resultantSymbol: 's',
      specs: const [
        VaVectorSpec(symbol: 'd', tail: VaVec.zero, xy: VaVec(6, 8)),
        VaVectorSpec(symbol: 'e', tail: VaVec.zero, xy: VaVec(8, 6)),
        VaVectorSpec(symbol: 'f', tail: VaVec.zero, xy: VaVec(0, -10)),
      ],
    );
    return VaScene(
      name: 'Polar',
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.polar,
      vectorSets: [set],
    );
  }

  @override
  void resetView() => view.resetExplore();
}

class LabModel extends VaScreenModel {
  LabModel() {
    scenes = [_cartesian()];
    view.resetExplore();
  }

  /// Lab Cartesian: 2 sets × 10 vectors, all off-graph; sum tails (12,10)/(25,5).
  VaScene _cartesian() {
    final graph = Graph(
      initialBounds: VaBounds.defaultGraph,
      orientation: GraphOrientation.twoDimensional,
    );
    const initialXy = VaVec(8, 6);

    VaVectorSet buildSet(String sym, VaColorPalette pal, VaVec sumTail) {
      return VaVectorSet.sum(
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        palette: pal,
        styleState: componentStyle,
        resultantSymbol: 's_$sym',
        resultantTail: sumTail,
        specs: [
          for (var i = 1;
              i <= VectorAdditionConstants.labVectorsPerVectorSet;
              i++)
            VaVectorSpec(
              symbol: '${sym}_$i',
              tail: VaVec.zero,
              xy: initialXy,
            ),
        ],
      );
    }

    return VaScene(
      name: 'Cartesian',
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      vectorSets: [
        buildSet('u', VaPalettes.labC1, const VaVec(12, 10)),
        buildSet('v', VaPalettes.labC2, const VaVec(25, 5)),
      ],
    );
  }

  @override
  void resetView() => view.resetExplore();
}

class EquationsModel extends VaScreenModel {
  EquationsModel() {
    scenes = [_cartesian(), _polar()];
    equationType = EquationType.addition;
    view.resetEquations();
  }

  EquationType equationType = EquationType.addition;

  VaScene _cartesian() {
    final bottomLeft = Offset(
      VectorAdditionConstants.defaultGraphBottomLeftX,
      VectorAdditionConstants.defaultGraphBottomLeftY + 40,
    );
    final graph = Graph(
      initialBounds: VaBounds.defaultGraph,
      orientation: GraphOrientation.twoDimensional,
      bottomLeft: bottomLeft,
    );
    final set = VaVectorSet.equations(
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      palette: VaPalettes.equationsC,
      styleState: componentStyle,
      resultantSymbol: 'c',
      equationType: EquationType.addition,
      resultantTail: const VaVec(25, 5),
      specs: const [
        VaVectorSpec(
          symbol: 'a',
          tail: VaVec(5, 5),
          xy: VaVec(0, 5),
          baseTail: VaVec(35, 15),
          onGraph: true,
        ),
        VaVectorSpec(
          symbol: 'b',
          tail: VaVec(15, 5),
          xy: VaVec(5, 5),
          baseTail: VaVec(35, 5),
          onGraph: true,
        ),
      ],
    );
    return VaScene(
      name: 'Cartesian',
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      vectorSets: [set],
    );
  }

  VaScene _polar() {
    final bottomLeft = Offset(
      VectorAdditionConstants.defaultGraphBottomLeftX,
      VectorAdditionConstants.defaultGraphBottomLeftY + 40,
    );
    final graph = Graph(
      initialBounds: VaBounds.defaultGraph,
      orientation: GraphOrientation.twoDimensional,
      bottomLeft: bottomLeft,
    );
    final eXy = VaVec.createPolar(8, 45 * 3.141592653589793 / 180);
    final set = VaVectorSet.equations(
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.polar,
      palette: VaPalettes.equationsP,
      styleState: componentStyle,
      resultantSymbol: 'f',
      equationType: EquationType.addition,
      resultantTail: const VaVec(25, 5),
      specs: [
        const VaVectorSpec(
          symbol: 'd',
          tail: VaVec(5, 5),
          xy: VaVec(5, 0),
          baseTail: VaVec(35, 15),
          onGraph: true,
        ),
        VaVectorSpec(
          symbol: 'e',
          tail: const VaVec(15, 5),
          xy: eXy,
          baseTail: const VaVec(35, 5),
          onGraph: true,
        ),
      ],
    );
    return VaScene(
      name: 'Polar',
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.polar,
      vectorSets: [set],
    );
  }

  void setEquationType(EquationType type) {
    equationType = type;
    for (final s in scenes) {
      final r = s.vectorSets.first.resultant;
      if (r is EquationsResultant) {
        r.equationType = type;
        r.recompute();
      }
    }
  }

  void notifyEquationVectorsChanged() {
    final r = scene.vectorSets.first.resultant;
    if (r is EquationsResultant) r.recompute();
  }

  @override
  void reset() {
    equationType = EquationType.addition;
    super.reset();
    setEquationType(EquationType.addition);
  }

  @override
  void resetView() => view.resetEquations();

  @override
  void erase() {
    // Equations does not support erase.
  }

  String get equationLabel {
    final syms = scene.vectorSets.first.allVectors.map((v) => v.symbol).toList();
    final a = syms.isNotEmpty ? syms[0] : 'a';
    final b = syms.length > 1 ? syms[1] : 'b';
    final c = scene.vectorSets.first.resultantSymbol;
    switch (equationType) {
      case EquationType.addition:
        return '$a + $b = $c';
      case EquationType.subtraction:
        return '$a − $b = $c';
      case EquationType.negation:
        return '$a + $b + $c = 0';
    }
  }
}
