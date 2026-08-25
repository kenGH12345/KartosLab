import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/drag_drop_workspace.dart';
import '../../common/geometry/projection.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../../common/widgets/inquiry_models.dart';
import '../../common/widgets/inquiry_drawer.dart';
import '../../common/widgets/experiment_logger.dart';
import '../../common/widgets/experiment_intro_panel.dart';
import '../../common/widgets/scenario_menu_button.dart';
import '../../common/scenario/success_condition.dart';
import '../config/scenario_manager.dart';
import '../config/scenario_runtime_policy.dart';
import '../config/lab_scenario.dart';
import '../config/learning_objective.dart';
import '../models/optical_element.dart';
import '../models/lens_element.dart';
import '../models/mirror_element.dart';
import '../models/light_source_element.dart';
import '../models/screen_element.dart';
import '../models/optics_world.dart';
import '../solvers/optics_solver.dart';

class OpticsScreen extends StatefulWidget {
  const OpticsScreen({super.key, this.initialScenarioId});
  final String? initialScenarioId;

  @override
  State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  final _scenarioManager = ScenarioManager();
  final _solver = OpticalSolver();

  OpticsWorld _world = OpticsWorld.empty();
  SolvedOptics? _solved;
  LabScenario? _currentScenario;
  String? _selectedElementId;
  int _nextElementId = 1; // 单调自增，避免 elements.length+1 在删元件后重号冲突
  bool _inquiryOpen = false;

