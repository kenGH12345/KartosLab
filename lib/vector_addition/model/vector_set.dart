import 'package:flutter/material.dart';

import '../vector_addition_colors.dart';
import 'enums.dart';
import 'equations_vector.dart';
import 'graph.dart';
import 'resultant_vector.dart';
import 'va_vec.dart';
import 'vector.dart';
import 'view_properties.dart';

class VaVectorSpec {
  const VaVectorSpec({
    required this.symbol,
    required this.tail,
    required this.xy,
    this.onGraph = false,
    this.baseTail,
  });

  final String symbol;
  final VaVec tail;
  final VaVec xy;
  final bool onGraph;

  /// Equations base-vector tail (defaults to [tail] if null).
  final VaVec? baseTail;
}

class VaColorPalette {
  const VaColorPalette({
    required this.vectorFill,
    required this.sumFill,
    this.baseVectorFill = Colors.white,
    this.baseVectorStroke,
  });
  final Color vectorFill;
  final Color sumFill;
  final Color baseVectorFill;
  final Color? baseVectorStroke;

  Color get effectiveBaseStroke => baseVectorStroke ?? vectorFill;
}

class VaPalettes {
  static const explore1dH = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillBlue,
    sumFill: VectorAdditionColors.sumFillBlue,
  );
  static const explore1dV = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillBlue,
    sumFill: VectorAdditionColors.sumFillBlue,
  );
  static const explore2dC = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillBlue,
    sumFill: VectorAdditionColors.sumFillBlue,
  );
  static const explore2dP = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillPink,
    sumFill: VectorAdditionColors.sumFillPurple,
  );
  static const labC1 = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillBlue,
    sumFill: VectorAdditionColors.sumFillBlue,
  );
  static const labC2 = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillOrange,
    sumFill: VectorAdditionColors.sumFillDarkRed,
  );
  static const equationsC = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillBlue,
    sumFill: VectorAdditionColors.sumFillBlack,
  );
  static const equationsP = VaColorPalette(
    vectorFill: VectorAdditionColors.vectorFillPink,
    sumFill: VectorAdditionColors.sumFillBlack,
  );
}

/// One vector set: allVectors + activeVectors + resultant.
class VaVectorSet {
  VaVectorSet.sum({
    required this.graph,
    required List<VaVectorSpec> specs,
    required this.coordinateSnapMode,
    required this.palette,
    required this.styleState,
    required this.resultantSymbol,
    VaVec? resultantTail,
  }) {
    allVectors = [
      for (final s in specs)
        VaVector(
          tailPosition: s.tail,
          xyComponents: s.xy,
          graph: graph,
          coordinateSnapMode: coordinateSnapMode,
          componentStyle: () => styleState.style,
          symbol: s.symbol,
          isOnGraph: s.onGraph,
        ),
    ];
    activeVectors = [
      for (final v in allVectors)
        if (v.isOnGraph) v,
    ];
    resultant = SumVector(
      tailPosition: resultantTail ?? graph.bounds.center,
      contributors: allVectors,
      graph: graph,
      coordinateSnapMode: coordinateSnapMode,
      componentStyle: () => styleState.style,
      symbol: resultantSymbol,
    );
  }

  VaVectorSet.equations({
    required this.graph,
    required List<VaVectorSpec> specs,
    required this.coordinateSnapMode,
    required this.palette,
    required this.styleState,
    required this.resultantSymbol,
    required EquationType equationType,
    required VaVec resultantTail,
  }) {
    allVectors = [
      for (final s in specs)
        EquationsVector(
          vectorTail: s.tail,
          baseTail: s.baseTail ?? const VaVec(35, 15),
          baseXy: s.xy,
          graph: graph,
          coordinateSnapMode: coordinateSnapMode,
          componentStyle: () => styleState.style,
          symbol: s.symbol,
        ),
    ];
    activeVectors = List<VaVector>.from(allVectors);
    resultant = EquationsResultant(
      tailPosition: resultantTail,
      operands: allVectors,
      equationType: equationType,
      graph: graph,
      coordinateSnapMode: coordinateSnapMode,
      componentStyle: () => styleState.style,
      symbol: resultantSymbol,
    );
  }

  final Graph graph;
  final CoordinateSnapMode coordinateSnapMode;
  final VaColorPalette palette;
  final VaComponentStyleState styleState;
  final String resultantSymbol;

  late final List<VaVector> allVectors;
  late List<VaVector> activeVectors;
  late final ResultantVector resultant;

  int get numberOnGraph => allVectors.where((v) => v.isOnGraph).length;

  void erase() {
    activeVectors = [];
    for (final v in allVectors) {
      if (v.isRemovableFromGraph) {
        v.reset();
      }
    }
    if (resultant is SumVector) {
      (resultant as SumVector).recompute();
    }
  }

  void reset() {
    for (final v in allVectors) {
      v.reset();
    }
    activeVectors = [
      for (final v in allVectors)
        if (v.isOnGraph) v,
    ];
    resultant.reset();
  }
}
