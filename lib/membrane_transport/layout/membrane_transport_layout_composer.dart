import 'package:flutter/material.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../layout/membrane_transport_layout.dart';
import '../model/solute_type.dart';
import '../view/membrane_thumbnail_node.dart';

/// Places screen modules by [MembraneTransportLayoutSpec] formulas.
///
/// Z-order matches LAYOUT_SPEC §8 (bottom → top). Does not own physics.
class MembraneTransportLayoutComposer extends StatelessWidget {
  const MembraneTransportLayoutComposer({
    super.key,
    required this.slots,
    required this.selectedSolute,
    required this.observation,
    required this.solutesPanel,
    required this.outsideControl,
    required this.insideControl,
    required this.cell,
    required this.eraser,
    required this.timeControls,
    required this.crossingOptions,
    required this.concentrationsGraph,
    required this.onReset,
    this.proteinPanel,
  });

  final MembraneTransportLayoutSlots slots;
  final SoluteType selectedSolute;
  final Widget observation;
  final Widget solutesPanel;
  final Widget outsideControl;
  final Widget insideControl;
  final Widget cell;
  final Widget eraser;
  final Widget timeControls;
  final Widget crossingOptions;
  final Widget concentrationsGraph;
  final VoidCallback onReset;
  final Widget? proteinPanel;

  @override
  Widget build(BuildContext context) {
    final s = slots;
    final obs = s.observation;
    final showOutside = selectedSolute != SoluteType.atp;

    return SizedBox(
      width: s.canvas.width,
      height: s.canvas.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1 Observation
          Positioned(
            left: obs.left,
            top: obs.top,
            width: obs.width,
            height: obs.height,
            child: observation,
          ),

          // 6 Eraser — left = obs.left, centerY = time.centerY
          Positioned(
            left: s.eraserLeft,
            top: s.eraserCenterY,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: eraser,
            ),
          ),

          // 7 Concentrations — top below time strip (not flush with play/pause)
          Positioned(
            left: s.graphLeft,
            top: s.graphTop,
            child: concentrationsGraph,
          ),

          // 9 Cell — origin at membrane (obs.centerY); artwork centered
          Positioned(
            left: s.cellLeft,
            top: s.cellTop,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: cell,
            ),
          ),

          // 10 Thumbnail + rays
          Positioned.fill(
            child: IgnorePointer(
              child: MembraneThumbnailNode(slots: s),
            ),
          ),

          // 8 Solutes panel — above cell (clickable / not covered)
          Positioned(
            left: s.solutesPanelLeft,
            top: s.solutesPanelCenterY,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: solutesPanel,
            ),
          ),

          // 5+11 Solute controls (moveToFront)
          if (showOutside)
            Positioned(
              left: s.soluteControlCenterX,
              top: s.outsideControlTop,
              child: FractionalTranslation(
                translation: const Offset(-0.5, 0),
                child: outsideControl,
              ),
            ),
          Positioned(
            left: s.soluteControlCenterX,
            top: s.insideControlBottom,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -1.0),
              child: insideControl,
            ),
          ),

          // 12 Protein panel
          if (s.showProteinPanel && proteinPanel != null)
            Positioned(
              top: s.proteinPanelTop,
              right: MembraneTransportLayoutPrimitives.marginX,
              child: proteinPanel!,
            ),

          // Time + checks + Reset above wide concentrations accordion
          Positioned(
            left: s.timeControlCenterX,
            top: s.timeControlTop,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: timeControls,
            ),
          ),
          Positioned(
            left: s.checksRight,
            top: s.checksCenterY,
            child: FractionalTranslation(
              translation: const Offset(-1.0, -0.5),
              child: crossingOptions,
            ),
          ),
          Positioned(
            right: MembraneTransportLayoutPrimitives.marginX,
            bottom: MembraneTransportLayoutPrimitives.marginY,
            child: KratosResetAllButton(
              onPressed: onReset,
              radius: MembraneTransportLayoutPrimitives.resetRadius,
            ),
          ),
        ],
      ),
    );
  }
}
