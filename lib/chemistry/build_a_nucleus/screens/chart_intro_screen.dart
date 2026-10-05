/// Chart Intro 正式 Screen：只组合已有 Controller / Widget / Clock。
///
/// 布局对标 joist `layoutBounds` 1024×618 + 原版 `ChartIntroScreenView` 锚点，
/// 再用 [FittedBox] 等比装进视口（范式 B），不把壳层塞进 NineGrid 中心格。
library;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../../../common/widgets/kratos_reset_all_button.dart';
import '../ban_constants.dart';
import '../chart_intro/chart_intro_visuals.dart';
import '../chart_intro/controller/chart_intro_controller.dart';
import '../chart_intro/render/periodic_table_panel_geometry.dart';
import '../chart_intro/render/shell_layout.dart';
import '../chart_intro/render/shell_nucleus_render.dart';
import '../chart_intro/widgets/chart_intro_count_panel.dart';
import '../chart_intro/widgets/chart_intro_nucleon_controls.dart';
import '../chart_intro/widgets/chart_intro_status_text.dart';
import '../chart_intro/widgets/chart_intro_symbol_view.dart';
import '../chart_intro/widgets/mini_atom_view.dart';
import '../chart_intro/widgets/nuclide_chart_view.dart';
import '../chart_intro/widgets/shell_nucleus_view.dart';
import '../data/nuclide_data_loader.dart';
import '../model/nucleon.dart';

class ChartIntroScreen extends StatefulWidget {
  const ChartIntroScreen({
    super.key,
    this.controller,
    this.tickOnClock = true,
    this.embedded = false,
  });

  final ChartIntroController? controller;
  final bool tickOnClock;
  final bool embedded;

  @override
  State<ChartIntroScreen> createState() => _ChartIntroScreenState();
}

class _ChartIntroScreenState extends State<ChartIntroScreen>
    with TickerProviderStateMixin {
  ChartIntroController? _owned;
  late final SimulationClock _clock;

  ChartIntroController? get controller => widget.controller ?? _owned;

  @override
  void initState() {
    super.initState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => controller?.tick(dt);
    if (widget.tickOnClock) _clock.play();
    if (widget.controller == null) {
      NuclideDataLoader.load().then((repo) {
        if (!mounted) return;
        setState(() => _owned = ChartIntroController(repository: repo));
      });
    }
  }

  @override
  void dispose() {
    _clock.pause();
    _clock.dispose();
    _owned?.dispose();
    _owned = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final body = KeyedSubtree(
      key: const ValueKey('chart_intro_screen'),
      child: c == null
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: c,
              builder: (context, _) => _ChartIntroStage(controller: c),
            ),
    );
    if (widget.embedded) return _playBackground(body);
    return Scaffold(
      backgroundColor: ChartIntroVisuals.screenBackground,
      appBar: AppBar(title: const Text('构建原子核 · Chart Intro')),
      body: body,
    );
  }

  Widget _playBackground(Widget child) {
    return ColoredBox(
      color: ChartIntroVisuals.screenBackground,
      child: child,
    );
  }
}

/// 固定 1024×618 舞台。外层 FittedBox.contain 随视口缩放。
///
/// 锚点 [已确认] `ChartIntroScreenView`：mini-atom 中心 (W/3, 87)，
/// 壳层原点 (135, 245)，右栏约 1/3 宽。
class _ChartIntroStage extends StatefulWidget {
  const _ChartIntroStage({required this.controller});

  final ChartIntroController controller;

  static const double layoutW = BanConstants.screenViewLayoutWidth;
  static const double layoutH = 618;
  static const double atomCx = layoutW / 3;
  static const double miniAtomSize = 180;
  static const double miniAtomY = 87;
  static const double rightPaneRight = 12;
  static const double creatorBottom = 18;
  static const double shellLeft = 135;
  static const double shellTop = 245;

  @override
  State<_ChartIntroStage> createState() => _ChartIntroStageState();
}

class _ChartIntroStageState extends State<_ChartIntroStage> {
  bool _showMagicNumbers = false;
  bool _accordionExpanded = true;
  final GlobalKey _stageKey = GlobalKey();
  Offset? _dragLocal;

  void _resetAll() {
    widget.controller.reset();
    setState(() {
      _showMagicNumbers = false;
      _accordionExpanded = true;
      _dragLocal = null;
    });
  }

  Offset _toStage(Offset global) {
    final box = _stageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (widget.controller.creatorDragType == null) return;
    setState(() => _dragLocal = _toStage(e.position));
  }

