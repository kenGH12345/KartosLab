import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/baa_constants.dart';
import '../model/baa_model.dart';
import '../model/baa_particle.dart';
import '../model/electron_model.dart';
import '../painters/baa_bucket_painter.dart';
import '../painters/particle_sphere_painter.dart';
import '../transform/baa_transform.dart';
import '../view/atom_view_state.dart';

/// Interactive atom + buckets (PhET `InteractiveSchematicAtom`).
///
/// Pointer drag is owned by a single [Listener] on the play area so that
/// rebuilds after [BAAModel.beginDrag] do not dispose the active gesture
/// recognizer (which cancelled pans when each particle had its own
/// [GestureDetector]).
class InteractiveAtomPlayArea extends StatefulWidget {
  const InteractiveAtomPlayArea({
    super.key,
    required this.model,
    required this.viewState,
    required this.transform,
    required this.simKey,
    this.rightReserved = 0,
  });

  final BAAModel model;
  final AtomViewState viewState;
  final BaaTransform transform;
  final GlobalKey simKey;

  /// Design-space width reserved for right accordion column (no pointer steal).
  final double rightReserved;

  @override
  State<InteractiveAtomPlayArea> createState() =>
      _InteractiveAtomPlayAreaState();
}

class _InteractiveAtomPlayAreaState extends State<InteractiveAtomPlayArea> {
  int? _activePointer;
  BaaParticle? _activeParticle;

  BAAModel get model => widget.model;
  AtomViewState get viewState => widget.viewState;
  BaaTransform get transform => widget.transform;

