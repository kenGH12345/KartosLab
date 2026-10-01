import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../data/bam_molecule_catalog.dart';
import '../model/bam_molecule.dart';
import '../painters/bam_play_area_painter.dart';
import 'bam_molecule_3d_dialog.dart';

/// Central molecule construction viewport (play area only — no kit overlay).
class BamMoleculeViewport extends StatefulWidget {
  const BamMoleculeViewport({super.key, required this.controller});

  final BamController controller;

  @override
  State<BamMoleculeViewport> createState() => _BamMoleculeViewportState();
}

class _BamMoleculeViewportState extends State<BamMoleculeViewport> {
  Size _viewSize = Size.zero;

  Offset _toView(Offset model) {
    final play =
        widget.controller.model.collectionLayout.availablePlayAreaBounds;
    final sx = _viewSize.width / play.width;
    final sy = _viewSize.height / play.height;
    final s = sx < sy ? sx : sy;
    final ox = _viewSize.width / 2 - play.center.dx * s;
    final oy = _viewSize.height / 2 + play.center.dy * s;
    return Offset(ox + model.dx * s, oy - model.dy * s);
  }

  Offset _toModel(Offset view) {
    final play =
        widget.controller.model.collectionLayout.availablePlayAreaBounds;
    final sx = _viewSize.width / play.width;
    final sy = _viewSize.height / play.height;
    final s = sx < sy ? sx : sy;
    final ox = _viewSize.width / 2 - play.center.dx * s;
    final oy = _viewSize.height / 2 + play.center.dy * s;
    return Offset((view.dx - ox) / s, (oy - view.dy) / s);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final kit = widget.controller.kit;
        return LayoutBuilder(
          builder: (context, constraints) {
            _viewSize = Size(constraints.maxWidth, constraints.maxHeight);
            final matched = <_FloatingLabel>[];
            if (kit != null) {
              final catalog = BamMoleculeCatalog.mainInstance;
              if (catalog != null) {
                for (final m in kit.molecules) {
                  if (m.atoms.length < 2) continue;
                  final complete = catalog.findMatchingCompleteMolecule(m);
                  if (complete == null) continue;
                  final center = m.positionBounds.center;
                  matched.add(
                    _FloatingLabel(
                      viewOffset: _toView(center) - const Offset(0, 48),
                      name: complete.getDisplayName(),
                      molecule: m,
                      on3d: complete.has3d || complete.has2d
                          ? () => BamMolecule3dDialog.show(context, complete)
                          : null,
                      onBreak: () =>
                          widget.controller.breakMolecule(m),
                    ),
                  );
                }
              }
            }

            return ColoredBox(
              color: BamConstants.playAreaBackgroundColor,
              child: Stack(
                children: [
                  // Interaction + paint layer
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) {
                        if (kit == null) return;
                        final world = _toModel(e.localPosition);
                        if (e.buttons == 2) {
                          final bond =
                              widget.controller.hitTestBond(world);
                          if (bond != null) {
                            widget.controller.breakBond(bond.a, bond.b);
                          }
                          return;
                        }
                        final playHit =
                            widget.controller.hitTestPlayAtom(world);
                        if (playHit != null) {
                          widget.controller.startDragAtom(playHit);
                        }
                      },
                      onPointerMove: (e) {
                        if (widget.controller.draggingAtom != null) {
                          widget.controller
                              .updateDrag(_toModel(e.localPosition));
                        }
                      },
                      onPointerUp: (e) {
                        if (widget.controller.draggingAtom != null) {
                          // Kit area is no longer in this viewport —
                          // drop stays in play / collection hit-test.
                          widget.controller
                              .endDrag(_toModel(e.localPosition));
                        }
                      },
                      onPointerCancel: (_) {
                        final atom = widget.controller.draggingAtom;
                        if (atom != null) {
                          widget.controller.endDrag(atom.position);
                        }
                      },
                      child: GestureDetector(
                        onLongPressStart: (d) {
                          if (kit == null) return;
                          final world = _toModel(d.localPosition);
                          final bond =
                              widget.controller.hitTestBond(world);
                          if (bond != null) {
                            widget.controller.breakBond(bond.a, bond.b);
                          }
                        },
                        child: CustomPaint(
                          painter: kit == null
                              ? null
                              : BamPlayAreaPainter(
                                  kit: kit,
                                  modelToView: _toView,
                                ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  // Floating molecule name + 3D / break
                  for (final label in matched)
                    Positioned(
                      left: label.viewOffset.dx.clamp(4.0, _viewSize.width - 160),
                      top: label.viewOffset.dy.clamp(4.0, _viewSize.height - 40),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(label.name,
                                  style: const TextStyle(fontSize: 12)),
                              if (label.on3d != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Material(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(3),
                                    child: InkWell(
                                      onTap: label.on3d,
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        child: Text(
                                          '3D',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 16,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                tooltip: '拆开',
                                onPressed: label.onBreak,
                                icon: Image.asset(
                                  'assets/images/build_a_molecule/scissors.png',
                                  width: 16,
                                  height: 16,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.content_cut, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Refill (put back) — left above inventory
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Material(
                      color: BamConstants.kitArrowBackgroundEnabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black87),
                      ),
                      child: IconButton(
                        tooltip: '填充',
                        onPressed: widget.controller.refill,
                        icon: const Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                  ),
                  // Reset All — lower right of workspace
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Material(
                      color: Colors.orange,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        tooltip: '重置',
                        onPressed: widget.controller.reset,
                        icon: const Icon(Icons.refresh, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FloatingLabel {
  _FloatingLabel({
    required this.viewOffset,
    required this.name,
    required this.molecule,
    this.on3d,
    required this.onBreak,
  });

  final Offset viewOffset;
  final String name;
  final BamMolecule molecule;
  final VoidCallback? on3d;
  final VoidCallback onBreak;
}
