/// Build a Nucleus · Decay 屏。
///
/// 固定 1024×618 舞台（joist DEFAULT_LAYOUT_BOUNDS），外层 FittedBox.contain。
/// 锚点对标 `DecayScreenView` / `BANScreenView`，不把 Available Decays
/// 和核子生成器塞进 NineGrid 边格（会把图标压到看不见）。
/// 作为 Tab 子页时设 [embedded]，由 [BuildANucleusHome] 提供外层 AppBar。
library;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../../../common/widgets/drag_drop_workspace.dart';
import '../../../common/widgets/kratos_reset_all_button.dart';
import '../ban_constants.dart';
import '../controller/build_a_nucleus_controller.dart';
import '../data/nuclide_data_loader.dart';
import '../model/build_a_nucleus_state.dart';
import '../model/half_life_number_line.dart';
import '../model/nucleon.dart';
import '../painters/nucleus_painter.dart';
import '../widgets/available_decays_panel.dart';
import '../widgets/decay_right_column.dart';
import '../widgets/half_life_information_view.dart';
import '../widgets/nucleon_arrow_column.dart';
import '../widgets/nuclide_status.dart';
import '../widgets/show_electron_cloud_checkbox.dart';
import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';

class BuildANucleusScreen extends StatefulWidget {
  const BuildANucleusScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  /// 测试可注入预构建控制器；为 null 时异步加载核素数据。
  final BuildANucleusController? controller;

  /// 作为 [KratosTabbedScreen] 子页时去掉本屏 AppBar，避免双层 Scaffold。
  final bool embedded;

  @override
  State<BuildANucleusScreen> createState() => _BuildANucleusScreenState();
}

