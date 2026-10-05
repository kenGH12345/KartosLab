import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../data/bam_molecule_catalog.dart';
import '../model/bam_molecule.dart';
import '../painters/bam_play_area_painter.dart';
import 'bam_molecule_3d_dialog.dart';

/// Central molecule construction viewport (play area only — no kit overlay).
class BamMoleculeViewport extends StatefulWidget {
  const BamMoleculeViewport({
    super.key,
    required this.controller,
  });

  final BamController controller;

  @override
  State<BamMoleculeViewport> createState() => BamMoleculeViewportState();
}

class BamMoleculeViewportState extends State<BamMoleculeViewport> {
  Size _viewSize = Size.zero;

  double get viewScale {
    final play =
        widget.controller.model.collectionLayout.availablePlayAreaBounds;
    if (_viewSize.width <= 0 || _viewSize.height <= 0 || play.width <= 0) {
      return 0.3;
    }
    final sx = _viewSize.width / play.width;
    final sy = _viewSize.height / play.height;
    return sx < sy ? sx : sy;
  }

  Offset _toView(Offset model) {
    final play =
        widget.controller.model.collectionLayout.availablePlayAreaBounds;
    final s = viewScale;
    final ox = _viewSize.width / 2 - play.center.dx * s;
    final oy = _viewSize.height / 2 + play.center.dy * s;
    return Offset(ox + model.dx * s, oy - model.dy * s);
  }

  Offset _toModel(Offset view) {
    final play =
        widget.controller.model.collectionLayout.availablePlayAreaBounds;
    final s = viewScale;
    final ox = _viewSize.width / 2 - play.center.dx * s;
    final oy = _viewSize.height / 2 + play.center.dy * s;
    return Offset((view.dx - ox) / s, (oy - view.dy) / s);
  }

  Offset globalToModel(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Offset.zero;
    return _toModel(box.globalToLocal(global));
  }

  bool containsGlobal(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    final local = box.globalToLocal(global);
    return local.dx >= 0 &&
        local.dy >= 0 &&
        local.dx <= box.size.width &&
        local.dy <= box.size.height;
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
                      onBreak: () => widget.controller.breakMolecule(m),
                    ),
                  );
                }
              }
            }

            return ColoredBox(
              color: BamConstants.playAreaBackgroundColor,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) {
                        if (kit == null) return;
                        if (widget.controller.draggingAtom != null) return;
                        final world = _toModel(e.localPosition);
                        if (e.buttons == 2) {
                          final bond = widget.controller.hitTestBond(world);
                          if (bond != null) {
                            widget.controller.breakBond(bond.a, bond.b);
                          }
                          return;
                        }
                        final playHit =
                            widget.controller.hitTestPlayAtom(world);
                        if (playHit != null) {
                          widget.controller
                              .startDragAtom(playHit, pointer: world);
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
                  for (final label in matched)
                    Positioned(
                      left: label.viewOffset.dx
                          .clamp(4.0, _viewSize.width - 160),
                      top: label.viewOffset.dy
                          .clamp(4.0, _viewSize.height - 40),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Material(
                      color: BamConstants.kitArrowBackgroundEnabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black87),
                      ),
                      child: InkWell(
                        onTap: widget.controller.refill,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: CustomPaint(painter: _RefillArrowPainter()),
                        ),
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

/// Yellow refill / put-back glyph (PhET ResetBucketButton, not Material).
class _RefillArrowPainter extends CustomPainter {
  const _RefillArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final r = 9.0;
    final arc = Path()
      ..addArc(Rect.fromCircle(center: c, radius: r), 0.9, 4.4);
    canvas.drawPath(arc, paint);
    final tip = Offset(c.dx + r * 0.15, c.dy - r);
    final path = Path()
      ..moveTo(tip.dx - 4, tip.dy + 1)
      ..lineTo(tip.dx + 5, tip.dy)
      ..lineTo(tip.dx - 1, tip.dy + 6)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
