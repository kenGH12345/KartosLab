import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../optics/config/scenario_manager.dart';
import '../optics/config/scenario_runtime_policy.dart';
import '../optics/config/lab_scenario.dart';
import '../optics/config/learning_objective.dart';
import '../optics/models/optical_element.dart';
import '../optics/models/lens_element.dart';
import '../optics/models/mirror_element.dart';
import '../optics/models/light_source_element.dart';
import '../optics/models/screen_element.dart';
import '../optics/models/optics_world.dart';
import '../optics/solvers/optics_solver.dart';
import '../widgets/drag_drop_workspace.dart';
import 'scenario_selection_screen.dart';

class OpticsScreen extends StatefulWidget {
  const OpticsScreen({super.key, this.initialScenarioId});
  final String? initialScenarioId;

  @override State<OpticsScreen> createState() => _OpticsScreenState();
}

class _OpticsScreenState extends State<OpticsScreen> {
  final _scenarioManager = ScenarioManager();
  final _solver = OpticalSolver();

  OpticsWorld _world = OpticsWorld.empty();
  SolvedOptics? _solved;
  LabScenario? _currentScenario;
  String? _selectedElementId;
  int _nextElementId = 1; // 单调自增，避免 elements.length+1 在删元件后重号冲突

  // 可拖拽元件定义（与 circuits 的 ComponentType 同模式，供 DragDropWorkspace 使用）
  static const _trayItems = [
    DragItem(data: 'lens_convex', label: '凸透镜', icon: Icons.lens_blur_rounded, color: Color(0xFF3B82F6)),
    DragItem(data: 'lens_concave', label: '凹透镜', icon: Icons.lens_outlined, color: Color(0xFFEF4444)),
    DragItem(data: 'mirror_plane', label: '平面镜', icon: Icons.motion_photos_on_rounded, color: Color(0xFF6366F1)),
    DragItem(data: 'mirror_concave', label: '凹面镜', icon: Icons.texture_rounded, color: Color(0xFF22C55E)),
    DragItem(data: 'lightSource', label: '光源', icon: Icons.light_mode_rounded, color: Color(0xFFEAB308)),
  ];

  @override void initState() { super.initState(); _loadInitialScenario(); }

  ScenarioRuntimePolicy get _policy => ScenarioRuntimePolicy(scenario: _currentScenario);

  Future<void> _loadInitialScenario() async {
    try {
      await _scenarioManager.loadScenarios();
      final world = _scenarioManager.loadScenario(widget.initialScenarioId ?? 'basic-lens-imaging');
      if (!mounted) return;
      setState(() { _world = world; _currentScenario = _scenarioManager.currentScenario; _nextElementId = _world.elements.length + 1; _solve(); });
    } catch (_) { if (mounted) setState(() { _world = OpticsWorld.empty(); _nextElementId = 1; _solve(); }); }
  }

  void _solve() => setState(() => _solved = _solver.solve(_world));

  void _onComponentDrop(String typeId, Offset worldPos) {
    final type = switch (typeId) {
      'lens_convex' || 'lens_concave' => OpticalElementType.lens,
      'mirror_plane' || 'mirror_concave' => OpticalElementType.mirror,
      'lightSource' => OpticalElementType.lightSource,
      _ => null,
    };
    if (type == null || !_policy.canAdd(type, _world)) return;
    final idx = _nextElementId++;
    final element = switch (typeId) {
      'lens_convex' => LensElement.create(id: 'lens_$idx', position: worldPos, lensType: LensType.convex, focalLength: 10),
      'lens_concave' => LensElement.create(id: 'lens_$idx', position: worldPos, lensType: LensType.concave, focalLength: -10),
      'mirror_plane' => MirrorElement.create(id: 'mirror_$idx', position: worldPos, mirrorType: MirrorType.plane),
      'mirror_concave' => MirrorElement.create(id: 'mirror_$idx', position: worldPos, mirrorType: MirrorType.concave),
      'lightSource' => LightSourceElement.create(id: 'light_$idx', position: worldPos, sourceType: SourceType.object),
      _ => throw UnsupportedError('Unknown component type: $typeId'),
    };
    setState(() { _world = _world.addElement(element); _selectedElementId = element.id; _solve(); });
  }

