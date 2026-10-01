import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../cck_constants.dart';
import '../controller/cck_ac_controller.dart';
import '../model/cck_vec.dart';
import '../model/elements.dart';
import '../model/enums.dart';
import '../model/vertex.dart';
import '../painters/circuit_painter.dart';
import '../render/cck_mvt.dart';
import '../render/cck_render_builder.dart';
import 'toolbox_catalog.dart';

class CircuitCanvas extends StatefulWidget {
  const CircuitCanvas({
    super.key,
    required this.controller,
    required this.images,
  });

  final CckAcController controller;
  final Map<String, ui.Image> images;

  @override
  State<CircuitCanvas> createState() => CircuitCanvasState();
}

class CircuitCanvasState extends State<CircuitCanvas> {
  CckVertex? _dragVertex;
  CckElement? _dragElement;
  Offset? _lastLocal;
  Offset? _downLocal;
  Size _size = Size.zero;

  CckMvt get _mvt => CckMvt(
        canvasSize: _size,
        zoom: widget.controller.circuit.animatedZoom,
      );

  void spawnAtCenter(CckToolboxSpec spec) {
    if (_size == Size.zero) return;
    widget.controller.spawn(
      spec.kind,
      CckVec(_size.width / 2, _size.height / 2),
      resistorKind: spec.resistorKind ?? CckResistorKind.resistor,
    );
  }

  void spawnAtLocal(CckToolboxSpec spec, Offset local) {
    final model = _mvt.toModel(local);
    widget.controller.spawn(
      spec.kind,
      model,
      resistorKind: spec.resistorKind ?? CckResistorKind.resistor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final data = buildRenderData(widget.controller.circuit);
        return Listener(
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: _onUp,
          child: CustomPaint(
            painter: CircuitPainter(
              data: data,
              mvt: _mvt,
              images: widget.images,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  void _onDown(PointerDownEvent e) {
    _downLocal = e.localPosition;
    _lastLocal = e.localPosition;
    final model = _mvt.toModel(e.localPosition);
    final vertex = _hitVertex(model);
    if (vertex != null) {
      _dragVertex = vertex;
      widget.controller.selectVertex(vertex);
      return;
    }
    final el = _hitElement(model);
    if (el != null) {
      _dragElement = el;
      widget.controller.selectElement(el);
      return;
    }
    widget.controller.selectElement(null);
  }

  void _onMove(PointerMoveEvent e) {
    final last = _lastLocal;
    if (last == null) return;
    final deltaView = e.localPosition - last;
    _lastLocal = e.localPosition;
    final zoom = math.max(widget.controller.circuit.animatedZoom, 1e-6);
    final delta = CckVec(deltaView.dx / zoom, deltaView.dy / zoom);
    if (_dragVertex != null) {
      widget.controller.moveVertex(
        _dragVertex!,
        CckVec(_dragVertex!.x + delta.x, _dragVertex!.y + delta.y),
      );
    } else if (_dragElement != null) {
      widget.controller.moveElement(_dragElement!, delta);
    } else if (widget.controller.circuit.voltmeters.first.active) {
      _maybeDragMeter(e.localPosition, delta);
    }
  }

  void _maybeDragMeter(Offset local, CckVec delta) {
    final m = widget.controller.circuit.voltmeters.first;
    final model = _mvt.toModel(local);
    if (model.distanceTo(m.body) < 40) {
      m.body = CckVec(m.body.x + delta.x, m.body.y + delta.y);
      widget.controller.circuit.dirty = true;
    } else if (model.distanceTo(m.redProbe) < 24) {
      m.redProbe = CckVec(m.redProbe.x + delta.x, m.redProbe.y + delta.y);
      widget.controller.circuit.dirty = true;
    } else if (model.distanceTo(m.blackProbe) < 24) {
      m.blackProbe = CckVec(m.blackProbe.x + delta.x, m.blackProbe.y + delta.y);
      widget.controller.circuit.dirty = true;
    }
  }

  void _onUp(PointerUpEvent e) {
    final down = _downLocal;
    if (down != null &&
        (e.localPosition - down).distance < CckConstants.tapThreshold) {
      final model = _mvt.toModel(e.localPosition);
      final el = _hitElement(model);
      if (el is CckSwitch) {
        widget.controller.toggleSwitch(el);
      }
    }
    if (_dragVertex != null) {
      widget.controller.dropVertex(_dragVertex!);
    } else if (_dragElement != null) {
      widget.controller.dropElement(_dragElement!);
    }
    _dragVertex = null;
    _dragElement = null;
    _lastLocal = null;
    _downLocal = null;
  }

  CckVertex? _hitVertex(CckVec model) {
    CckVertex? best;
    var bestD = CckConstants.vertexRadius;
    for (final v in widget.controller.circuit.vertices) {
      final d = model.distanceTo(v.pos);
      if (d < bestD) {
        bestD = d;
        best = v;
      }
    }
    return best;
  }

  CckElement? _hitElement(CckVec model) {
    CckElement? best;
    var bestD = CckConstants.wireLifelikeWidth;
    for (final el in widget.controller.circuit.elements) {
      final d = _distToSegment(model, el.start.pos, el.end.pos);
      if (d < bestD) {
        bestD = d;
        best = el;
      }
    }
    return best;
  }

  double _distToSegment(CckVec p, CckVec a, CckVec b) {
    final ab = b - a;
    final len2 = ab.x * ab.x + ab.y * ab.y;
    if (len2 == 0) return p.distanceTo(a);
    final t = ((p - a).dot(ab) / len2).clamp(0.0, 1.0);
    return p.distanceTo(a.lerp(b, t));
  }
}