  void _onPointerEnd(PointerEvent e) {
    if (widget.controller.creatorDragType == null) return;
    final local = _toStage(e.position);
    final shell = widget.controller.shellRender;
    final hit = Rect.fromLTWH(
      _ChartIntroStage.shellLeft,
      _ChartIntroStage.shellTop,
      shell.contentSize.width,
      shell.contentSize.height,
    );
    widget.controller.endCreatorDrag(inShell: hit.contains(local));
    setState(() => _dragLocal = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final s = c.state;
    final caption = ChartIntroStatusText.elementCaption(s);
    final tableInner = PeriodicTablePanelGeometry.contentSize;
    final tableW = tableInner.width + ChartIntroVisuals.panelXMargin * 2 + 2;
    final tableH = tableInner.height + ChartIntroVisuals.panelYMargin * 2 + 2;
    final mini =
        _ChartIntroStage.miniAtomSize * ChartIntroVisuals.miniAtomScale;
    final shell = ShellNucleusRender.from(s, fades: c.fades);
    final shellSize = shell.contentSize;

    return ColoredBox(
      color: ChartIntroVisuals.screenBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          key: _stageKey,
          width: _ChartIntroStage.layoutW,
          height: _ChartIntroStage.layoutH,
          child: Listener(
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerEnd,
            onPointerCancel: _onPointerEnd,
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ShellTentPainter(
                      atom: Offset(
                        _ChartIntroStage.atomCx,
                        _ChartIntroStage.miniAtomY,
                      ),
                      shellOrigin: const Offset(
                        _ChartIntroStage.shellLeft,
                        _ChartIntroStage.shellTop,
                      ),
                      contentOrigin: shell.contentOrigin,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (caption.isNotEmpty)
                      Text(
                        caption,
                        key: const ValueKey('chart_intro_element'),
                        style: const TextStyle(
                          color: ChartIntroVisuals.elementNameColor,
                          fontSize: ChartIntroVisuals.regularFontSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ChartIntroCountPanel(state: s),
                  ],
                ),
              ),
              Positioned(
                left: _ChartIntroStage.atomCx - mini / 2,
                top: _ChartIntroStage.miniAtomY - mini / 2,
                width: mini,
                height: mini,
                child: FittedBox(
                  child: MiniAtomView.fromState(s, c.repository),
                ),
              ),
              Positioned(
                right: _ChartIntroStage.rightPaneRight,
                top: 8,
                width: tableW,
                bottom: 8,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: tableW,
                        height: tableH,
                        child: PeriodicTableAndSymbolView.fromState(
                          s,
                          c.repository.table.elements,
                          key: const ValueKey('chart_intro_periodic_table'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          KeyedSubtree(
                            key: const ValueKey('chart_intro_chart'),
                            child: ChartIntroChartPanel(
                              controller: c,
                              showMagicNumbers: _showMagicNumbers,
                              accordionExpanded: _accordionExpanded,
                              onMagicChanged: (v) =>
                                  setState(() => _showMagicNumbers = v),
                              onAccordionToggle: () => setState(
                                () =>
                                    _accordionExpanded = !_accordionExpanded,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: KratosResetAllButton(
                              key: const ValueKey('chart_intro_reset'),
                              onPressed: _resetAll,
                              radius: 20.5,
                              tooltip: 'Reset',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 40,
                top: 175,
                width: 40,
                bottom: 90,
                child: IgnorePointer(child: _EnergyAxis()),
              ),
              Positioned(
                left: _ChartIntroStage.shellLeft,
                top: _ChartIntroStage.shellTop,
                child: IgnorePointer(
                  child: ShellNucleusView.fromState(s, fades: c.fades),
                ),
              ),
              Positioned(
                left: _ChartIntroStage.shellLeft +
                    shellSize.width / 2 -
                    110,
                top: _ChartIntroStage.shellTop + shellSize.height + 4,
                width: 220,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ChartIntroVisuals.nuclearShellModelFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      ChartIntroVisuals.nuclearShellModelLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ChartIntroVisuals.regularFontSize,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _ChartIntroStage.atomCx,
                bottom: _ChartIntroStage.creatorBottom,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: ChartIntroNucleonControls(controller: c),
                ),
              ),
              if (_dragLocal != null && c.creatorDragType != null)
                Positioned(
                  left: _dragLocal!.dx - BanConstants.nucleonRadius,
                  top: _dragLocal!.dy - BanConstants.nucleonRadius,
                  child: IgnorePointer(
                    child: Container(
                      width: BanConstants.nucleonRadius * 2,
                      height: BanConstants.nucleonRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(
                            c.creatorDragType == NucleonType.proton
                                ? BanConstants.protonColorValue
                                : BanConstants.neutronColorValue,
                          ),
                        ),
                        gradient: RadialGradient(
                          center: const Alignment(-0.4, -0.4),
                          radius: 1.6,
                          colors: [
                            Colors.white,
                            Color(
                              c.creatorDragType == NucleonType.proton
                                  ? BanConstants.protonColorValue
                                  : BanConstants.neutronColorValue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

/// [已确认] `energyText` 竖排 + 上指 ArrowNode。
class _EnergyAxis extends StatelessWidget {
  const _EnergyAxis();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: Center(
            child: Text(
              ChartIntroVisuals.energyAxisLabel,
              style: TextStyle(fontSize: ChartIntroVisuals.regularFontSize),
            ),
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: CustomPaint(painter: _EnergyArrowPainter()),
        ),
      ],
    );
  }
}

class _EnergyArrowPainter extends CustomPainter {
  const _EnergyArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, size.height), Offset(x, 10), p);
    final head = Path()
      ..moveTo(x, 0)
      ..lineTo(x - 7, 12)
      ..lineTo(x + 7, 12)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShellTentPainter extends CustomPainter {
  const _ShellTentPainter({
    required this.atom,
    required this.shellOrigin,
    required this.contentOrigin,
  });

  final Offset atom;
  final Offset shellOrigin;
  final Offset contentOrigin;

  @override
  void paint(Canvas canvas, Size size) {
    final dash = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final proton = shellOrigin +
        contentOrigin +
        Offset(ShellLayout.viewWidth / 2, 0);
    final neutron = proton + Offset(ChartIntroVisuals.energyLevelColumnGap, 0);
    _dashed(canvas, atom, proton, dash);
    _dashed(canvas, atom, neutron, dash);
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const on = 6.0;
    const off = 4.0;
    final d = b - a;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    var t = 0.0;
    while (t < len) {
      final t2 = (t + on).clamp(0.0, len);
      canvas.drawLine(a + dir * t, a + dir * t2, paint);
      t += on + off;
    }
  }

  @override
  bool shouldRepaint(covariant _ShellTentPainter old) =>
      old.atom != atom ||
      old.shellOrigin != shellOrigin ||
      old.contentOrigin != contentOrigin;
}

