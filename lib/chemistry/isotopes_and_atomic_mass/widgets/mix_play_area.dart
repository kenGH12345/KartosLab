/// Mix play area: chamber, buckets, large atoms, canvas, sliders.
library;

import 'package:flutter/material.dart';

import '../controller/mixtures_controller.dart';
import '../model/data/data.dart';
import '../model/get_isotope_color.dart';
import '../model/interactivity_mode.dart';
import '../model/mix_particle.dart';
import '../model/mixtures_constants.dart';
import '../model/mixtures_model.dart';
import '../painters/isotope_canvas_painter.dart';
import '../painters/nucleon_ball_painter.dart';
import '../painters/neutron_bucket_painter.dart';
import '../transform/iaam_transform.dart';
import 'control_isotope.dart';
import 'sim_coord_scope.dart';

class MixPlayArea extends StatefulWidget {
  const MixPlayArea({
    super.key,
    required this.controller,
    required this.transform,
  });

  final MixturesController controller;
  final IaamTransform transform;

  @override
  State<MixPlayArea> createState() => _MixPlayAreaState();
}

class _MixPlayAreaState extends State<MixPlayArea> {
  int? _activePointer;

  MixturesController get controller => widget.controller;
  IaamTransform get transform => widget.transform;

  Offset _toModel(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final local = box.globalToLocal(global);
      return transform.viewToModel(local.dx, local.dy);
    }
    final scope = context.findAncestorStateOfType<SimCoordScopeState>();
    final sim = scope == null ? global : scope.globalToSim(global);
    return transform.viewToModel(sim.dx, sim.dy);
  }

  MixParticle? _hitParticle(double mx, double my) {
    final m = controller.model;
    bool hits(MixParticle p) {
      final dx = p.x - mx;
      final dy = p.y - my;
      final r = p.radius * 2.2;
      return dx * dx + dy * dy <= r * r;
    }

    final dragging = m.draggingParticle;
    if (dragging != null && hits(dragging)) return dragging;
    for (final p in m.chamberParticles.reversed) {
      if (hits(p)) return p;
    }
    final inBucket = List<MixParticle>.of(m.bucketParticles)
      ..sort((a, b) => b.destY.compareTo(a.destY));
    for (final p in inBucket) {
      if (hits(p)) return p;
    }
    return null;
  }

  MixParticle? _hitBucket(double mx, double my) {
    final m = controller.model;
    final isotopes = m.possibleIsotopes;
    for (var i = 0; i < isotopes.length; i++) {
      final pos = m.bucketPositionForIndex(i);
      final halfW = kMixBucketWidth / 2;
      final top = pos.y - 8;
      final bottom = pos.y + kMixBucketHeight;
      if (mx < pos.x - halfW || mx > pos.x + halfW) continue;
      if (my < top || my > bottom) continue;
      MixParticle? pick;
      for (final p in m.bucketParticles) {
        if (p.massNumber != isotopes[i].massNumber) continue;
        if (pick == null || p.destY > pick.destY) pick = p;
      }
      return pick;
    }
    return null;
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_activePointer != null) return;
    final m = controller.model;
    if (m.showingNaturesMix ||
        m.interactivityMode != InteractivityMode.bucketsAndLargeAtoms) {
      return;
    }
    final model = _toModel(e.position);
    final hit = _hitParticle(model.dx, model.dy) ?? _hitBucket(model.dx, model.dy);
    if (hit == null) return;
    if (!controller.beginDrag(hit.id, model.dx, model.dy)) return;
    _activePointer = e.pointer;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    final model = _toModel(e.position);
    controller.updateDrag(model.dx, model.dy);
  }

  void _onPointerEnd(PointerEvent e) {
    if (e.pointer != _activePointer) return;
    _activePointer = null;
    controller.endDrag();
  }

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final chamberTL = transform.modelToView(kTestChamberMinX, kTestChamberMaxY);
    final chamberBR = transform.modelToView(kTestChamberMaxX, kTestChamberMinY);
    final chamberRect = Rect.fromLTRB(
      chamberTL.dx,
      chamberTL.dy,
      chamberBR.dx,
      chamberBR.dy,
    );

    final bucketMode = m.interactivityMode ==
            InteractivityMode.bucketsAndLargeAtoms &&
        !m.showingNaturesMix;
    final useCanvas = m.showingNaturesMix ||
        m.interactivityMode == InteractivityMode.slidersAndSmallAtoms;

    final canvasParticles =
        useCanvas ? m.chamberParticles : const <MixParticle>[];

    final bucketSorted = List<MixParticle>.of(m.bucketParticles)
      ..sort((a, b) => a.destY.compareTo(b.destY));

    Widget ball(MixParticle p) {
      final v = transform.modelToView(p.x, p.y);
      final r = transform.modelToViewDelta(p.radius);
      final color = getIsotopeColorForMass(
        atomicNumber: m.selectedAtomicNumber,
        massNumber: p.massNumber,
      );
      return Positioned(
        left: v.dx - r,
        top: v.dy - r,
        width: r * 2,
        height: r * 2,
        child: IgnorePointer(
          key: ValueKey('mix_particle_${p.id}'),
          child: CustomPaint(
            painter: _IsoSpherePainter(
              color: color,
              massNumber: p.massNumber,
            ),
          ),
        ),
      );
    }

    final stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: chamberRect.left,
          top: chamberRect.top,
          width: chamberRect.width,
          height: chamberRect.height,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ),
        ),
        if (!m.showingNaturesMix &&
            m.interactivityMode == InteractivityMode.slidersAndSmallAtoms)
          ..._sliderControls(m),
        if (bucketMode || m.showingNaturesMix)
          ..._bucketLayers(m, front: false),
        if (useCanvas)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: IsotopeCanvasPainter(
                  particles: List.of(canvasParticles),
                  atomicNumber: m.selectedAtomicNumber,
                  transform: transform,
                  chamberViewRect: chamberRect,
                ),
              ),
            ),
          ),
        if (bucketMode) ...bucketSorted.map(ball),
        if (bucketMode || m.showingNaturesMix)
          ..._bucketLayers(m, front: true),
        if (bucketMode) ...m.chamberParticles.map(ball),
        if (bucketMode && m.draggingParticle != null)
          ball(m.draggingParticle!),
      ],
    );

    if (!bucketMode) return stack;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: stack,
    );
  }

  List<Widget> _sliderControls(MixturesModel m) {
    // PhET ControlIsotope: centerY = controller model Y (−238), left = x − MAX/2.
    // Control stack ≈ readout + gaps + label + slider ≈ 96 px tall.
    const controlH = 96.0;
    final widgets = <Widget>[];
    final isotopes = m.possibleIsotopes;
    for (var i = 0; i < isotopes.length; i++) {
      final iso = isotopes[i];
      final pos = transform.modelToView(
        m.bucketPositionForIndex(i).x,
        kMixSliderY,
      );
      widgets.add(
        Positioned(
          left: pos.dx - kMixMaxSliderWidth / 2,
          top: pos.dy - controlH / 2,
          width: kMixMaxSliderWidth,
          height: controlH,
          child: ControlIsotopeWidget(
            controller: controller,
            isotope: iso,
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _bucketLayers(MixturesModel m, {required bool front}) {
    final widgets = <Widget>[];
    final isotopes = m.possibleIsotopes;
    for (var i = 0; i < isotopes.length; i++) {
      final iso = isotopes[i];
      final bucketPos = m.bucketPositionForIndex(i);
      final v = transform.modelToView(bucketPos.x, bucketPos.y);
      final w = transform.modelToViewDelta(kMixBucketWidth);
      final h = transform.modelToViewDelta(kMixBucketHeight);
      final color = getIsotopeColor(
        protonCount: iso.atomicNumber,
        neutronCount: iso.neutronCount,
      );
      // PhET MonoIsotopeBucket caption: "Hydrogen-1"
      final name = ElementRepository.instance
              .getByAtomicNumber(iso.atomicNumber)
              ?.name ??
          iso.symbol;
      final label = '$name-${iso.massNumber}';
      widgets.add(
        Positioned(
          left: v.dx - w / 2,
          top: v.dy - h * 0.15,
          width: w,
          height: h,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ColoredBucketPainter(
                layer: front ? BucketPaintLayer.front : BucketPaintLayer.hole,
                width: w,
                height: h,
                label: front ? label : '',
                baseColor: color,
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _ColoredBucketPainter extends CustomPainter {
  _ColoredBucketPainter({
    required this.layer,
    required this.width,
    required this.height,
    required this.label,
    required this.baseColor,
  });

  final BucketPaintLayer layer;
  final double width;
  final double height;
  final String label;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (layer == BucketPaintLayer.hole) {
      NeutronBucketPainter(
        layer: BucketPaintLayer.hole,
        width: width,
        height: height,
      ).paint(canvas, size);
      return;
    }

    final holeRy = height * NeutronBucketPainter.holeEllipseHeightProportion / 2;
    final holeCenter = Offset(size.width / 2, holeRy + 2);
    final rx = width / 2;
    final topY = holeCenter.dy;
    final bottomY = size.height - 4;
    final path = Path()
      ..moveTo(holeCenter.dx - rx * 0.92, topY)
      ..lineTo(holeCenter.dx - rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.92, topY)
      ..close();

    final hsl = HSLColor.fromColor(baseColor);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            hsl.withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0)).toColor(),
            baseColor,
            hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, topY, size.width, bottomY - topY)),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: holeCenter,
        width: width * 0.95,
        height: holeRy * 2,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor(),
    );

    if (label.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: width < 100 ? 11 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: width * 0.9);
      tp.paint(
        canvas,
        Offset(
          holeCenter.dx - tp.width / 2,
          (topY + bottomY) / 2 - tp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ColoredBucketPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.label != label ||
      oldDelegate.layer != layer;
}

class _IsoSpherePainter extends CustomPainter {
  _IsoSpherePainter({required this.color, required this.massNumber});
  final Color color;
  final int massNumber;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    NucleonBallPainter.paint(canvas, c, r, color);
    // PhET IsotopeNode mass-number label on large atoms.
    final tp = TextPainter(
      text: TextSpan(
        text: '$massNumber',
        style: TextStyle(
          color: Colors.white,
          fontSize: (r * 0.9).clamp(8.0, 12.0),
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 1),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _IsoSpherePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.massNumber != massNumber;
}