  // 可拖拽元件定义（与 circuits 的 ComponentType 同模式，供 DragDropWorkspace 使用）
  //
  // 每项都带 customFeedback：拖拽跟随手指的浮起视觉与画布上落定的最终形态一致（迷你版）。
  // 参见 lib/widgets/drag_drop_workspace.dart 的 DragItem.customFeedback。
  static final _trayItems = <DragItem<String>>[
    DragItem(
      data: 'lens_convex',
      label: '凸透镜',
      icon: Icons.lens_blur_rounded,
      color: const Color(0xFF3B82F6),
      customFeedback: () => const _TrayPreview.lens(convex: true),
    ),
    DragItem(
      data: 'lens_concave',
      label: '凹透镜',
      icon: Icons.lens_outlined,
      color: const Color(0xFFEF4444),
      customFeedback: () => const _TrayPreview.lens(convex: false),
    ),
    DragItem(
      data: 'mirror_plane',
      label: '平面镜',
      icon: Icons.motion_photos_on_rounded,
      color: const Color(0xFF6366F1),
      customFeedback: () => const _TrayPreview.mirror(color: Color(0xFF1D4ED8)),
    ),
    DragItem(
      data: 'mirror_concave',
      label: '凹面镜',
      icon: Icons.texture_rounded,
      color: const Color(0xFF22C55E),
      customFeedback: () => const _TrayPreview.mirror(color: Color(0xFF15803D)),
    ),
    DragItem(
      data: 'lightSource',
      label: '光源',
      icon: Icons.light_mode_rounded,
      color: const Color(0xFFEAB308),
      customFeedback: () => const _TrayPreview.source(),
    ),
    DragItem(
      data: 'screen',
      label: '光屏',
      icon: Icons.crop_portrait_rounded,
      color: const Color(0xFF6B7280),
      customFeedback: () => const _TrayPreview.screen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialScenario();
  }

  ScenarioRuntimePolicy get _policy =>
      ScenarioRuntimePolicy(scenario: _currentScenario);

  Future<void> _loadInitialScenario() async {
    try {
      await _scenarioManager.loadScenarios();
      final world = _scenarioManager.loadScenario(
        widget.initialScenarioId ?? 'basic-lens-imaging',
      );
      if (!mounted) return;
      setState(() {
        _world = world;
        _currentScenario = _scenarioManager.currentScenario;
        _nextElementId = _world.elements.length + 1;
        _inquiryOpen = _currentScenario?.inquiryTask != null;
        _solve();
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _world = OpticsWorld.empty();
          _nextElementId = 1;
          _solve();
        });
    }
  }

  void _solve() => setState(() => _solved = _solver.solve(_world));

  void _onComponentDrop(String typeId, Offset worldPos) {
    final type = switch (typeId) {
      'lens_convex' || 'lens_concave' => OpticalElementType.lens,
      'mirror_plane' || 'mirror_concave' => OpticalElementType.mirror,
      'lightSource' => OpticalElementType.lightSource,
      'screen' => OpticalElementType.screen,
      _ => null,
    };
    if (type == null || !_policy.canAdd(type, _world)) return;
    final idx = _nextElementId++;
    final element = switch (typeId) {
      'lens_convex' => LensElement.create(
        id: 'lens_$idx',
        position: worldPos,
        lensType: LensType.convex,
        focalLength: 10,
      ),
      'lens_concave' => LensElement.create(
        id: 'lens_$idx',
        position: worldPos,
        lensType: LensType.concave,
        focalLength: -10,
      ),
      'mirror_plane' => MirrorElement.create(
        id: 'mirror_$idx',
        position: worldPos,
        mirrorType: MirrorType.plane,
      ),
      'mirror_concave' => MirrorElement.create(
        id: 'mirror_$idx',
        position: worldPos,
        mirrorType: MirrorType.concave,
      ),
      'lightSource' => LightSourceElement.create(
        id: 'light_$idx',
        position: worldPos,
        sourceType: SourceType.object,
      ),
      'screen' => ScreenElement.create(id: 'screen_$idx', position: worldPos),
      _ => throw UnsupportedError('Unknown component type: $typeId'),
    };
    setState(() {
      _world = _world.addElement(element);
      _selectedElementId = element.id;
      _solve();
    });
  }

  void _selectElement(String? id) =>
      setState(() => _selectedElementId = _selectedElementId == id ? null : id);
  void _dragSelectElement(String id) => setState(() {
    if (_selectedElementId != id) _selectedElementId = id;
  });
  void _removeSelected() {
    final id = _selectedElementId;
    if (id == null) return;
    final el = _world.getElementById(id);
    if (el != null && !_policy.canRemove(el)) return;
    setState(() {
      _world = _world.removeElement(id);
      _selectedElementId = null;
      _solve();
    });
  }

  void _moveElement(String id, Offset pos) {
    final el = _world.getElementById(id);
    if (el != null && !_policy.canMove(el)) return;
    setState(() {
      _world = _world.moveElement(id, pos);
      _solve();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_currentScenario?.name ?? '几何光学'),
      backgroundColor: const Color(0xFFE8F6FB),
      foregroundColor: const Color(0xFF062A3A),
      actions: [
        IconButton(
          onPressed: _showKnowledgeDialog,
          icon: const Icon(Icons.menu_book_outlined),
          tooltip: '知识点',
        ),
        _buildScenarioMenu(),
        if (_selectedElementId != null)
          IconButton(
            onPressed: _removeSelected,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
          ),
        IconButton(
          onPressed: () => setState(() {
            _world = OpticsWorld.empty();
            _solved = null;
            _selectedElementId = null;
          }),
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: Stack(
        children: [
          NineGridLayout(
            // 中间格 = 纯实验画布（光路图）· 面积 ≥ 70% 屏 · DragTarget 接收元件
            center: DropCanvas<String>(
              canvasBuilder: (context, proj, canvasSize) => _OpticsScene(
                world: _world,
                solved: _solved,
                selectedId: _selectedElementId,
                projection: proj,
                canvasSize: canvasSize,
                onElementTap: _selectElement,
                onDragSelect: _dragSelectElement,
                onElementDrag: _moveElement,
              ),
              onItemDropped: _onComponentDrop,
              scale: 20,
            ),
            // 底部中格 = 元件库托盘（贴边）
            bottomCenter: DragTray<String>(
              layout: DragDropLayout.bottomTray,
              trayTitle: '元件库',
              items: _trayItems,
              traySize: 80,
            ),
            // 右侧边格 = 教学目标 + 约束条件（贴边 · 窄条可滚动）
            // 注意：禁止再包 SingleChildScrollView——_RightPanel 内含 Expanded(ListView)，
            // 无界高度约束会让 RenderFlex 布局失败，render box 无尺寸导致全局 hit test 崩溃。
            midRight: _currentScenario != null
                ? _RightPanel(scenario: _currentScenario!, world: _world)
                : null,
            // 顶部中格 = 实验说明 + 操作指引（通用引导组件）
            topCenter: ExperimentIntroPanel(
              description: _currentScenario?.description ?? '',
              task: _inquiryTask,
              color: const Color(0xFF1177AA),
            ),
            // 顶部右格 = 探究入口按钮（窄边条放不下三组件 → 抽屉方案）
            topRight: _buildInquiryEntryButton(),
          ),
          // 探究工作流抽屉（Offstage 保持记录/结论 State · 无 inquiryTask 不渲染）
          InquiryDrawer(
            task: _currentScenario?.inquiryTask,
            columns: _inquiryTask != null
                ? _inquiryColumns(_inquiryTask!)
                : const [],
            snapshotProvider: _opticsSnapshot,
            open: _inquiryOpen,
          ),
        ],
      ),
    ),
  );

  InquiryTask? get _inquiryTask => _currentScenario?.inquiryTask;

  /// 探究抽屉入口按钮（仅在有 inquiryTask 的 scenario 显示）。
  Widget _buildInquiryEntryButton() {
    if (_inquiryTask == null) return const SizedBox.shrink();
    return Center(
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.science_outlined, size: 20),
        tooltip: '探究任务',
        onPressed: () => setState(() => _inquiryOpen = !_inquiryOpen),
      ),
    );
  }

  /// optics 快照：物距（param）+ 像距/放大率/虚实（reading）。
  Map<String, dynamic> _opticsSnapshot() {
    final stage = _solved?.imageStages.isNotEmpty == true
        ? _solved!.imageStages.last
        : null;
    return {
      'objectDistance': stage?.objectDistance,
      'imageDistance': stage?.imageDistance,
      'magnification': stage?.magnification,
      'isVirtual': stage?.isVirtual == true ? '虚像' : '实像',
    };
  }

  List<ColumnDef> _inquiryColumns(InquiryTask task) {
    if (task.snapshotColumns.isEmpty) {
      return const [
        ColumnDef(key: 'objectDistance', label: '物距', isParam: true),
        ColumnDef(key: 'imageDistance', label: '像距'),
        ColumnDef(key: 'magnification', label: '放大率'),
        ColumnDef(key: 'isVirtual', label: '虚实'),
      ];
    }
    return task.snapshotColumns
        .map(
          (c) => ColumnDef(
            key: c.key,
            label: c.label,
            isParam: c.source == 'param',
          ),
        )
        .toList(growable: false);
  }

  /// 知识点卡 → 弹窗（9 宫格边条容纳不下长文本知识卡）
  void _showKnowledgeDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: _buildKnowledgePanel(),
          ),
        ),
      ),
    );
  }

  // ---- 几何光学知识点 ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: '几何光学原理',
      titleIcon: '🔬',
      titleColor: const Color(0xFF3B82F6),
      maxHeight: 200,
      sections: [
        KnowledgeSection.grid(
          items: const [
            KnowledgeItem(
              dot: Color(0xFF3B82F6),
              title: '凸透镜 (会聚)',
              titleColor: Color(0xFF3B82F6),
              desc: '中间厚边缘薄。平行光通过后汇聚于焦点F。放大镜、远视眼镜、照相机镜头都是凸透镜。',
            ),
            KnowledgeItem(
              dot: Color(0xFFEF4444),
              title: '凹透镜 (发散)',
              titleColor: Color(0xFFEF4444),
              desc: '中间薄边缘厚。平行光通过后向外发散,反向延长线汇聚于虚焦点。近视眼镜就是凹透镜。',
            ),
            KnowledgeItem(
              dot: Color(0xFF6366F1),
              title: '平面镜',
              titleColor: Color(0xFF6366F1),
              desc: '反射面为平面。像与物等大、正立、虚像,像距=物距。日常镜子就是这个原理。',
            ),
            KnowledgeItem(
              dot: Color(0xFF22C55E),
              title: '凹面镜 (会聚)',
              titleColor: Color(0xFF22C55E),
              desc: '反射面内凹。平行光反射后汇聚于焦点。手电筒反光碗、太阳灶就是凹面镜。',
            ),
          ],
        ),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '🎯',
              title: '焦点与焦距 · 透镜成像公式',
              titleColor: Color(0xFFF59E0B),
              desc:
                  '平行于主光轴的光线经过透镜后会聚(或反向延长线会聚)于焦点F。透镜中心到焦点的距离叫焦距f。'
                  '成像公式: 1/f = 1/u + 1/v（u为物距,v为像距,f凸为正/凹为负）。',
            ),
            KnowledgeItem(
              icon: '🪞',
              title: '实像 vs 虚像 · 像的性质判断',
              titleColor: Color(0xFF22C55E),
              desc:
                  '实像：光线实际汇聚而成,可用光屏承接（如投影仪成像）。虚像：光线反向延长线汇聚,不能用光屏承接（如放大镜看到的像）。'
                  '凸透镜u>f成实像,u<f成虚像；凹透镜永远成虚像。',
            ),
            KnowledgeItem(
              icon: '💡',
              title: '生活应用 · 无处不在的透镜',
              titleColor: Color(0xFF8B5CF6),
              desc:
                  '人眼(晶状体=凸透镜,视网膜=光屏)、照相机(镜头=凸透镜,底片=光屏)、投影仪(强光源+凸透镜)、'
                  '门镜猫眼(凹透镜组合)、汽车后视镜(凸面镜扩大视野)——透镜原理贯穿日常。',
            ),
          ],
        ),
      ],
    );
  }

  /// 场景切换（统一走 L0 ScenarioMenuButton · 替代原全屏选择页）
  void _applyScenarioById(String id) async {
    if (id == _currentScenario?.scenarioId) return;
    await _scenarioManager.loadScenarios();
    final world = _scenarioManager.loadScenario(id);
    if (!mounted) return;
    setState(() {
      _world = world;
      _currentScenario = _scenarioManager.currentScenario;
      _nextElementId = _world.elements.length + 1;
      _inquiryOpen = _currentScenario?.inquiryTask != null;
      _solve();
    });
  }

  /// 场景切换菜单（统一 L0 组件 · entries 来自已加载场景）
  Widget _buildScenarioMenu() {
    final scenarios = _scenarioManager.scenarios;
    return ScenarioMenuButton(
      entries: scenarios
          .map((s) => ScenarioMenuEntry(id: s.scenarioId, name: s.name))
          .toList(growable: false),
      currentId: _currentScenario?.scenarioId,
      onSelected: _applyScenarioById,
      accentColor: const Color(0xFF1177AA),
      tooltip: '切换场景',
    );
  }
}