class _BuildANucleusScreenState extends State<BuildANucleusScreen>
    with TickerProviderStateMixin {
  BuildANucleusController? _controller;
  late final SimulationClock _clock;

  /// 拖拽会话：pointerId → 核子（核内拖出与生成器拖出共用）。
  /// 原版支持多指同时拖多个核子（userControlled 数组）[已确认]。
  final Map<int, Nucleon> _dragSessions = {};

  /// 电子云可见性。视图层，不进 State。
  /// [已确认] ShowElectronCloudCheckbox BooleanProperty(true)
  bool _showElectronCloud = true;

  /// 画布坐标换算：最新投影 + 画布 RenderBox（生成器在 footer，
  /// 其指针事件需经 globalToLocal 换算到画布坐标系）。
  CanvasProjection? _proj;
  final GlobalKey _canvasKey = GlobalKey();
  final Map<NucleonType, GlobalKey> _creatorKeys = {
    NucleonType.proton: GlobalKey(),
    NucleonType.neutron: GlobalKey(),
  };

  BuildANucleusController? get controller => widget.controller ?? _controller;

  Offset _globalToWorld(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final proj = _proj;
    if (box == null || proj == null) return Offset.zero;
    return proj.toWorld(box.globalToLocal(global));
  }

  /// 生成器中心的世界坐标（失败 drop 的归位目的地）。
  /// [已确认] 原项目 returnParticleToStack 飞回 creatorNodeModelCenter
  Offset _creatorHome(NucleonType type) {
    final box =
        _creatorKeys[type]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return _globalToWorld(box.localToGlobal(box.size.center(Offset.zero)));
  }

  void _onCanvasPointerDown(PointerDownEvent e) {
    final c = controller;
    final proj = _proj;
    if (c == null || proj == null) return;
    final w = proj.toWorld(e.localPosition);
    final hit = c.hitTestNucleon(w.dx, w.dy);
    if (hit != null) {
      // 按下不跳位置，首次移动才对齐指针（[已确认] DragListener 行为）
      final dragged = c.beginDrag(hit);
      if (dragged != null) _dragSessions[e.pointer] = dragged;
    }
  }

  void _onCreatorPointerDown(NucleonType type, PointerDownEvent e) {
    final c = controller;
    if (c == null) return;
    // [已确认] 生成器按下即创建粒子并进入拖拽（中心对齐指针）
    final w = _globalToWorld(e.position);
    _dragSessions[e.pointer] = c.startTrayDrag(type, w.dx, w.dy);
  }

  void _onSessionMove(PointerMoveEvent e) {
    final n = _dragSessions[e.pointer];
    final c = controller;
    if (n == null || c == null) return;
    final w = _globalToWorld(e.position);
    c.moveDragged(n, w.dx, w.dy);
  }

  void _onSessionEnd(PointerEvent e) {
    final n = _dragSessions.remove(e.pointer);
    final c = controller;
    if (n == null || c == null) return;
    final w = _globalToWorld(e.position);
    c.moveDragged(n, w.dx, w.dy);
    final home = _creatorHome(n.type);
    c.endDrop(n, returnX: home.dx, returnY: home.dy);
  }

  void _reset() {
    // [已确认] ResetAllButton → model.reset 会 dispose 粒子，DragListener 拆除。
    // 本屏必须同步丢掉 pointer 会话，否则松手会走到 endNucleonDrop。
    _dragSessions.clear();
    // [已确认] DecayScreenView.reset → showElectronCloudCheckbox.reset()
    _showElectronCloud = true;
    controller?.reset();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => controller?.tick(dt);
    _clock.play();
    if (widget.controller == null) {
      NuclideDataLoader.load().then((repo) {
        if (!mounted) return;
        setState(() => _controller = BuildANucleusController(repository: repo));
      });
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final body = c == null
        ? const Center(child: CircularProgressIndicator())
        : ListenableBuilder(
            listenable: c,
            builder: (context, _) => _buildBody(c),
          );
    if (widget.embedded) return _playBackground(body);
    return Scaffold(
      backgroundColor: const Color(BanConstants.screenBackgroundValue),
      appBar: AppBar(title: const Text('构建原子核 · 衰变')),
      body: body,
    );
  }

  /// [已确认] screenBackground WHITE。只铺本屏 play，不改 Theme / 其他 sim。
  Widget _playBackground(Widget child) {
    return ColoredBox(
      color: const Color(BanConstants.screenBackgroundValue),
      child: child,
    );
  }

  Widget _buildBody(BuildANucleusController c) {
    // 注入生成器世界坐标解析（箭头飞入的起点）。
    c.creatorHomeResolver ??= _creatorHome;
    const layoutW = BanConstants.screenViewLayoutWidth;
    const layoutH = 618.0;
    final s = c.state;
    const canvasSize = Size(layoutW, layoutH);
    final proj = CanvasProjection(
      canvasSize: canvasSize,
      origin: BanConstants.atomOriginInCanvas(
        layoutWidth: layoutW,
        canvasSize: canvasSize,
      ),
    );
    _proj = proj;
    c.visibleSizeProvider ??= () => canvasSize;

    // [已确认] DecayScreenView
    // halfLife.left = minX + X_MARGIN + 30; y = minY + Y_MARGIN + 80
    // symbol.right = maxX - X_MARGIN; symbol.top = minY + Y_MARGIN
    // availableDecays.right = symbol.right; top = symbol.bottom + 10
    // creators.centerX = atomCenter.x; bottom = maxY - Y_MARGIN
    const xMargin = BanConstants.screenViewXMargin;
    const yMargin = BanConstants.screenViewYMargin;
    const panelW = 322.0;
    const halfLifeLeft =
        xMargin + BanConstants.halfLifeInformationExtraLeft;
    const halfLifeY = yMargin + 80;
    const halfLifeW = BanConstants.halfLifeNumberLineWidth;
    final halfLifeCx =
        BanConstants.halfLifeInformationCenterXForLayout(layoutW);
    const decaysTop = yMargin + 148;
    const atomCx = layoutW / 3;

    return ColoredBox(
      color: const Color(BanConstants.screenBackgroundValue),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: layoutW,
          height: layoutH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: KeyedSubtree(
                  key: const ValueKey('ban_canvas'),
                  child: Listener(
                    key: _canvasKey,
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: _onCanvasPointerDown,
                    onPointerMove: _onSessionMove,
                    onPointerUp: _onSessionEnd,
                    onPointerCancel: _onSessionEnd,
                    child: CustomPaint(
                      painter: NucleusPainter(
                        state: s,
                        proj: proj,
                        showElectronCloud: _showElectronCloud,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: halfLifeLeft,
                top: halfLifeY,
                width: halfLifeW,
                child: HalfLifeInformationView(
                  reading: HalfLifeNumberLine.fromState(s),
                  elementName: NuclideStatusText.elementCaption(s),
                ),
              ),
              Positioned(
                left: halfLifeCx,
                top: decaysTop,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: ElementAndStabilityReadout(state: s),
                ),
              ),
              Positioned(
                right: xMargin,
                top: yMargin,
                width: panelW,
                bottom: 72,
                child: DecayRightColumn(
                  state: s,
                  decays: AvailableDecaysPanel(controller: c),
                ),
              ),
              Positioned(
                left: layoutW - xMargin - panelW,
                bottom: yMargin,
                child: ShowElectronCloudCheckbox(
                  value: _showElectronCloud,
                  onChanged: (v) => setState(() => _showElectronCloud = v),
                ),
              ),
              Positioned(
                right: xMargin,
                bottom: yMargin,
                child: KratosResetAllButton(
                  key: const ValueKey('ban_reset'),
                  onPressed: _reset,
                  radius: 20.5,
                  tooltip: '重置',
                ),
              ),
              Positioned(
                left: atomCx,
                bottom: yMargin,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: _nucleonCreatorsRow(c, s),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nucleonCreatorsRow(
    BuildANucleusController c,
    BuildANucleusState s,
  ) {
    return Row(
      key: const ValueKey('ban_nucleon_creators'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        NucleonArrowColumn(
          upKey: const ValueKey('ban_add_proton'),
          downKey: const ValueKey('ban_remove_proton'),
          color: const Color(BanConstants.protonColorValue),
          onUp: s.canAddProton ? c.addProton : null,
          onDown: s.canRemoveProton ? c.removeProton : null,
        ),
        const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
        _CreatorNode(
          type: NucleonType.proton,
          label: BanStrings.proton,
          creatorKey: _creatorKeys[NucleonType.proton]!,
          onPointerDown: _onCreatorPointerDown,
          onPointerMove: _onSessionMove,
          onPointerEnd: _onSessionEnd,
        ),
        const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
        NucleonArrowColumn(
          upKey: const ValueKey('ban_add_pair'),
          downKey: const ValueKey('ban_remove_pair'),
          color: Colors.black87,
          doubled: true,
          onUp: s.canAddPair ? c.addPair : null,
          onDown: s.canRemovePair ? c.removePair : null,
        ),
        const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
        _CreatorNode(
          type: NucleonType.neutron,
          label: BanStrings.neutron,
          creatorKey: _creatorKeys[NucleonType.neutron]!,
          onPointerDown: _onCreatorPointerDown,
          onPointerMove: _onSessionMove,
          onPointerEnd: _onSessionEnd,
        ),
        const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
        NucleonArrowColumn(
          upKey: const ValueKey('ban_add_neutron'),
          downKey: const ValueKey('ban_remove_neutron'),
          color: const Color(BanConstants.neutronColorValue),
          onUp: s.canAddNeutron ? c.addNeutron : null,
          onDown: s.canRemoveNeutron ? c.removeNeutron : null,
        ),
      ],
    );
  }
}

/// 核子生成器（占位视觉 + 正式拖拽语义）：按下即创建活核子并跟随指针。
///
/// 对标 NucleonCreatorNode：无限供应；球体视觉同 ParticleNode 渐变
/// （白 → 基色，高光偏左上）；下方带类型标签（原版 "Protons"/"Neutrons"）。
class _CreatorNode extends StatelessWidget {
  const _CreatorNode({
    required this.type,
    required this.label,
    required this.creatorKey,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerEnd,
  });

  final NucleonType type;
  final String label;
  final GlobalKey creatorKey;
  final void Function(NucleonType, PointerDownEvent) onPointerDown;
  final void Function(PointerMoveEvent) onPointerMove;
  final void Function(PointerEvent) onPointerEnd;

  @override
  Widget build(BuildContext context) {
    final base = type == NucleonType.proton
        ? const Color(BanConstants.protonColorValue)
        : const Color(BanConstants.neutronColorValue);
    return Listener(
      onPointerDown: (e) => onPointerDown(type, e),
      onPointerMove: onPointerMove,
      onPointerUp: onPointerEnd,
      onPointerCancel: onPointerEnd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: BanConstants.nucleonCreatorsMinContentWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: creatorKey,
              width: BanConstants.nucleonRadius * 2,
              height: BanConstants.nucleonRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: base),
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 1.6,
                  colors: [Colors.white, base],
                ),
              ),
            ),
            Text(
              label,
              key: ValueKey('ban_creator_label_${type.name}'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
