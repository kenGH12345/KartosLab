import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../model/bam_atom.dart';
import '../painters/bam_atom_sphere_painter.dart';
import '../widgets/bam_atom_inventory.dart';
import '../widgets/bam_molecule_viewport.dart';
import '../widgets/bam_your_molecules_panel.dart';

/// Page-level BAM layout matching PhET Single baseline.
class BamScreenBody extends StatefulWidget {
  const BamScreenBody({
    super.key,
    required this.controller,
    this.showCollection = true,
    this.title,
    this.embedded = false,
  });

  final BamController controller;
  final bool showCollection;
  final String? title;
  final bool embedded;

  static const double yourMoleculesWidthFraction = 0.28;
  static const double inventoryHeightFraction = 0.22;

  @override
  State<BamScreenBody> createState() => _BamScreenBodyState();
}

class _BamScreenBodyState extends State<BamScreenBody> {
  final GlobalKey<BamMoleculeViewportState> _viewportKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();
  Offset? _dragGlobal;

  BamMoleculeViewportState? get _viewport => _viewportKey.currentState;

  Offset _modelFromGlobal(Offset global) {
    return _viewport?.globalToModel(global) ?? Offset.zero;
  }

  void _startBucketDrag(BamPlayAtom atom, Offset global) {
    widget.controller.startDragFromBucket(atom, _modelFromGlobal(global));
    setState(() => _dragGlobal = global);
  }

  void _onPointerMove(PointerEvent e) {
    if (widget.controller.draggingAtom == null) return;
    widget.controller.updateDrag(_modelFromGlobal(e.position));
    setState(() => _dragGlobal = e.position);
  }

  void _onPointerEnd(PointerEvent e) {
    if (widget.controller.draggingAtom == null) return;
    final onPlay = _viewport?.containsGlobal(e.position) ?? false;
    if (widget.controller.draggingFromBucket && !onPlay) {
      widget.controller.cancelDragToBucket();
    } else {
      widget.controller.endDrag(
        _modelFromGlobal(e.position),
        droppedOnPlay: onPlay,
      );
    }
    setState(() => _dragGlobal = null);
  }

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final inventoryH = (constraints.maxHeight *
                BamScreenBody.inventoryHeightFraction)
            .clamp(148.0, 180.0);
        final panelW = widget.showCollection
            ? (constraints.maxWidth * BamScreenBody.yourMoleculesWidthFraction)
                .clamp(200.0, 280.0)
            : 0.0;

        return ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final dragAtom = widget.controller.draggingAtom;
            final overlayR = dragAtom == null
                ? 0.0
                : BamAtomSpherePainter.viewRadius(
                    dragAtom.covalentRadius,
                    _viewport?.viewScale ?? 0.32,
                  );
            final showOverlay =
                dragAtom != null && _dragGlobal != null;

            Offset overlayLocal = Offset.zero;
            if (showOverlay) {
              final box =
                  _stackKey.currentContext?.findRenderObject() as RenderBox?;
              overlayLocal =
                  box?.globalToLocal(_dragGlobal!) ?? _dragGlobal!;
            }

            return ColoredBox(
              color: BamConstants.playAreaBackgroundColor,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) {
                  if (widget.controller.draggingAtom != null) {
                    setState(() => _dragGlobal = e.position);
                  }
                },
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerEnd,
                onPointerCancel: _onPointerEnd,
                child: Stack(
                  key: _stackKey,
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: BamMoleculeViewport(
                                    key: _viewportKey,
                                    controller: widget.controller,
                                  ),
                                ),
                                SizedBox(
                                  height: inventoryH,
                                  child: BamAtomInventory(
                                    controller: widget.controller,
                                    onBucketDragStart: _startBucketDrag,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.showCollection)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: SizedBox(
                              width: panelW,
                              child: BamYourMoleculesPanel(
                                controller: widget.controller,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: KratosResetAllButton(
                        onPressed: widget.controller.reset,
                        radius: 20.5,
                        tooltip: '全部重置',
                      ),
                    ),
                    if (showOverlay)
                      Positioned(
                        left: overlayLocal.dx - overlayR,
                        top: overlayLocal.dy - overlayR,
                        width: overlayR * 2,
                        height: overlayR * 2,
                        child: IgnorePointer(
                          child: BamAtomSphere(
                            element: dragAtom.element,
                            radius: overlayR,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '搭建分子'),
        backgroundColor: BamConstants.playAreaBackgroundColor,
      ),
      body: body,
    );
  }
}
