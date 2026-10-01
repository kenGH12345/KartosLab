/// Build a Nucleus · Decay 屏。
///
/// 布局：NineGridLayout（中间格 ≥70%）。核素状态 UI 在边格（1G-2）；
/// Decay 右栏（counters|symbol + Available Decays）在 midRight（P2-1）；
/// 核上方标签（Unstable + 元素名）在 center，Half-Life 与画布之间（P2-2）；
/// 半衰期信息区在中间格顶部（1G-3B-5）；画布为 NucleusPainter（含电子云）；
/// footer 为核子生成器。作为 Tab 子页时设 [embedded]，由
/// [BuildANucleusHome] 提供外层 AppBar。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../../../common/widgets/drag_drop_workspace.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../ban_constants.dart';
import '../controller/build_a_nucleus_controller.dart';
import '../data/nuclide_data_loader.dart';
import '../model/nucleon.dart';
import '../model/half_life_number_line.dart';
import '../painters/nucleus_painter.dart';
import '../widgets/available_decays_panel.dart';
import '../widgets/decay_right_column.dart';
import '../widgets/half_life_information_view.dart';
import '../widgets/nuclide_status.dart';
import '../widgets/show_electron_cloud_checkbox.dart';

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
    final s = c.state;
    // play 宽 = NineGrid 约束宽，对标原版 layoutBounds.width。
    return LayoutBuilder(
      builder: (context, play) {
        return NineGridLayout(
      midRight: DecayRightColumn(
        state: s,
        decays: AvailableDecaysPanel(controller: c),
      ),
      bottomRight: IconButton(
        key: const ValueKey('ban_reset'),
        icon: const Icon(Icons.restart_alt),
        tooltip: '重置',
        onPressed: _reset,
      ),
      center: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 原版 HalfLifeInformationNode：屏顶绝对定位，宽 550。
          // NineGrid 顶行高度 < 数轴所需 ~124px，无法放入 topCenter。
          // 中间格是唯一既够宽又够高的格子 → 放在画布上方。
          // [已确认 原版在上半屏] [推测 NineGrid 映射]
          HalfLifeInformationView(
            reading: HalfLifeNumberLine.fromState(s),
            elementName: NuclideStatusText.elementCaption(s),
          ),
          // [已确认] Unstable + 元素名在核上方，X 跟半衰期中心。
          // 矮视口：标签上限为剩余高的一部分并 scaleDown，不改 NineGrid。
          Expanded(
            child: LayoutBuilder(
              builder: (context, remain) {
                return Column(
                  children: [
                    SizedBox(
                      width: remain.maxWidth,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: remain.maxHeight * 0.4,
                          ),
                          child: _HalfLifeContentXAnchor(
                            layoutWidth: play.maxWidth,
                            columnWidth: remain.maxWidth,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ElementAndStabilityReadout(state: s),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                final canvasSize =
                    Size(constraints.maxWidth, constraints.maxHeight);
                // [已确认] atomCenter.x = layoutBounds.width / 3
                // play.maxWidth 对标 ScreenView layoutBounds.width，不是画布宽。
                // 核画在中心格：局部 X = layoutX - canvasLeft。
                final proj = CanvasProjection(
                  canvasSize: canvasSize,
                  origin: BanConstants.atomOriginInCanvas(
                    layoutWidth: play.maxWidth,
                    canvasSize: canvasSize,
                  ),
                );
                _proj = proj;
                c.visibleSizeProvider ??=
                    () => Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    KeyedSubtree(
                      key: const ValueKey('ban_canvas'),
                      child: Listener(
                        key: _canvasKey,
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: _onCanvasPointerDown,
                        onPointerMove: _onSessionMove,
                        onPointerUp: _onSessionEnd,
                        onPointerCancel: _onSessionEnd,
                        child: SizedBox.expand(
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
                    // [已确认] checkbox 与 Reset 底对齐、与衰变面板左对齐。
                    // [推测 NineGrid] 边格仅 ~65px，放不下原文案；叠在画布右下，
                    // 贴近 midRight/bottomRight，不改 Half-Life 布局。
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ShowElectronCloudCheckbox(
                        value: _showElectronCloud,
                        onChanged: (v) =>
                            setState(() => _showElectronCloud = v),
                      ),
                    ),
                  ],
                );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // 生成器条：箭头 + 质子/中子生成器（按下即创建活粒子，DragTray 的
      // Draggable「drop 才入世界」语义与原版不符，故用 Listener 实现；
      // common 组件不改造以避免影响 circuit/optics）。
      // [已确认] NucleonCreatorsNode HBox：
      // protonArrows | protonCreator | doubleArrows | neutronCreator | neutronArrows
      // FittedBox：窄横屏不溢出。[有意差异] 不用 sun ArrowButton 皮肤。
      // [已确认] NucleonCreatorsNode.centerX = atomCenter.x = layoutBounds.width / 3
      // 整组 HBox 中心对齐核，不是某个内部球/箭头；无额外左右偏移。
      footer: CustomSingleChildLayout(
        delegate: _GeneratorAnchorDelegate(),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            key: const ValueKey('ban_nucleon_creators'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ArrowColumn(
                upKey: const ValueKey('ban_add_proton'),
                downKey: const ValueKey('ban_remove_proton'),
                color: const Color(BanConstants.protonColorValue),
                onUp: s.canAddProton ? c.addProton : null,
                onDown: s.canRemoveProton ? c.removeProton : null,
              ),
              const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
              _CreatorNode(
                type: NucleonType.proton,
                label: '质子',
                creatorKey: _creatorKeys[NucleonType.proton]!,
                onPointerDown: _onCreatorPointerDown,
                onPointerMove: _onSessionMove,
                onPointerEnd: _onSessionEnd,
              ),
              const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
              _ArrowColumn(
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
                label: '中子',
                creatorKey: _creatorKeys[NucleonType.neutron]!,
                onPointerDown: _onCreatorPointerDown,
                onPointerMove: _onSessionMove,
                onPointerEnd: _onSessionEnd,
              ),
              const SizedBox(width: BanConstants.nucleonCreatorsHBoxSpacing),
              _ArrowColumn(
                upKey: const ValueKey('ban_add_neutron'),
                downKey: const ValueKey('ban_remove_neutron'),
                color: const Color(BanConstants.neutronColorValue),
                onUp: s.canAddNeutron ? c.addNeutron : null,
                onDown: s.canRemoveNeutron ? c.removeNeutron : null,
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

/// 把子组件中心 X 锚到冻结的半衰期信息块中心。
/// [已确认] `stability.center.x = halfLifeInformationNodeCenterX`
/// 只用 play/列宽公式，不用 Positioned 截图像素。不改子组件高度。
class _HalfLifeContentXAnchor extends StatelessWidget {
  const _HalfLifeContentXAnchor({
    required this.layoutWidth,
    required this.columnWidth,
    required this.child,
  });

  final double layoutWidth;
  final double columnWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final localCx = BanConstants.halfLifeInformationCenterXInColumn(
      layoutWidth: layoutWidth,
      columnWidth: columnWidth,
    );
    return Transform.translate(
      offset: Offset(localCx, 0),
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: child,
      ),
    );
  }
}

/// X：整组中心 = atomCenterX（已 resolved，不改语义）。
/// Y：[已确认] `nucleonCreatorsNode.bottom = layoutBounds.maxY - Y_MARGIN`
/// Flutter footer 底对应 play 底；锚 `footerBottom - SCREEN_VIEW_Y_MARGIN`。
/// 子级 maxHeight 预留该 margin；装不下时 FittedBox.scaleDown（不改 NineGrid footer 高）。
class _GeneratorAnchorDelegate extends SingleChildLayoutDelegate {
  static double _bottomMargin(double footerHeight) {
    if (footerHeight <= 0) return 0;
    return footerHeight < BanConstants.screenViewYMargin
        ? footerHeight
        : BanConstants.screenViewYMargin;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final margin = _bottomMargin(constraints.maxHeight);
    final maxH = constraints.maxHeight - margin;
    return BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: maxH > 1 ? maxH : 1,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final centerX = BanConstants.atomCenterXForLayout(size.width);
    final margin = _bottomMargin(size.height);
    var y = size.height - margin - childSize.height;
    if (y < 0) y = 0;
    return Offset(centerX - childSize.width / 2, y);
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => false;
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
      child: SizedBox(
        width: BanConstants.nucleonCreatorsMinContentWidth,
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
            // [已确认] NucleonCreatorsNode PhetFont(20)
            // footer 高 96：整组 FittedBox，装不下再缩。[视觉近似：NineGrid]
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

/// 上/下箭头列。对标 ArrowButton VBox（spacing 7）。
/// [已确认] 单箭头 fill = 核子色；双箭头在两生成器之间。
class _ArrowColumn extends StatelessWidget {
  const _ArrowColumn({
    required this.upKey,
    required this.downKey,
    required this.color,
    required this.onUp,
    required this.onDown,
    this.doubled = false,
  });

  final Key upKey;
  final Key downKey;
  final Color color;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final bool doubled;

  @override
  Widget build(BuildContext context) {
    final w = doubled
        ? BanConstants.nucleonDoubleArrowButtonWidth
        : BanConstants.nucleonArrowButtonWidth;
    const h = BanConstants.nucleonArrowButtonHeight;
    final style = IconButton.styleFrom(
      minimumSize: Size(w, h),
      maximumSize: Size(w, h),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      side: const BorderSide(color: Colors.black, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
    Widget button({
      required Key key,
      required bool up,
      required VoidCallback? onPressed,
    }) {
      return SizedBox(
        width: w,
        height: h,
        child: IconButton(
          key: key,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: w, height: h),
          style: style,
          icon: SizedBox(
            width: doubled
                ? BanConstants.nucleonArrowGlyphSize * 2
                : BanConstants.nucleonArrowGlyphSize,
            height: BanConstants.nucleonArrowGlyphSize,
            child: CustomPaint(
              painter: _NucleonArrowPainter(
                up: up,
                doubled: doubled,
                leftFill: doubled
                    ? const Color(BanConstants.protonColorValue)
                    : color,
                rightFill: doubled
                    ? const Color(BanConstants.neutronColorValue)
                    : color,
              ),
            ),
          ),
          onPressed: onPressed,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(key: upKey, up: true, onPressed: onUp),
        const SizedBox(height: BanConstants.nucleonArrowVBoxSpacing),
        button(key: downKey, up: false, onPressed: onDown),
      ],
    );
  }
}

/// [已确认] `ArrowButton` / `DoubleArrowButton` 三角 Path：14×14，尖朝上；
/// 双箭并排、左质子色右中子色；朝下旋转 π。
class _NucleonArrowPainter extends CustomPainter {
  const _NucleonArrowPainter({
    required this.up,
    required this.doubled,
    required this.leftFill,
    required this.rightFill,
  });

  final bool up;
  final bool doubled;
  final Color leftFill;
  final Color rightFill;

  @override
  void paint(Canvas canvas, Size size) {
    final g = BanConstants.nucleonArrowGlyphSize;
    // 朝下旋转 π 后左右对调，与 DoubleArrowButton 一样先换色。
    final left = !up && doubled ? rightFill : leftFill;
    final right = !up && doubled ? leftFill : rightFill;
    canvas.save();
    if (!up) {
      canvas.translate(size.width, size.height);
      canvas.rotate(math.pi);
    }
    if (doubled) {
      _triangle(canvas, Offset(g / 2, 0), left);
      _triangle(canvas, Offset(g + g / 2, 0), right);
    } else {
      _triangle(canvas, Offset(g / 2, 0), left);
    }
    canvas.restore();
  }

  void _triangle(Canvas canvas, Offset tip, Color fill) {
    final g = BanConstants.nucleonArrowGlyphSize;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + g / 2, tip.dy + g)
      ..lineTo(tip.dx - g / 2, tip.dy + g)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(covariant _NucleonArrowPainter old) =>
      old.up != up ||
      old.doubled != doubled ||
      old.leftFill != leftFill ||
      old.rightFill != rightFill;
}
