import 'package:flutter/material.dart';

import '../controller/two_dimensions_controller.dart';
import '../model/nm_vec.dart';
import '../normal_modes_constants.dart';
import '../painters/experiment_painter.dart';
import '../render/nm_mvt.dart';
import '../render/nm_render_builder.dart';
import '../render/nm_render_data.dart';

class TwoDimensionsPlayArea extends StatefulWidget {
  const TwoDimensionsPlayArea({super.key, required this.controller});

  final TwoDimensionsController controller;

  @override
  State<TwoDimensionsPlayArea> createState() => _TwoDimensionsPlayAreaState();
}

class _TwoDimensionsPlayAreaState extends State<TwoDimensionsPlayArea> {
  MassRender? _hover;
  int? _dragI;
  int? _dragJ;

  NmMvt get _mvt => NmMvt.twoDimensions();

  @override
  Widget build(BuildContext context) {
    final data = NmRenderBuilder.from2D(widget.controller);
    return MouseRegion(
      onHover: (e) {
        final hit = _hit(data, e.localPosition);
        if (hit?.index != _hover?.index) setState(() => _hover = hit);
      },
      onExit: (_) => setState(() => _hover = null),
      child: GestureDetector(
        onPanStart: (d) {
          final hit = _hit(data, d.localPosition);
          if (hit == null || hit.indexI == null || hit.indexJ == null) return;
          _dragI = hit.indexI;
          _dragJ = hit.indexJ;
          widget.controller.beginDrag(hit.indexI!, hit.indexJ!);
        },
        onPanUpdate: (d) {
          if (_dragI == null || _dragJ == null) return;
          final modelPoint = _mvt.viewToModel(d.localPosition);
          final eq =
              widget.controller.model.masses[_dragI!][_dragJ!].equilibriumPosition;
          var disp = modelPoint - eq;
          final world = eq + disp;
          const minC = -1.0;
          const maxC = 1.0;
          final clampedWorld = NmVec(
            world.x.clamp(minC, maxC),
            world.y.clamp(minC, maxC),
          );
          disp = clampedWorld - eq;
          widget.controller.updateDrag(_dragI!, _dragJ!, disp);
        },
        onPanEnd: (_) => _end(),
        onPanCancel: _end,
        child: CustomPaint(
          painter: ExperimentPainter(data: data, circleMasses: true),
          foregroundPainter: _hover == null
              ? null
              : ArrowOverlayPainter(mass: _hover!, hovered: true),
          size: const Size(
            NormalModesConstants.layoutWidth,
            NormalModesConstants.layoutHeight,
          ),
        ),
      ),
    );
  }

  void _end() {
    if (_dragI == null) return;
    widget.controller.endDrag(interrupted: false);
    _dragI = null;
    _dragJ = null;
  }

  MassRender? _hit(NmRenderData data, Offset p) {
    const r = NormalModesConstants.massNodeSize;
    for (final m in data.masses) {
      if (!m.visible) continue;
      if ((m.center - p).distance <= r) return m;
    }
    return null;
  }
}