// ── 光学场景内容（纯绘制，拖拽由 DragDropWorkspace 处理） ──

class _OpticsScene extends StatefulWidget {
  final OpticsWorld world;
  final SolvedOptics? solved;
  final String? selectedId;
  final SceneProjection projection;
  final Size canvasSize;
  final void Function(String?) onElementTap;
  final void Function(String) onDragSelect;
  final void Function(String, Offset) onElementDrag;

  const _OpticsScene({
    required this.world,
    required this.solved,
    required this.selectedId,
    required this.projection,
    required this.canvasSize,
    required this.onElementTap,
    required this.onDragSelect,
    required this.onElementDrag,
  });

  @override
  State<_OpticsScene> createState() => _OpticsSceneState();
}

class _OpticsSceneState extends State<_OpticsScene> {
  // drag anchor: element position and pointer world position when scale starts
  Offset? _dragElementStart;
  Offset? _dragPointerStart;
  String? _dragId;

  OpticsWorld get world => widget.world;
  SolvedOptics? get solved => widget.solved;
  String? get selectedId => widget.selectedId;
  SceneProjection get projection => widget.projection;
  Size get canvasSize => widget.canvasSize;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapUp: (d) {
      final wp = projection.toWorld(d.localPosition);
      for (final e in world.elements.reversed) {
        if (e.hitTest(wp)) {
          widget.onElementTap(e.id);
          return;
        }
      }
      widget.onElementTap(null);
    },
    onScaleStart: (d) {
      final wp = projection.toWorld(d.localFocalPoint);
      // pick element under finger (if not selected, auto-select)
      String? hitId =
          selectedId != null &&
              world.getElementById(selectedId!) != null &&
              world.getElementById(selectedId!)!.hitTest(wp)
          ? selectedId
          : null;
      if (hitId == null) {
        for (final e in world.elements.reversed) {
          if (e.hitTest(wp)) {
            hitId = e.id;
            widget.onDragSelect(e.id);
            break;
          }
        }
      }
      if (hitId == null) {
        _dragId = null;
        return;
      }
      final el = world.getElementById(hitId);
      if (el == null) {
        _dragId = null;
        return;
      }
      _dragId = hitId;
      _dragElementStart = Offset(el.x, el.y);
      _dragPointerStart = wp;
    },
    onScaleUpdate: (d) {
      if (d.pointerCount >= 2) return;
      if (_dragId == null ||
          _dragElementStart == null ||
          _dragPointerStart == null)
        return;
      final wp = projection.toWorld(d.localFocalPoint);
      final delta = wp - _dragPointerStart!;
      widget.onElementDrag(_dragId!, _dragElementStart! + delta);
    },
    onScaleEnd: (_) {
      _dragId = null;
      _dragElementStart = null;
      _dragPointerStart = null;
    },
    child: SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFFF8FCFE))),
          Positioned(
            left: 0,
            top: projection.origin.dy - 1,
            right: 0,
            height: 2,
            child: Container(color: const Color(0xFF7A81CA)),
          ),
          ...world.elements.map(
            (e) => _elementWidget(e, projection, e.id == selectedId),
          ),
          // 焦距标记层（F/F' 与 2F/2F'）—— 独立 painter，仅按 elements 派发
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _FocalPointsPainter(world: world, proj: projection),
            ),
          ),
          // 渲染层不拦截点击/拖放，让事件穿透到元件和 DragTarget
          if (solved != null)
            IgnorePointer(
              child: Stack(
                children: [
                  ..._rayWidgets(solved!, projection),
                  _imageWidget(solved!, projection),
                  ..._screenHitWidgets(solved!, projection),
                  if (solved!.imageInfo != null)
                    _debugDot(solved!.imageInfo!, projection),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  Widget _debugDot(dynamic info, SceneProjection p) {
    final imagePoint = info.imagePoint as Offset;
    final sp = p.toScreen(imagePoint);
    return Positioned(
      left: sp.dx - 5,
      top: sp.dy - 5,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFF0000),
        ),
      ),
    );
  }

  Widget _elementWidget(OpticalElement e, SceneProjection p, bool sel) {
    final sp = p.toScreen(Offset(e.x, e.y));
    late final double left, top;
    if (e is LightSourceElement) {
      final srch = e.objectHeight * 10; // SVG 像素高度
      final tipX = 15.0; // 30px 宽，尖端在水平中心 x=32/64
      final tipY = srch * 6 / 240; // 尖端距 SVG 顶部 y=6/240
      // 尖端对准光线起点：curObj = (src.x, src.y - objH/2)
      left = sp.dx - tipX;
      top = sp.dy - srch - tipY; // sp.y = world 0 的光轴，srg 底部在光轴
    } else if (e is LensElement) {
      left = sp.dx - 20;
      top = sp.dy - 65;
    } else {
      left = sp.dx - 3;
      top = sp.dy - 40;
    }
    return Positioned(
      left: left,
      top: top,
      child: Container(
        decoration: sel
            ? BoxDecoration(
                border: Border.all(color: const Color(0xFF1177AA), width: 2),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF1177AA).withValues(alpha: 0.05),
              )
            : null,
        child: _elementVisual(e),
      ),
    );
  }

  Widget _elementVisual(OpticalElement e) {
    if (e is LensElement) return _LensIcon(lens: e);
    if (e is MirrorElement) return _MirrorIcon(mirror: e);
    if (e is LightSourceElement) return _SourceIcon(source: e);
    if (e is ScreenElement) return _ScreenIcon();
    return const SizedBox.shrink();
  }

  List<Widget> _rayWidgets(SolvedOptics s, SceneProjection p) => [
    ...s.rays
        .where((r) => r.points.length >= 2 || r.virtualPoints.isNotEmpty)
        .map(
          (r) => CustomPaint(
            painter: _RayPainter(ray: r, proj: p),
            size: Size.infinite,
          ),
        ),
    ...s.virtualRays
        .where((r) => r.virtualPoints.isNotEmpty)
        .map(
          (r) => CustomPaint(
            painter: _RayPainter(ray: r, proj: p),
            size: Size.infinite,
          ),
        ),
  ];

  Widget _imageWidget(SolvedOptics s, SceneProjection p) {
    final info = s.imageInfo;
    if (info == null) return const SizedBox.shrink();
    final sp = p.toScreen(info.imagePoint);
    // 和源一致的像素比：objectHeight → objectHeight*10 px
    final hPx = (info.imageHeight.abs() * 10).clamp(12.0, 300.0);
    final svgW = hPx * 64 / 240; // 原始 SVG 比例 64:240
    final isVirtual = info.isVirtual;
    final isUp = info.imageHeight > 0 || isVirtual;
    final alpha = isVirtual ? 0.35 : 0.6;
    final tint = isVirtual ? const Color(0xFF60A5FA) : const Color(0xFFEF4444);

    // 关键：imagePoint 是笔尖位置，直接对准 sp (screen point)
    // SVG 内部：尖端在 (32, 6)，底部在 (32, ~234)
    // 为了尖端对准 sp，需要把 widget 的 (32, 6) 映射到 sp
    // BoxFit.fill 后：(32/64*svgW, 6/240*hPx) = (svgW/2, hPx*0.025)
    final tipX = svgW / 2;
    final tipY = hPx * 6 / 240; // 尖端距 widget 顶部的偏移

    return Positioned(
      left: sp.dx - tipX,
      top: isUp ? sp.dy - tipY : sp.dy - (hPx - tipY),
      child: Opacity(
        opacity: alpha,
        child: Transform(
          alignment: Alignment.center,
          transform: isUp
              ? Matrix4.identity()
              : Matrix4.diagonal3Values(1, -1, 1),
          child: SvgPicture.asset(
            'assets/images/pencil.svg',
            width: svgW,
            height: hPx,
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  List<Widget> _screenHitWidgets(SolvedOptics s, SceneProjection p) =>
      s.screenHits.map((h) {
        final sp = p.toScreen(h.point);
        return Positioned(
          left: sp.dx - 3,
          top: sp.dy - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withValues(alpha: 0.9),
            ),
          ),
        );
      }).toList();
}

class _LensIcon extends StatelessWidget {
  final LensElement lens;
  const _LensIcon({required this.lens});
  @override
  Widget build(_) {
    final cv = lens.lensKind == LensType.convex;
    final c = cv ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);
    final bc = cv ? const Color(0xFF1E40AF) : const Color(0xFF991B1B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 130,
          child: CustomPaint(
            painter: _LensPainter(convex: cv, color: c, borderColor: bc),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          cv ? '凸透镜' : '凹透镜',
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _LensPainter extends CustomPainter {
  final bool convex;
  final Color color;
  final Color borderColor;
  const _LensPainter({
    required this.convex,
    required this.color,
    required this.borderColor,
  });
  @override
  void paint(Canvas can, Size sz) {
    final w = sz.width, h = sz.height, cx = w / 2, cy = h / 2;
    // 凸透镜：中间宽；凹透镜：中间窄。直接指定赤道半宽
    final poleW = w * 0.12; // 端部半宽
    final eqW = convex ? w * 0.45 : w * 0.02; // 中间半宽：凸大/凹小
    final p = Path()
      ..moveTo(cx - poleW, 4) // 顶端左
      ..cubicTo(cx - eqW, h * 0.15, cx - eqW, h * 0.85, cx - poleW, h - 4) // 右弧
      ..lineTo(cx + poleW, h - 4) // 底端右
      ..cubicTo(cx + eqW, h * 0.85, cx + eqW, h * 0.15, cx + poleW, 4) // 左弧
      ..close();
    can.drawPath(
      p,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
    can.drawPath(
      p,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    can.drawLine(
      Offset(0, cy),
      Offset(w, cy),
      Paint()
        ..color = borderColor.withValues(alpha: 0.4)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_LensPainter o) => o.convex != convex || o.color != color;
}

class _MirrorIcon extends StatelessWidget {
  final MirrorElement mirror;
  const _MirrorIcon({required this.mirror});
  @override
  Widget build(_) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFF1D4ED8), width: 2),
        ),
      ),
      const SizedBox(height: 4),
      Text(switch (mirror.mirrorKind) {
        MirrorType.concave => '凹面镜',
        MirrorType.convex => '凸面镜',
        MirrorType.plane => '平面镜',
      }, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
    ],
  );
}

class _SourceIcon extends StatelessWidget {
  final LightSourceElement source;
  const _SourceIcon({required this.source});
  @override
  Widget build(_) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(
        'assets/images/pencil.svg',
        width: 30,
        height: source.objectHeight * 10,
        fit: BoxFit.fill,
      ),
      const SizedBox(height: 4),
      const Text(
        '光源',
        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
      ),
    ],
  );
}

class _ScreenIcon extends StatelessWidget {
  const _ScreenIcon();
  @override
  Widget build(_) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFF6B7280), width: 2),
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        '光屏',
        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
      ),
    ],
  );
}