  void _selectElement(String? id) => setState(() => _selectedElementId = _selectedElementId == id ? null : id);
  void _removeSelected() {
    final id = _selectedElementId;
    if (id == null) return;
    final el = _world.getElementById(id);
    if (el != null && !_policy.canRemove(el)) return;
    setState(() { _world = _world.removeElement(id); _selectedElementId = null; _solve(); });
  }
  void _moveElement(String id, Offset pos) {
    final el = _world.getElementById(id);
    if (el != null && !_policy.canMove(el)) return;
    setState(() { _world = _world.moveElement(id, pos); _solve(); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_currentScenario?.name ?? '几何光学'),
      backgroundColor: const Color(0xFFE8F6FB), foregroundColor: const Color(0xFF062A3A),
      actions: [
        IconButton(onPressed: _showScenarioPicker, icon: const Icon(Icons.folder_open_rounded)),
        if (_selectedElementId != null)
          IconButton(onPressed: _removeSelected, icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626))),
        IconButton(onPressed: () => setState(() { _world = OpticsWorld.empty(); _solved = null; _selectedElementId = null; }),
            icon: const Icon(Icons.restart_alt_rounded)),
      ],
    ),
    body: SafeArea(
      child: DragDropWorkspace<String>(
        trayTitle: '元件库',
        items: _trayItems,
        traySize: 200,
        scale: 20,
        onItemDropped: _onComponentDrop,
        rightPanel: _currentScenario != null
            ? _RightPanel(scenario: _currentScenario!, world: _world)
            : null,
        canvasBuilder: (context, proj) => _OpticsScene(
          world: _world, solved: _solved, selectedId: _selectedElementId,
          projection: proj,
          onElementTap: _selectElement,
          onElementDrag: _moveElement,
        ),
      ),
    ),
  );

  void _showScenarioPicker() async {
    final r = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const ScenarioSelectionScreen()));
    if (r != null && mounted) {
      await _scenarioManager.loadScenarios();
      final world = _scenarioManager.loadScenario(r);
      setState(() { _world = world; _currentScenario = _scenarioManager.currentScenario; _nextElementId = _world.elements.length + 1; _solve(); });
    }
  }
}

// ── 光学场景内容（纯绘制，拖拽由 DragDropWorkspace 处理） ──

class _OpticsScene extends StatelessWidget {
  final OpticsWorld world; final SolvedOptics? solved; final String? selectedId;
  final CanvasProjection projection;
  final void Function(String?) onElementTap;
  final void Function(String, Offset) onElementDrag;

