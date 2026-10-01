import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../model/bce_element.dart';
import '../model/bce_molecule.dart';
import '../views/bce_molecule_node.dart';

/// PhET `BCERewardNode` ← vegas `RewardNode`.
///
/// 150 falling nodes; L1 atoms / L2 molecules / L3 faces+stars.
/// Speed: `(random + 1) * MAX_SPEED` with `MAX_SPEED = 200` px/s; wrap to top.
class BceRewardNode extends StatefulWidget {
  const BceRewardNode({
    super.key,
    required this.levelNumber,
    this.random,
  });

  /// 1-based game level.
  final int levelNumber;
  final math.Random? random;

  static const numberOfNodes = 150;
  static const maxSpeed = 200.0;

  @override
  State<BceRewardNode> createState() => _BceRewardNodeState();
}

class _BceRewardNodeState extends State<BceRewardNode>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final math.Random _random;
  late List<_RewardParticle> _particles;
  Duration _last = Duration.zero;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _random = widget.random ?? math.Random();
    _particles = _createParticles(const Size(768, 504));
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_disposed || !mounted) return;
    final dt = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.1) {
      setState(() {});
      return;
    }
    setState(() {
      for (final p in _particles) {
        p.y += p.speed * dt;
        if (p.y > p.boundsHeight + 40) {
          p.x = _random.nextDouble() * p.boundsWidth;
          p.y = -_random.nextDouble() * p.boundsHeight * 2 -
              BceRewardNode.maxSpeed;
        }
      }
    });
  }

  List<_RewardParticle> _createParticles(Size bounds) {
    final kinds = _kindsForLevel(widget.levelNumber);
    return List.generate(BceRewardNode.numberOfNodes, (i) {
      final kind = kinds[i % kinds.length];
      return _RewardParticle(
        kind: kind,
        x: _random.nextDouble() * bounds.width,
        y: -_random.nextDouble() * bounds.height * 2 - BceRewardNode.maxSpeed,
        speed: (_random.nextDouble() + 1) * BceRewardNode.maxSpeed,
        boundsWidth: bounds.width,
        boundsHeight: bounds.height,
      );
    });
  }

  List<_RewardKind> _kindsForLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return [
          for (final e in [
            BceElement.c,
            BceElement.cl,
            BceElement.f,
            BceElement.h,
            BceElement.n,
            BceElement.o,
            BceElement.p,
            BceElement.s,
          ])
            _RewardKind.atom(e),
        ];
      case 2:
        return [
          for (final m in [
            BceMolecule.c,
            BceMolecule.c2h2,
            BceMolecule.c2h4,
            BceMolecule.h2o,
            BceMolecule.o2,
            BceMolecule.n2,
            BceMolecule.nh3,
            BceMolecule.co2,
            BceMolecule.ch4,
            BceMolecule.hCl,
          ])
            _RewardKind.molecule(m),
        ];
      default:
        return const [_RewardKind.face, _RewardKind.star];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 768.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 504.0;
        for (final p in _particles) {
          p.boundsWidth = w;
          p.boundsHeight = h;
        }
        return IgnorePointer(
          child: CustomPaint(
            size: Size(w, h),
            painter: _RewardPainter(particles: List.of(_particles)),
          ),
        );
      },
    );
  }
}

enum _RewardType { atom, molecule, face, star }

class _RewardKind {
  const _RewardKind._(this.type, {this.element, this.molecule});
  factory _RewardKind.atom(BceElement e) =>
      _RewardKind._(_RewardType.atom, element: e);
  factory _RewardKind.molecule(BceMolecule m) =>
      _RewardKind._(_RewardType.molecule, molecule: m);
  static const face = _RewardKind._(_RewardType.face);
  static const star = _RewardKind._(_RewardType.star);

  final _RewardType type;
  final BceElement? element;
  final BceMolecule? molecule;
}

class _RewardParticle {
  _RewardParticle({
    required this.kind,
    required this.x,
    required this.y,
    required this.speed,
    required this.boundsWidth,
    required this.boundsHeight,
  });

  final _RewardKind kind;
  double x;
  double y;
  final double speed;
  double boundsWidth;
  double boundsHeight;
}

class _RewardPainter extends CustomPainter {
  _RewardPainter({required this.particles});
  final List<_RewardParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      switch (p.kind.type) {
        case _RewardType.atom:
          _paintShadedSphere(canvas, p.kind.element!, scale: 0.55);
        case _RewardType.molecule:
          _paintMolecule(canvas, p.kind.molecule!);
        case _RewardType.face:
          _paintFace(canvas);
        case _RewardType.star:
          _paintStar(canvas);
      }
      canvas.restore();
    }
  }

  void _paintShadedSphere(Canvas canvas, BceElement element, {double scale = 1}) {
    final d = BceAtomLayout(element, Offset.zero).diameter * scale;
    final r = d / 2;
    final c = Offset(r, r);
    final base = Color(element.colorArgb);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(c.dx - r * 0.35, c.dy - r * 0.35),
          r * 1.2,
          [
            Color.lerp(base, Colors.white, 0.55)!,
            base,
            Color.lerp(base, Colors.black, 0.25)!,
          ],
          const [0.0, 0.45, 1.0],
        ),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  void _paintMolecule(Canvas canvas, BceMolecule molecule) {
    const scale = 0.45;
    final atoms = BceMoleculeNode.layoutsFor(molecule);
    if (atoms.isEmpty) return;
    var minX = double.infinity, minY = double.infinity;
    for (final a in atoms) {
      final r = a.diameter / 2;
      minX = math.min(minX, a.center.dx - r);
      minY = math.min(minY, a.center.dy - r);
    }
    canvas.save();
    canvas.scale(scale);
    canvas.translate(-minX, -minY);
    final ordered = [...atoms]..sort((a, b) => b.diameter.compareTo(a.diameter));
    for (final a in ordered) {
      final r = a.diameter / 2;
      final base = Color(a.element.colorArgb);
      canvas.drawCircle(
        a.center,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(a.center.dx - r * 0.35, a.center.dy - r * 0.35),
            r * 1.2,
            [
              Color.lerp(base, Colors.white, 0.55)!,
              base,
              Color.lerp(base, Colors.black, 0.25)!,
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
      canvas.drawCircle(
        a.center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );
    }
    canvas.restore();
  }

  void _paintFace(Canvas canvas) {
    const size = 40.0;
    final c = const Offset(size / 2, size / 2);
    final r = size / 2 - 1;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFEE58));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(c.dx - r * 0.35, c.dy - r * 0.15),
      2.5,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(c.dx + r * 0.35, c.dy - r * 0.15),
      2.5,
      Paint()..color = Colors.black,
    );
    final mouth = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * 0.1),
          width: r,
          height: r * 0.7,
        ),
        0.2,
        2.7,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  void _paintStar(Canvas canvas) {
    const size = 28.0;
    final cx = size / 2;
    final cy = size / 2;
    final outer = size / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD700));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black54,
    );
  }

  @override
  bool shouldRepaint(covariant _RewardPainter oldDelegate) => true;
}