  Offset _globalToSim(Offset global) {
    final box =
        widget.simKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  /// Pointer → model: track finger/cursor center (跟手).
  ///
  /// PhET `PARTICLE_TOUCH_DRAG_OFFSET` lifts the particle above a finger for
  /// visibility; users report that as laggy/non-following, so we track 1:1.
  Offset _pointerToModel(Offset global) {
    final sim = _globalToSim(global);
    return transform.viewToModel(sim.dx, sim.dy);
  }

  /// Hit-test: whichever particle the pointer is on (topmost wins).
  ///
  /// No drag order — any particle under the finger/cursor is grabable; when
  /// several overlap, prefer higher [BaaParticle.zLayer] (stack top).
  BaaParticle? _hitTest(Offset modelPos) {
    BaaParticle? best;
    var bestZ = -0x3fffffff;
    var bestD = double.infinity;
    void consider(BaaParticle p) {
      if (p.isDragging) return;
      final r = ParticleSpherePainter.radiusFor(p.type) + 8;
      final d = p.distanceTo(modelPos.dx, modelPos.dy);
      if (d > r) return;
      if (p.zLayer > bestZ || (p.zLayer == bestZ && d < bestD)) {
        bestZ = p.zLayer;
        bestD = d;
        best = p;
      }
    }

    for (final type in BaaParticleType.values) {
      for (final p in model.bucketFor(type).particles) {
        consider(p);
      }
    }
    for (final p in model.atom.protons) {
      consider(p);
    }
    for (final p in model.atom.neutrons) {
      consider(p);
    }
    if (model.electronModel.isShells) {
      for (final p in model.atom.electrons) {
        consider(p);
      }
    }
    return best;
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_activePointer != null) return;
    // Raw pointer position for hit (no drag offset — offset applies while moving).
    final sim = _globalToSim(e.position);
    final hitModel = transform.viewToModel(sim.dx, sim.dy);
    final p = _hitTest(hitModel);
    if (p == null) return;
    _activePointer = e.pointer;
    _activeParticle = p;
    final m = _pointerToModel(e.position);
    model.beginDrag(p, modelX: m.dx, modelY: m.dy);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    final p = _activeParticle;
    if (p == null) return;
    final m = _pointerToModel(e.position);
    model.updateDrag(p, m.dx, m.dy);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer != _activePointer) return;
    final p = _activeParticle;
    _activePointer = null;
    _activeParticle = null;
    if (p == null || !p.isDragging) return;
    final m = _pointerToModel(e.position);
    model.endDrag(p, m.dx, m.dy);
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _activePointer) return;
    final p = _activeParticle;
    _activePointer = null;
    _activeParticle = null;
    if (p != null && p.isDragging) {
      model.endDrag(p, p.x, p.y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([model, viewState]),
      builder: (context, _) {
        final children = <Widget>[
          _shellOrCloud(),
          _nucleusMarker(),
          ..._bucketHoles(),
          ..._bucketParticles(),
          ..._bucketFronts(),
          ..._atomParticles(),
          if (model.draggingParticle != null)
            _particleWidget(model.draggingParticle!, dragging: true),
          _elementLabels(),
        ];
        final visuals = Stack(clipBehavior: Clip.none, children: children);
        // Pointer strip excludes right accordion so panels stay clickable when
        // this play area is painted above them (PhET interactiveAtom z-order).
        final reserve = widget.rightReserved;
        if (reserve <= 0) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: visuals,
          );
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            visuals,
            Positioned(
              left: 0,
              top: 0,
              right: reserve,
              bottom: 0,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shellOrCloud() {
    final center = transform.modelToView(0, 0);
    if (model.electronModel.isCloud) {
      final r = ElectronModel.cloudRadius(
        electronCount: model.electronCount,
        innerShellRadius: BAAConstants.innerElectronShellRadius,
        outerShellRadius: BAAConstants.outerElectronShellRadius,
        maxElectrons: BAAConstants.maxElectrons,
      );
      final vr = transform.modelToViewDelta(r);
      if (vr < 1) return const SizedBox.shrink();
      return Positioned(
        left: center.dx - vr,
        top: center.dy - vr,
        width: vr * 2,
        height: vr * 2,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xC80000FF),
                  const Color(0x000000FF),
                ],
                stops: const [0.0, 0.9],
              ),
            ),
          ),
        ),
      );
    }

    final inner =
        transform.modelToViewDelta(BAAConstants.innerElectronShellRadius);
    final outer =
        transform.modelToViewDelta(BAAConstants.outerElectronShellRadius);
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ShellRingsPainter(
            center: center,
            innerR: inner,
            outerR: outer,
          ),
        ),
      ),
    );
  }

  Widget _nucleusMarker() {
    final c = transform.modelToView(0, 0);
    return Positioned(
      left: c.dx - 6,
      top: c.dy - 6,
      width: 12,
      height: 12,
      child: IgnorePointer(
        child: CustomPaint(painter: _NucleusXPainter()),
      ),
    );
  }

  List<Widget> _bucketHoles() {
    return [
      for (final type in BaaParticleType.values)
        _bucketLayer(type, BaaBucketPaintLayer.hole),
    ];
  }

  List<Widget> _bucketFronts() {
    return [
      for (final type in BaaParticleType.values)
        _bucketLayer(type, BaaBucketPaintLayer.front),
    ];
  }

  Widget _bucketLayer(BaaParticleType type, BaaBucketPaintLayer layer) {
    final bx = switch (type) {
      BaaParticleType.proton => BAAConstants.protonBucketX,
      BaaParticleType.neutron => BAAConstants.neutronBucketX,
      BaaParticleType.electron => BAAConstants.electronBucketX,
    };
    final view = transform.modelToView(bx, BAAConstants.bucketYOffset);
    final w = transform.modelToViewDelta(BAAConstants.bucketWidth);
    final h = transform.modelToViewDelta(BAAConstants.bucketHeight);
    final label = switch (type) {
      BaaParticleType.proton => 'Protons',
      BaaParticleType.neutron => 'Neutrons',
      BaaParticleType.electron => 'Electrons',
    };
    final color = ParticleSpherePainter.colorFor(type);
    return Positioned(
      left: view.dx - w / 2,
      top: view.dy - h * 0.15,
      width: w,
      height: h,
      child: IgnorePointer(
        child: CustomPaint(
          painter: BaaBucketPainter(
            layer: layer,
            width: w,
            height: h,
            baseColor: color,
            label: label,
          ),
        ),
      ),
    );
  }

  List<Widget> _bucketParticles() {
    final all = <BaaParticle>[
      for (final type in BaaParticleType.values)
        for (final p in model.bucketFor(type).particles)
          if (!p.isDragging) p,
    ]..sort((a, b) => a.zLayer.compareTo(b.zLayer));
    return [for (final p in all) _particleWidget(p)];
  }

  List<Widget> _atomParticles() {
    final particles = <BaaParticle>[
      ...model.atom.protons,
      ...model.atom.neutrons,
      if (model.electronModel.isShells) ...model.atom.electrons,
    ];
    particles.sort((a, b) => a.zLayer.compareTo(b.zLayer));
    return [
      for (final p in particles)
        if (!p.isDragging) _particleWidget(p),
    ];
  }

  Widget _particleWidget(BaaParticle p, {bool dragging = false}) {
    final r = ParticleSpherePainter.radiusFor(p.type);
    final visualR = transform.modelToViewDelta(r);
    // Hit padding in design/view space (Listener does geometric hit-test).
    final hit = (visualR + 8).clamp(14.0, 28.0);
    final view = transform.modelToView(p.x, p.y);
    return Positioned(
      left: view.dx - hit,
      top: view.dy - hit,
      width: hit * 2,
      height: hit * 2,
      child: _KeyboardParticle(
        particle: p,
        model: model,
        visualDiameter: visualR * 2,
        dragging: dragging || p.isDragging,
      ),
    );
  }

  Widget _elementLabels() {
    final center = transform.modelToView(0, 0);
    final name = model.numberAtom.elementDisplayName;
    final charge = model.charge;
    String? ionLabel;
    if (viewState.neutralAtomOrIonVisible && model.protonCount > 0) {
      ionLabel = charge == 0 ? 'Neutral Atom' : 'Ion';
    }
    String? stabLabel;
    if (viewState.nuclearStabilityVisible && model.massNumber > 0) {
      stabLabel = model.nucleusStable ? 'Stable' : 'Unstable';
    }

    return Positioned(
      left: center.dx - 80,
      top: center.dy -
          transform.modelToViewDelta(
            BAAConstants.outerElectronShellRadius,
          ) -
          48,
      width: 160,
      child: IgnorePointer(
        child: Column(
          children: [
            if (viewState.elementNameVisible && name.isNotEmpty)
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (ionLabel != null)
              Text(ionLabel, style: const TextStyle(fontSize: 14)),
            if (stabLabel != null)
              Text(
                stabLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: model.nucleusStable
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Keyboard / focus chrome only — pointer drag is handled by the play-area
/// [Listener] so rebuilds do not cancel the active pointer.
class _KeyboardParticle extends StatelessWidget {
  const _KeyboardParticle({
    required this.particle,
    required this.model,
    required this.visualDiameter,
    required this.dragging,
  });

  final BaaParticle particle;
  final BAAModel model;
  final double visualDiameter;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.space): const _GrabIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const _GrabIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const _DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyW): const _NavIntent(-1),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const _NavIntent(-1),
        LogicalKeySet(LogicalKeyboardKey.keyA): const _NavIntent(-1),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const _NavIntent(-1),
        LogicalKeySet(LogicalKeyboardKey.keyS): const _NavIntent(1),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const _NavIntent(1),
        LogicalKeySet(LogicalKeyboardKey.keyD): const _NavIntent(1),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const _NavIntent(1),
        LogicalKeySet(LogicalKeyboardKey.escape): const _CancelIntent(),
      },
      actions: {
        _GrabIntent: CallbackAction<_GrabIntent>(
          onInvoke: (_) {
            if (particle.container == BaaParticleContainer.atom) {
              model.removeToBucket(particle);
            } else if (particle.container == BaaParticleContainer.bucket) {
              model.beginDrag(particle, modelX: 0, modelY: -40);
              model.endDrag(particle, 0, 0);
            }
            return null;
          },
        ),
        _DeleteIntent: CallbackAction<_DeleteIntent>(
          onInvoke: (_) {
            if (particle.container == BaaParticleContainer.atom) {
              model.removeToBucket(particle);
            }
            return null;
          },
        ),
        _NavIntent: CallbackAction<_NavIntent>(
          onInvoke: (intent) {
            final scope = FocusScope.of(context);
            if (intent.direction > 0) {
              scope.nextFocus();
            } else {
              scope.previousFocus();
            }
            return null;
          },
        ),
        _CancelIntent: CallbackAction<_CancelIntent>(
          onInvoke: (_) {
            if (particle.isDragging) {
              model.endDrag(particle, particle.x, particle.y);
            }
            return null;
          },
        ),
      },
      child: _FocusRing(
        diameter: visualDiameter,
        child: Center(
          child: ParticleSphereWidget(
            type: particle.type,
            scale: visualDiameter /
                (2 * ParticleSpherePainter.radiusFor(particle.type)),
            dragging: dragging,
          ),
        ),
      ),
    );
  }
}

class _FocusRing extends StatelessWidget {
  const _FocusRing({required this.diameter, required this.child});
  final double diameter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final focused = Focus.maybeOf(context)?.hasFocus ?? false;
    return DecoratedBox(
      decoration: focused
          ? BoxDecoration(
              border: Border.all(color: const Color(0xFF1177AA), width: 2),
              borderRadius: BorderRadius.circular(diameter),
            )
          : const BoxDecoration(),
      child: child,
    );
  }
}

class _GrabIntent extends Intent {
  const _GrabIntent();
}

class _DeleteIntent extends Intent {
  const _DeleteIntent();
}

class _NavIntent extends Intent {
  const _NavIntent(this.direction);
  final int direction;
}

class _CancelIntent extends Intent {
  const _CancelIntent();
}

class _ShellRingsPainter extends CustomPainter {
  _ShellRingsPainter({
    required this.center,
    required this.innerR,
    required this.outerR,
  });

  final Offset center;
  final double innerR;
  final double outerR;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF1565C0);
    _dashedCircle(canvas, center, innerR, paint);
    _dashedCircle(canvas, center, outerR, paint);
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final circ = 2 * 3.141592653589793 * r;
    final n = (circ / (dash + gap)).floor();
    for (var i = 0; i < n; i++) {
      final a0 = i * (dash + gap) / r;
      final a1 = a0 + dash / r;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        a0,
        a1 - a0,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShellRingsPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.innerR != innerR ||
      oldDelegate.outerR != outerR;
}

class _NucleusXPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFE67E22)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), p);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