  const _OpticsScene({required this.world, required this.solved, required this.selectedId,
    required this.projection, required this.onElementTap, required this.onElementDrag, super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapUp: (d) {
      final wp = projection.toWorld(d.localPosition);
      for (final e in world.elements.reversed) { if (e.hitTest(wp)) { onElementTap(e.id); return; } }
      onElementTap(null);
    },
    onScaleStart: (_) {},
    onScaleUpdate: (d) {
      if (d.pointerCount >= 2) return;
      if (selectedId == null) return;
      if (d.focalPointDelta.distance < 4.0) return;
      onElementDrag(selectedId!, projection.toWorld(d.localFocalPoint));
    },
    child: SizedBox(width: projection.canvasSize.width, height: projection.canvasSize.height,
      child: Stack(children: [
        Positioned.fill(child: Container(color: const Color(0xFFF8FCFE))),
        Positioned(left: 0, top: projection.origin.dy - 1, right: 0, height: 2,
            child: Container(color: const Color(0xFF7A81CA))),
        ...world.elements.map((e) => _elementWidget(e, projection, e.id == selectedId)),
        // 渲染层不拦截点击/拖放，让事件穿透到元件和 DragTarget
        if (solved != null)
          IgnorePointer(child: Stack(children: [
            ..._rayWidgets(solved!, projection),
            _imageWidget(solved!, projection),
            ..._screenHitWidgets(solved!, projection),
            if (solved!.imageInfo != null) _debugDot(solved!.imageInfo!, projection),
          ])),
      ])),
  );

  Widget _debugDot(dynamic info, CanvasProjection p) {
    final imagePoint = info.imagePoint as Offset;
    final sp = p.toScreen(imagePoint);
    return Positioned(
      left: sp.dx - 5, top: sp.dy - 5,
      child: Container(width: 10, height: 10,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF0000))),
    );
  }

  Widget _elementWidget(OpticalElement e, CanvasProjection p, bool sel) {
    final sp = p.toScreen(Offset(e.x, e.y));
    late final double left, top;
    if (e is LightSourceElement) {
      final srch = e.objectHeight * 10;    // SVG 像素高度
      final tipX = 15.0;                   // 30px 宽，尖端在水平中心 x=32/64
      final tipY = srch * 6 / 240;         // 尖端距 SVG 顶部 y=6/240
      // 尖端对准光线起点：curObj = (src.x, src.y - objH/2)
      left = sp.dx - tipX;
      top  = sp.dy - srch - tipY;          // sp.y = world 0 的光轴，srg 底部在光轴
    } else if (e is LensElement) {
      left = sp.dx - 20; top = sp.dy - 65;
    } else {
      left = sp.dx - 3;  top = sp.dy - 40;
    }
    return Positioned(
      left: left,
      top: top,
      child: Container(
        decoration: sel ? BoxDecoration(border: Border.all(color: const Color(0xFF1177AA), width: 2),
            borderRadius: BorderRadius.circular(8), color: const Color(0xFF1177AA).withValues(alpha: 0.05)) : null,
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

  List<Widget> _rayWidgets(SolvedOptics s, CanvasProjection p) => [
        ...s.rays.where((r) => r.points.length >= 2 || r.virtualPoints.isNotEmpty)
            .map((r) => CustomPaint(painter: _RayPainter(ray: r, proj: p), size: Size.infinite)),
        ...s.virtualRays.where((r) => r.virtualPoints.isNotEmpty)
            .map((r) => CustomPaint(painter: _RayPainter(ray: r, proj: p), size: Size.infinite)),
      ];

  Widget _imageWidget(SolvedOptics s, CanvasProjection p) {
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
          transform: isUp ? Matrix4.identity() : Matrix4.diagonal3Values(1, -1, 1),
          child: SvgPicture.asset('assets/images/pencil.svg',
            width: svgW, height: hPx, fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn)),
        ),
      ),
    );
  }

  List<Widget> _screenHitWidgets(SolvedOptics s, CanvasProjection p) =>
      s.screenHits.map((h) {
        final sp = p.toScreen(h.point);
        return Positioned(
          left: sp.dx - 3, top: sp.dy - 3,
          child: Container(width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEF4444).withValues(alpha: 0.9))),
        );
      }).toList();
}

class _LensIcon extends StatelessWidget {
  final LensElement lens; const _LensIcon({required this.lens});
  @override Widget build(_) {
    final cv = lens.lensKind == LensType.convex;
    final c = cv ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);
    final bc = cv ? const Color(0xFF1E40AF) : const Color(0xFF991B1B);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 40, height: 130,
        child: CustomPaint(painter: _LensPainter(convex: cv, color: c, borderColor: bc))),
      const SizedBox(height: 2),
      Text(cv ? '凸透镜' : '凹透镜', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
    ]);
  }
}

class _LensPainter extends CustomPainter {
  final bool convex; final Color color; final Color borderColor;
  const _LensPainter({required this.convex, required this.color, required this.borderColor});
  @override void paint(Canvas can, Size sz) {
    final w=sz.width, h=sz.height, cx=w/2, cy=h/2;
    // 凸透镜：中间宽；凹透镜：中间窄。直接指定赤道半宽
    final poleW = w * 0.12;                       // 端部半宽
    final eqW = convex ? w * 0.45 : w * 0.02;     // 中间半宽：凸大/凹小
    final p = Path()
      ..moveTo(cx - poleW, 4)                     // 顶端左
      ..cubicTo(cx - eqW, h*0.15, cx - eqW, h*0.85, cx - poleW, h-4)  // 右弧
      ..lineTo(cx + poleW, h - 4)                  // 底端右
      ..cubicTo(cx + eqW, h*0.85, cx + eqW, h*0.15, cx + poleW, 4)   // 左弧
      ..close();
    can.drawPath(p, Paint()..color=color.withValues(alpha:0.7)..style=PaintingStyle.fill);
    can.drawPath(p, Paint()..color=borderColor..style=PaintingStyle.stroke..strokeWidth=2.5);
    can.drawLine(Offset(0, cy), Offset(w, cy), Paint()..color=borderColor.withValues(alpha:0.4)..strokeWidth=1);
  }
  @override bool shouldRepaint(_LensPainter o)=>o.convex!=convex||o.color!=color;
}

