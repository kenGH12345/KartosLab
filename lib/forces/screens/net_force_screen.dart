import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../common/simulation_clock.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
import '../famb_assets.dart';
import '../widgets/famb_picture.dart';
import '../model/famb_constants.dart';
import '../model/net_force_model.dart';

/// PhET Net Force (Tug of War) ? layout bounds 981?604.
class NetForceScreen extends StatefulWidget {
  const NetForceScreen({super.key});

  @override
  State<NetForceScreen> createState() => _NetForceScreenState();
}

class _NetForceScreenState extends State<NetForceScreen>
    with TickerProviderStateMixin {
  static const double W = 981;
  static const double H = 604;
  static const double skyH = 376;
  static const double grassY = 368;
  static const double centerX = 490.5;

  late final NetForceModel model;
  late final SimulationClock clock;
  AudioPlayer? _clap;
  bool _clapPlayed = false;

  Puller? dragging;
  Offset? dragPos;
  int? hoverKnot;

  AudioPlayer get _clapPlayer => _clap ??= AudioPlayer();

  @override
  void initState() {
    super.initState();
    model = NetForceModel();
    clock = SimulationClock(fps: 60);
    clock.attach(this);
    clock.onTick = (dt, _) {
      model.step(dt);
      if (model.isCompleted && !_clapPlayed) {
        _clapPlayed = true;
        // Ignore missing plugin in widget tests / unsupported platforms.
        _clapPlayer.play(AssetSource(
          'simulations/forces_and_motion_basics/sounds/golfClap.mp3',
        )).catchError((_) {});
      }
      if (mounted) setState(() {});
    };
    clock.play(); // wall clock always runs; physics gated by model.isRunning
  }

  @override
  void dispose() {
    clock.dispose();
    _clap?.dispose();
    super.dispose();
  }

  String _pullerColor(Puller p) {
    final blueRed = model.colorScheme == PullerColorScheme.blueRed;
    if (p.team == PullerTeam.left) return blueRed ? 'BLUE' : 'PURPLE';
    return blueRed ? 'RED' : 'ORANGE';
  }

  String _sizePrefix(PullerSize s) {
    switch (s) {
      case PullerSize.large:
        return 'lrg';
      case PullerSize.medium:
        return '';
      case PullerSize.small:
        return 'small';
    }
  }

  /// Pose 0 = standing, 3 = leaning (PhET PullerNode).
  int _pose(Puller p) {
    final leaning = model.hasStarted &&
        p.isAttached &&
        !model.isCompleted &&
        dragging != p;
    return leaning ? 3 : 0;
  }

  String _pullerAsset(Puller p) => FambAssets.puller(
        color: _pullerColor(p),
        size: _sizePrefix(p.size),
        pose: _pose(p),
      );

  Offset _homePos(Puller p) {
    // PhET toolbox home positions (top-left of figure).
    const homes = <String, Offset>{
      'largeLeft': Offset(38, 394),
      'mediumLeft': Offset(127, 426),
      'smallLeft1': Offset(208, 473),
      'smallLeft2': Offset(278, 473),
      'smallRight1': Offset(648, 473),
      'smallRight2': Offset(717, 473),
      'mediumRight': Offset(789, 426),
      'largeRight': Offset(860, 394),
    };
    return homes[p.id] ?? const Offset(100, 450);
  }

  Size _pullerDisplaySize(Puller p) {
    // PhET PullerNode scale 0.86 ? intrinsic PNG size.
    switch (p.size) {
      case PullerSize.large:
        return const Size(86 * 0.86, 233 * 0.86); // ~74?200
      case PullerSize.medium:
        return const Size(70 * 0.86, 195 * 0.86); // ~60?168
      case PullerSize.small:
        return const Size(61 * 0.86, 141 * 0.86); // ~52?121
    }
  }

  Offset _attachedPos(Puller p) {
    final knotX = model.knotX(p.team, p.knotIndex!);
    final sz = _pullerDisplaySize(p);
    // PhET: x = knot.x + offset + (blue?-50:0); y = knot.y - height + 90
    final dx = p.team == PullerTeam.left ? -50.0 : 0.0;
    return Offset(knotX + dx - sz.width / 2, NetForceConstants.knotY - sz.height + 90);
  }

  Offset _pullerPos(Puller p) {
    if (dragging == p && dragPos != null) return dragPos!;
    if (p.isAttached) return _attachedPos(p);
    return _homePos(p);
  }

  void _onDragStart(Puller p, Offset local) {
    setState(() {
      dragging = p;
      dragPos = local;
      if (p.isAttached) model.detachPuller(p);
    });
  }

  void _onDragUpdate(Offset local) {
    if (dragging == null) return;
    setState(() {
      dragPos = local;
      hoverKnot = _nearestKnot(dragging!, local);
    });
  }

  int? _nearestKnot(Puller p, Offset local) {
    final cy = local.dy + _pullerDisplaySize(p).height / 2;
    if (cy > 370) return null; // too low ??home
    int? best;
    var bestDist = 220.0;
    for (var i = 0; i < NetForceConstants.knotsPerSide; i++) {
      final kx = model.knotX(p.team, i);
      final d = (local.dx + _pullerDisplaySize(p).width / 2 - kx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  void _onDragEnd() {
    final p = dragging;
    if (p == null) return;
    final knot = hoverKnot;
    setState(() {
      if (knot != null) {
        model.attachPuller(p, knot);
      }
      dragging = null;
      dragPos = null;
      hoverKnot = null;
    });
  }

  void _toggleGo() {
    setState(() {
      if (model.isRunning) {
        model.pause();
      } else {
        model.go();
      }
    });
  }

  void _returnCart() {
    setState(() {
      model.returnCart();
      _clapPlayed = false;
    });
  }

  void _resetAll() {
    setState(() {
      model.resetAll();
      _clapPlayed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(constraints.maxWidth / W, constraints.maxHeight / H);
        return Material(
          color: const Color(0xFFC59A5B),
          child: Center(
            child: SizedBox(
              width: W * scale,
              height: H * scale,
              child: FittedBox(
                child: SizedBox(
                  width: W,
                  height: H,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildSky(),
                      _buildGround(),
                      _buildGrass(),
                      _buildCaret(),
                      _buildStoppers(),
                      _buildRope(),
                      _buildCart(),
                      _buildForceArrows(),
                      if (model.showSpeed) _buildSpeedometer(),
                      if (model.isCompleted) _buildFlag(),
                      _buildToolboxes(),
                      ..._buildKnotHighlights(),
                      ..._buildPullers(),
                      _buildGoReturn(),
                      _buildControlPanel(),
                      Positioned(
                        right: 10,
                        top: 10 + 118 + 10,
                        child: KratosResetAllButton(
                          onPressed: _resetAll,
                          radius: 23,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSky() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: skyH,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF02ACE4), Color(0xFFCFECFC)],
          ),
        ),
      ),
    );
  }

  Widget _buildGround() {
    return const Positioned(
      top: skyH,
      left: 0,
      right: 0,
      bottom: 0,
      child: ColoredBox(color: Color(0xFFC59A5B)),
    );
  }

  Widget _buildGrass() {
    return Positioned(
      top: grassY,
      left: 0,
      right: 0,
      height: 12,
      child: Image.asset(
        FambAssets.grass,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _buildCaret() {
    return Positioned(
      left: centerX - 6,
      top: grassY + 10,
      child: const CustomPaint(
        size: Size(12, 10),
        painter: _CaretPainter(),
      ),
    );
  }

  Widget _buildStoppers() {
    Widget stopper(double left) => Positioned(
          left: left,
          top: grassY + 5,
          child: CustomPaint(
            size: const Size(30, 24),
            painter: _StopperPainter(),
          ),
        );
    return Stack(children: [
      stopper(centerX - NetForceConstants.gameLength - 15),
      stopper(centerX + NetForceConstants.gameLength - 15),
    ]);
  }

  Widget _buildRope() {
    // PhET: scale = (1130.2 * 0.78) / 2356 ? 0.374; y=273; x = cart.x + 51
    const scale = (1130.2 * 0.78) / 2356;
    const ropeW = 2356 * scale;
    const ropeH = 56 * scale;
    final x = model.cartPosition + 51;
    return Positioned(
      left: x,
      top: 273,
      width: ropeW,
      height: ropeH,
      child: Image.asset(
        FambAssets.rope,
        width: ropeW,
        height: ropeH,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _buildCart() {
    final x = model.cartPosition + 412;
    return Positioned(
      left: x,
      top: 221,
      child: const FambPicture(FambAssets.cart, height: 80),
    );
  }

  Widget _buildSpeedometer() {
    return Positioned(
      left: centerX - 55 + model.cartPosition,
      top: 150,
      child: _NetForceGauge(speed: model.speed),
    );
  }

  Widget _buildFlag() {
    final leftWins = model.winner == 'left';
    final blueRed = model.colorScheme == PullerColorScheme.blueRed;
    final color = leftWins
        ? (blueRed ? Colors.blue : const Color(0xFF8A2BE2))
        : (blueRed ? Colors.red : const Color(0xFFFF5500));
    final label = leftWins
        ? (blueRed ? 'Blue Wins!' : 'Purple Wins!')
        : (blueRed ? 'Red Wins!' : 'Orange Wins!');
    return Positioned(
      left: centerX - 110,
      top: 8,
      child: Container(
        width: 220,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black54, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildToolboxes() {
    Widget box(double left) => Positioned(
          left: left,
          top: H - 216 - 4,
          width: 324,
          height: 216,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE7E8E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF9E9E9E)),
            ),
          ),
        );
    return Stack(children: [box(25), box(630)]);
  }

  List<Widget> _buildKnotHighlights() {
    if (dragging == null || hoverKnot == null) return [];
    final kx = model.knotX(dragging!.team, hoverKnot!);
    return [
      Positioned(
        left: kx - 20,
        top: NetForceConstants.knotY - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 4),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPullers() {
    final widgets = <Widget>[];
    for (final p in model.pullers) {
      if (dragging == p) continue;
      widgets.add(_pullerWidget(p));
    }
    if (dragging != null) widgets.add(_pullerWidget(dragging!));
    return widgets;
  }

  Widget _pullerWidget(Puller p) {
    final pos = _pullerPos(p);
    final sz = _pullerDisplaySize(p);
    final mirror = p.team == PullerTeam.right;
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: sz.width,
      height: sz.height,
      child: GestureDetector(
        onPanStart: (_) => _onDragStart(p, pos),
        onPanUpdate: (d) {
          if (dragPos == null) return;
          _onDragUpdate(dragPos! + d.delta);
        },
        onPanEnd: (_) => _onDragEnd(),
        onPanCancel: _onDragEnd,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(mirror ? -1.0 : 1.0, 1, 1),
          child: Image.asset(
            _pullerAsset(p),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => ColoredBox(
              color: p.team == PullerTeam.left
                  ? const Color(0xFF1565C0)
                  : const Color(0xFFC62828),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForceArrows() {
    final showLeft = model.leftForce.abs() > 1e-6;
    final showRight = model.rightForce.abs() > 1e-6;
    final showSum = model.showSumOfForces && model.netForce.abs() > 1e-6;
    final dashed = !model.isRunning;

    return Stack(
      children: [
        if (showLeft)
          Positioned(
            left: centerX - model.leftForce.abs(),
            top: 200 - 20,
            child: _ForceArrow(
              length: model.leftForce.abs(),
              toLeft: true,
              color: const Color(0xFFBF8B63),
              dashed: dashed,
              label: model.showValues
                  ? '${model.leftForce.abs().round()} N'
                  : null,
            ),
          ),
        if (showRight)
          Positioned(
            left: centerX,
            top: 200 - 20,
            child: _ForceArrow(
              length: model.rightForce.abs(),
              toLeft: false,
              color: const Color(0xFFBF8B63),
              dashed: dashed,
              label: model.showValues
                  ? '${model.rightForce.abs().round()} N'
                  : null,
            ),
          ),
        if (showSum)
          Positioned(
            left: model.netForce < 0
                ? centerX - model.netForce.abs()
                : centerX,
            top: 127 - 20,
            child: _ForceArrow(
              length: model.netForce.abs(),
              toLeft: model.netForce < 0,
              color: const Color(0xFF7DC673),
              dashed: dashed,
              label: model.showValues
                  ? '${model.netForce.abs().round()} N'
                  : 'Sum of Forces',
            ),
          ),
        if (model.showSumOfForces && model.netForce.abs() <= 1e-6)
          const Positioned(
            left: centerX - 60,
            top: 102,
            child: Text(
              'Sum of Forces = 0',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildGoReturn() {
    final canGo = (model.hasAttachedPullers || model.isRunning) &&
        !model.isCompleted;
    // PhET GoPauseButton: Go base #94b830, Pause base #ff5500
    final fill = model.isRunning
        ? const Color(0xFFFF5500)
        : const Color(0xFF94B830);
    return Stack(
      children: [
        Positioned(
          left: centerX - 50,
          top: 400,
          child: GestureDetector(
            onTap: canGo ? _toggleGo : null,
            child: Opacity(
              opacity: canGo ? 1 : 0.45,
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF555555), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  model.isRunning ? 'Pause' : 'Go!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: centerX - 45,
          top: 400 + 100 + 10,
          child: GestureDetector(
            onTap: model.hasStarted ? _returnCart : null,
            child: Opacity(
              opacity: model.hasStarted ? 1 : 0.4,
              child: Container(
                width: 90,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // PhET ReturnButton baseColor rgb(254,192,0)
                  color: const Color.fromRGBO(254, 192, 0, 1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black54),
                ),
                child: const Text(
                  'Return',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      right: 10,
      top: 10,
      child: Theme(
        data: Theme.of(context).copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.white;
            }),
            checkColor: WidgetStateProperty.all(Colors.black),
            side: const BorderSide(color: Colors.black, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Container(
        width: 160,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E980),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _check(
              'Sum of Forces',
              model.showSumOfForces,
              (v) => setState(() => model.showSumOfForces = v),
            ),
            _check(
              'Values',
              model.showValues,
              (v) => setState(() => model.showValues = v),
            ),
            _check(
              'Speed',
              model.showSpeed,
              (v) => setState(() => model.showSpeed = v),
              trailing: CustomPaint(
                size: const Size(22, 14),
                painter: _MiniSpeedIconPainter(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _ForceArrow extends StatelessWidget {
  const _ForceArrow({
    required this.length,
    required this.toLeft,
    required this.color,
    required this.dashed,
    this.label,
  });

  final double length;
  final bool toLeft;
  final Color color;
  final bool dashed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final w = length.clamp(0, 350).toDouble();
    return SizedBox(
      width: w,
      height: 40,
      child: CustomPaint(
        painter: _ArrowPainter(
          toLeft: toLeft,
          color: color.withValues(alpha: 0.8),
          dashed: dashed,
        ),
        child: label == null
            ? null
            : Align(
                alignment: toLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.toLeft,
    required this.color,
    required this.dashed,
  });

  final bool toLeft;
  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final y = size.height / 2;
    const headW = 50.0;
    const headH = 40.0;
    const tailH = 25.0;
    final path = Path();
    if (toLeft) {
      path.moveTo(0, y);
      path.lineTo(headW, y - headH / 2);
      path.lineTo(headW, y - tailH / 2);
      path.lineTo(size.width, y - tailH / 2);
      path.lineTo(size.width, y + tailH / 2);
      path.lineTo(headW, y + tailH / 2);
      path.lineTo(headW, y + headH / 2);
      path.close();
    } else {
      path.moveTo(size.width, y);
      path.lineTo(size.width - headW, y - headH / 2);
      path.lineTo(size.width - headW, y - tailH / 2);
      path.lineTo(0, y - tailH / 2);
      path.lineTo(0, y + tailH / 2);
      path.lineTo(size.width - headW, y + tailH / 2);
      path.lineTo(size.width - headW, y + headH / 2);
      path.close();
    }
    if (dashed) {
      // Approximate dashed stroke outline
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, stroke);
      canvas.drawPath(path, paint..color = color.withValues(alpha: 0.35));
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.toLeft != toLeft || old.color != color || old.dashed != dashed;
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StopperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF555555);
    final path = Path()
      ..moveTo(size.width / 2 - 5.5, 0)
      ..lineTo(size.width / 2 + 5.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniSpeedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height);
    final r = size.height * 0.85;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = const Color(0xFF455A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      c,
      Offset(c.dx + r * 0.5, c.dy - r * 0.6),
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NetForceGauge extends StatelessWidget {
  const _NetForceGauge({required this.speed});
  final double speed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 70,
      child: CustomPaint(
        painter: _GaugePainter(speed: speed.clamp(0, 6)),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.speed});
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height - 4);
    final r = size.width * 0.4;
    final arc = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi,
      math.pi,
      false,
      arc,
    );
    final ratio = (speed / 6).clamp(0.0, 1.0);
    final angle = math.pi + ratio * math.pi;
    final tip = Offset(c.dx + (r - 8) * math.cos(angle),
        c.dy + (r - 8) * math.sin(angle));
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.speed != speed;
}