class _RayPainter extends CustomPainter {
  final RayPath ray;
  final SceneProjection proj;
  const _RayPainter({required this.ray, required this.proj});
  @override
  void paint(Canvas c, Size s) {
    final realPts = ray.points.map(proj.toScreen).toList();
    final realPaint = Paint()
      ..color = ray.isBoundary
          ? const Color(0xFF071827)
          : const Color(0xFF22C55E)
      ..strokeWidth = ray.isBoundary ? 2 : 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < realPts.length - 1; i++) {
      c.drawLine(realPts[i], realPts[i + 1], realPaint);
    }

    final virtualPts = ray.virtualPoints.map(proj.toScreen).toList();
    if (virtualPts.length >= 2) {
      _drawDashed(
        c,
        virtualPts[0],
        virtualPts[1],
        Paint()
          ..color = const Color(0xFF60A5FA).withValues(alpha: 0.55)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawDashed(Canvas c, Offset a, Offset b, Paint p) {
    final d = b - a;
    final len = d.distance;
    if (len == 0) return;
    final u = d / len;
    var traveled = 0.0;
    while (traveled < len) {
      final start = a + u * traveled;
      final end = a + u * (traveled + 6).clamp(0.0, len);
      c.drawLine(start, end, p);
      traveled += 10;
    }
  }

  @override
  bool shouldRepaint(_RayPainter o) => o.ray != ray;
}

/// 焦距标记层：读 world.elements 里的 lens/mirror，在光轴上画 F / F' / 2F / 2F' 四个点 + 文字。
///
/// 说明：
/// - lens：F' 在透镜右侧（+f），F 在左侧（-f）；2F' / 2F 同理。
/// - mirror：反射系统 F 在镜面前方（凹面镜 → 左侧）；平面镜 focalLength 为 infinity，跳过。
class _FocalPointsPainter extends CustomPainter {
  final OpticsWorld world;
  final SceneProjection proj;
  const _FocalPointsPainter({required this.world, required this.proj});

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in world.elements) {
      if (e is LensElement) {
        final f = e.focalLength.abs();
        if (f < 0.001) continue;
        _drawMark(canvas, e.x + f, e.y, 'F\'');
        _drawMark(canvas, e.x - f, e.y, 'F');
        _drawMark(canvas, e.x + 2 * f, e.y, '2F\'', secondary: true);
        _drawMark(canvas, e.x - 2 * f, e.y, '2F', secondary: true);
      } else if (e is MirrorElement) {
        if (e.focalLength.isInfinite) continue;
        final f = e.focalLength.abs();
        if (f < 0.001) continue;
        // 镜面焦距在镜面前方（对凹面镜，光线来自左方 → 焦点在左）
        _drawMark(canvas, e.x - f, e.y, 'F');
        _drawMark(canvas, e.x - 2 * f, e.y, '2F', secondary: true);
      }
    }
  }

