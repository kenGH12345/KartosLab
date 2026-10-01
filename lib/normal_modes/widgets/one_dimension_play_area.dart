import 'package:flutter/material.dart';

import '../controller/one_dimension_controller.dart';
import '../model/amplitude_direction.dart';
import '../model/nm_vec.dart';
import '../normal_modes_constants.dart';
import '../painters/experiment_painter.dart';
import '../render/nm_mvt.dart';
import '../render/nm_render_builder.dart';
import '../render/nm_render_data.dart';

class OneDimensionPlayArea extends StatefulWidget {
  const OneDimensionPlayArea({super.key, required this.controller});

  final OneDimensionController controller;

  @override
  State<OneDimensionPlayArea> createState() => _OneDimensionPlayAreaState();
}

class _OneDimensionPlayAreaState extends State<OneDimensionPlayArea> {
  int? _hoverIndex;
  int? _dragIndex;

  NmMvt get _mvt => NmMvt.oneDimension();

  @override
  Widget build(BuildContext context) {
    final data = NmRenderBuilder.from1D(widget.controller);
    return MouseRegion(
      onHover: (e) {
        final hit = _hitMass(data, e.localPosition);
        if (hit != _hoverIndex) setState(() => _hoverIndex = hit);
      },
      onExit: (_) => setState(() => _hoverIndex = null),
      child: GestureDetector(
        onPanStart: (d) {
          final hit = _hitMass(data, d.localPosition);
          if (hit == null) return;
          _dragIndex = hit;
          widget.controller.beginDrag(hit);
        },
        onPanUpdate: (d) {
          final idx = _dragIndex;
          if (idx == null) return;
          final modelPoint = _mvt.viewToModel(d.localPosition);
          final eq = widget.controller.model.masses[idx].equilibriumPosition;
          final disp = modelPoint - eq;
          final clamped = _clamp1D(disp, eq);
          final axis = widget.controller.model.amplitudeDirection ==
                  AmplitudeDirection.horizontal
              ? clamped.x
              : clamped.y;
          widget.controller.updateDrag(idx, axis);
        },
        onPanEnd: (_) => _endDrag(),
        onPanCancel: _endDrag,
        child: CustomPaint(
          painter: ExperimentPainter(data: data, circleMasses: false),
          foregroundPainter: _hoverIndex == null
              ? null
              : ArrowOverlayPainter(
                  mass: data.masses.firstWhere(
                    (m) => m.index == _hoverIndex,
                    orElse: () => data.masses.first,
                  ),
                  hovered: true,
                ),
          size: const Size(
            NormalModesConstants.layoutWidth,
            NormalModesConstants.layoutHeight,
          ),
        ),
      ),
    );
  }

  void _endDrag() {
    if (_dragIndex == null) return;
    widget.controller.endDrag(interrupted: false);
    _dragIndex = null;
  }

  int? _hitMass(NmRenderData data, Offset p) {
    const r = NormalModesConstants.massNodeSize;
    for (final m in data.masses) {
      if (!m.visible) continue;
      if ((m.center - p).distance <= r) return m.index;
    }
    return null;
  }

  NmVec _clamp1D(NmVec disp, NmVec eq) {
    final dir = widget.controller.model.amplitudeDirection;
    final left = widget.controller.model.masses.first.equilibriumPosition.x;
    final right = widget.controller.model.masses.last.equilibriumPosition.x;
    var x = disp.x;
    var y = disp.y;
    if (dir == AmplitudeDirection.horizontal) {
      y = 0;
      final worldX = eq.x + x;
      if (worldX < left) x = left - eq.x;
      if (worldX > right) x = right - eq.x;
    } else {
      x = 0;
      final half = (NormalModesConstants.dragBoundsHeight1D / 2) / _mvt.scale;
      if (y > half) y = half;
      if (y < -half) y = -half;
    }
    return NmVec(x, y);
  }
}