class _MirrorIcon extends StatelessWidget {
  final MirrorElement mirror; const _MirrorIcon({required this.mirror});
  @override Widget build(_) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 80, decoration: BoxDecoration(color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(3), border: Border.all(color: const Color(0xFF1D4ED8), width: 2))),
    const SizedBox(height: 4),
    Text(switch (mirror.mirrorKind) { MirrorType.concave => '凹面镜', MirrorType.convex => '凸面镜', MirrorType.plane => '平面镜' },
        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
  ]);
}

class _SourceIcon extends StatelessWidget {
  final LightSourceElement source; const _SourceIcon({required this.source});
  @override Widget build(_) => Column(mainAxisSize: MainAxisSize.min, children: [
    SvgPicture.asset('assets/images/pencil.svg', width: 30, height: source.objectHeight * 10, fit: BoxFit.fill),
    const SizedBox(height: 4),
    const Text('光源', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
  ]);
}

class _ScreenIcon extends StatelessWidget {
  const _ScreenIcon();
  @override Widget build(_) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 80, decoration: BoxDecoration(color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(2), border: Border.all(color: const Color(0xFF6B7280), width: 2))),
    const SizedBox(height: 4),
    const Text('光屏', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
  ]);
}

class _RayPainter extends CustomPainter {
  final RayPath ray; final CanvasProjection proj;
  const _RayPainter({required this.ray, required this.proj});
  @override void paint(Canvas c, Size s) {
    final realPts = ray.points.map(proj.toScreen).toList();
    final realPaint = Paint()
      ..color = ray.isBoundary ? const Color(0xFF071827) : const Color(0xFF22C55E)
      ..strokeWidth = ray.isBoundary ? 2 : 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < realPts.length - 1; i++) {
      c.drawLine(realPts[i], realPts[i + 1], realPaint);
    }

    final virtualPts = ray.virtualPoints.map(proj.toScreen).toList();
    if (virtualPts.length >= 2) {
      _drawDashed(c, virtualPts[0], virtualPts[1],
        Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.55)
            ..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }
  }

  void _drawDashed(Canvas c, Offset a, Offset b, Paint p) {
    final d = b - a; final len = d.distance;
    if (len == 0) return;
    final u = d / len; var traveled = 0.0;
    while (traveled < len) {
      final start = a + u * traveled;
      final end = a + u * (traveled + 6).clamp(0.0, len);
      c.drawLine(start, end, p);
      traveled += 10;
    }
  }

  @override bool shouldRepaint(_RayPainter o) => o.ray != ray;
}

class _RightPanel extends StatelessWidget {
  final LabScenario scenario; final OpticsWorld world;
  const _RightPanel({required this.scenario, required this.world, super.key});

  @override Widget build(_) => Container(width: 250, color: const Color(0xFFF9FAFB),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _header('教学目标', const Color(0xFF059669), Icons.flag_rounded),
      Expanded(child: ListView(padding: const EdgeInsets.all(8), children: [
        for (final c in scenario.objectives?.successCriteria ?? <SuccessCriterion>[])
          _listCard(const Icon(Icons.radio_button_unchecked, color: Color(0xFF9CA3AF), size: 20), c.description),
      ])),
      const Divider(height: 1),
      _header('约束条件', const Color(0xFF7C3AED), Icons.rule_rounded),
      Expanded(child: ListView(padding: const EdgeInsets.all(8), children: [
        for (final c in scenario.constraints)
          _listCard(Icon(c.validate(world) ? Icons.info_rounded : Icons.warning_rounded,
              color: c.validate(world) ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B), size: 20), c.description),
      ])),
    ]));

  Widget _header(String title, Color color, IconData icon) => Container(padding: const EdgeInsets.all(12), color: color,
      child: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));
  Widget _listCard(Widget icon, String desc) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(
    padding: const EdgeInsets.all(12), child: Row(children: [icon, const SizedBox(width: 8),
      Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))))])));
}