  void _drawMark(
    Canvas canvas,
    double wx,
    double wy,
    String label, {
    bool secondary = false,
  }) {
    final sp = proj.toScreen(Offset(wx, wy));
    final dotColor = secondary
        ? const Color(0xFFF59E0B)
        : const Color(0xFFDC2626);
    final textColor = secondary
        ? const Color(0xFFB45309)
        : const Color(0xFFB91C1C);
    canvas.drawCircle(sp, secondary ? 4 : 5, Paint()..color = dotColor);
    canvas.drawCircle(
      sp,
      secondary ? 4 : 5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.white, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(sp.dx - tp.width / 2, sp.dy + 6));
  }

  @override
  bool shouldRepaint(covariant _FocalPointsPainter old) =>
      old.world != world || old.proj != proj;
}

/// 托盘拖拽反馈的迷你预览（Draggable.feedback 用）。
///
/// 用途：让"拖起来跟随手指的浮起视觉"与"落到画布上的最终形态"保持一致（迷你版）。
/// 由于 tray item 是"类别"而非"实例"（tray 里的凸透镜不绑定具体 focalLength），
/// 因此本 widget 不复用 _LensIcon 等实例化组件，而是画结构性缩略图。
class _TrayPreview extends StatelessWidget {
  final _PreviewKind kind;
  final bool convex; // for lens
  final Color? tint; // for mirror
  const _TrayPreview.lens({required this.convex})
    : kind = _PreviewKind.lens,
      tint = null;
  const _TrayPreview.mirror({required Color color})
    : kind = _PreviewKind.mirror,
      convex = false,
      tint = color;
  const _TrayPreview.source()
    : kind = _PreviewKind.source,
      convex = false,
      tint = null;
  const _TrayPreview.screen()
    : kind = _PreviewKind.screen,
      convex = false,
      tint = null;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _PreviewKind.lens:
        final c = convex ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);
        final bc = convex ? const Color(0xFF1E40AF) : const Color(0xFF991B1B);
        return SizedBox(
          width: 32,
          height: 56,
          child: CustomPaint(
            painter: _LensPainter(convex: convex, color: c, borderColor: bc),
          ),
        );
      case _PreviewKind.mirror:
        return Container(
          width: 6,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: tint!, width: 2),
          ),
        );
      case _PreviewKind.source:
        return SvgPicture.asset(
          'assets/images/pencil.svg',
          width: 20,
          height: 56,
          fit: BoxFit.fill,
        );
      case _PreviewKind.screen:
        return Container(
          width: 6,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFF6B7280), width: 2),
          ),
        );
    }
  }
}

enum _PreviewKind { lens, mirror, source, screen }

class _RightPanel extends StatelessWidget {
  final LabScenario scenario;
  final OpticsWorld world;
  const _RightPanel({required this.scenario, required this.world});

  @override
  Widget build(_) => Container(
    width: double.infinity,
    color: const Color(0xFFF9FAFB),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('教学目标', const Color(0xFF059669), Icons.flag_rounded),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final c
                  in scenario.objectives?.successCriteria ??
                      <SuccessCondition>[])
                for (final leaf in c.collectLeaves())
                  _listCard(
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                    leaf.description,
                  ),
            ],
          ),
        ),
        const Divider(height: 1),
        _header('约束条件', const Color(0xFF7C3AED), Icons.rule_rounded),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final c in scenario.constraints)
                _listCard(
                  Icon(
                    c.validate(world)
                        ? Icons.info_rounded
                        : Icons.warning_rounded,
                    color: c.validate(world)
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF59E0B),
                    size: 16,
                  ),
                  c.description,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _header(String title, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    color: color,
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _listCard(Widget icon, String desc) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    ),
  );
}
