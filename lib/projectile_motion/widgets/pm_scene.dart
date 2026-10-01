import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../controller/projectile_motion_controller.dart';
import '../painters/cannon_painter.dart';
import '../painters/scene_painters.dart';
import '../painters/tools_painters.dart';
import '../painters/trajectory_painter.dart';
import '../pm_constants.dart';
import '../transform/pm_transform.dart';
import '../view/pm_image_cache.dart';

enum PmDragTarget {
  none,
  cannonAngle,
  cannonHeight,
  target,
  tapeBase,
  tapeTip,
  probe,
}

/// 播放区：painters 叠层 + 拖拽手势。
/// 拖拽语义逐行对照 CannonNode.ts:451-541 / TargetNode.ts:112-133 /
/// ToolboxPanel.ts:86-127。
class PmScene extends StatefulWidget {
  const PmScene({
    super.key,
    required this.controller,
    required this.images,
    required this.showHeightCue,
    required this.flatironsVisible,
    required this.angleSnapDegrees,
    this.toolboxBoundsInScene,
  });

  final ProjectileMotionController controller;
  final PmImageCache images;
  final bool showHeightCue;
  final bool flatironsVisible;

  /// 5（普通屏）/ 1（Lab preciseCannonDelta）
  final double angleSnapDegrees;

  /// Toolbox 在 scene 坐标系中的矩形；工具拖回判定用。
  final Rect? Function()? toolboxBoundsInScene;

  @override
  State<PmScene> createState() => PmSceneState();
}

class PmSceneState extends State<PmScene> {
  PmDragTarget _dragging = PmDragTarget.none;

  // cannon angle drag
  double _startAngle = 0;
  double _startPointAngle = 0;

  // cannon height drag
  double _startPointerY = 0;
  double _startHeightViewY = 0;

  // target drag
  double _startPointerX = 0;
  double _startTargetX = 0;

  /// 工具拖拽：指针相对工具锚点的 view 偏移（finger = anchor + offset）
  Offset _toolGrabOffset = Offset.zero;

  /// 本次拖拽是否已离开 toolbox（滞回，避免刚拖出就因重叠被收回）
  bool _toolHasLeftToolbox = false;

  ProjectileMotionController get controller => widget.controller;
  PmTransform get transform => PmTransform(zoom: controller.model.zoom);

  bool get isDraggingTool =>
      _dragging == PmDragTarget.probe ||
      _dragging == PmDragTarget.tapeBase ||
      _dragging == PmDragTarget.tapeTip;

  /// 从 toolbox 拖出调用：激活工具并开始拖拽。
  /// [viewPos] 已是 scene 坐标；probe 会再左偏（ToolboxPanel:91）。
  void startToolDrag(PmDragTarget tool, Offset viewPos) {
    final model = controller.model;
    setState(() => _dragging = tool);
    _toolHasLeftToolbox = false;
    if (tool == PmDragTarget.probe) {
      model.dataProbe.isActive = true;
      // 指针不挡在探针上：view 左偏 180（ToolboxPanel:91）
      final placed = viewPos + const Offset(-180, 0);
      model.dataProbe.position = transform.viewToModel(placed);
      model.dataProbe.updateData();
      _toolGrabOffset = viewPos - placed; // (180, 0)
    } else if (tool == PmDragTarget.tapeBase) {
      model.measuringTape.isActive = true;
      final base = transform.viewToModel(viewPos);
      // 保持默认 tip−base（ToolboxPanel:114-125）
      final tipDelta =
          model.measuringTape.tipPosition - model.measuringTape.basePosition;
      model.measuringTape.basePosition = base;
      model.measuringTape.tipPosition =
          base + (tipDelta == Offset.zero ? const Offset(1, 0) : tipDelta);
      _toolGrabOffset = Offset.zero;
    }
    controller.model.refresh();
  }

  /// 工具拖拽结束：曾离开 toolbox 后再交叠则收回（ToolboxPanel:74-82）
  void endToolDrag(Rect toolboxBounds) {
    _maybeReturnTool(toolboxBounds);
    setState(() => _dragging = PmDragTarget.none);
    controller.model.refresh();
  }

  bool _toolOverlapsToolbox(Rect box) {
    final model = controller.model;
    if (_dragging == PmDragTarget.probe && model.dataProbe.isActive) {
      return box.overlaps(_probeBounds());
    }
    if ((_dragging == PmDragTarget.tapeBase ||
            _dragging == PmDragTarget.tapeTip) &&
        model.measuringTape.isActive) {
      return box.overlaps(_tapeBaseBounds());
    }
    return false;
  }

  Rect _probeBounds() {
    final origin = transform.modelToView(controller.model.dataProbe.position);
    return Rect.fromLTRB(
      origin.dx - 15,
      origin.dy - 47.5,
      origin.dx + 15 + 6 + 161,
      origin.dy + 47.5,
    );
  }

  Rect _tapeBaseBounds() {
    final base =
        transform.modelToView(controller.model.measuringTape.basePosition);
    return Rect.fromLTWH(base.dx - 50, base.dy - 40, 90, 50);
  }

  void _updateToolboxHysteresis() {
    if (!isDraggingTool) return;
    final box = widget.toolboxBoundsInScene?.call();
    if (box == null) {
      // 测试直接 dragToolTo：移动即视为已离开，允许随后拖回
      _toolHasLeftToolbox = true;
      return;
    }
    if (!_toolOverlapsToolbox(box.inflate(-5))) {
      _toolHasLeftToolbox = true;
    }
  }

  void _maybeReturnTool(Rect toolboxBounds) {
    if (!isDraggingTool) return;
    final box = toolboxBounds.inflate(-5);
    if (!_toolOverlapsToolbox(box)) {
      _toolHasLeftToolbox = true;
      return;
    }
    if (!_toolHasLeftToolbox) return;
    final model = controller.model;
    if (_dragging == PmDragTarget.probe) {
      model.dataProbe.isActive = false;
      model.dataProbe.dataPoint = null;
    } else {
      model.measuringTape.isActive = false;
    }
  }

  // ── 命中测试 ──────────────────────────────────────────────────────────

  /// 黑色十字附近 / 炮座 / 圆柱 / 高度标签 / cue → 改高度
  /// （CannonNode:535-541；用户主操作区 = 枢轴黑色十字）
  bool _hitCannonHeight(Offset viewPos) {
    final model = controller.model;
    final t = transform;
    final pivot = t.modelToView(Offset(0, model.cannonHeight));
    final s = t.modelToViewDeltaX(PmConstants.cannonLength) / 275;

    // 枢轴黑色十字抓手（优先，全屏通用）
    if ((viewPos - pivot).distance <= 40) return true;

    // base images：[-80,-39]-[80,135]*s
    final baseRect = Rect.fromLTWH(
        pivot.dx - 80 * s, pivot.dy - 39 * s, 160 * s, 174 * s);
    if (baseRect.inflate(6).contains(viewPos)) return true;

    // 圆柱侧面 + 顶
    final cylinderX = t.origin.dx +
        t.modelToViewDeltaX(PmConstants.cylinderDistanceFromOrigin);
    final rx = 210 * s;
    final cylinderTopY = pivot.dy + 125 * s;
    final cylinderRect = Rect.fromLTRB(
        cylinderX - rx,
        math.min(cylinderTopY, t.origin.dy),
        cylinderX + rx,
        t.origin.dy + 20 * s);
    if (cylinderRect.contains(viewPos)) return true;

    // 高度标签 + Intro cue 箭头
    final leaderX =
        t.origin.dx + t.modelToViewDeltaX(PmConstants.heightLeaderLineX);
    final labelRect = Rect.fromCenter(
        center: Offset(leaderX, pivot.dy - 8), width: 72, height: 36);
    if (labelRect.contains(viewPos)) return true;
    if (widget.showHeightCue) {
      final cueRect = Rect.fromCenter(
          center: Offset(leaderX, pivot.dy), width: 32, height: 72);
      if (cueRect.contains(viewPos)) return true;
    }
    return false;
  }

  /// 炮管远端 → 改角度（CannonNode:451-497 cannonBarrelTop）
  /// 枢轴附近留给高度，避免十字拖动变成转角。
  bool _hitCannonBarrel(Offset viewPos) {
    final model = controller.model;
    final t = transform;
    final pivot = t.modelToView(Offset(0, model.cannonHeight));
    if ((viewPos - pivot).distance <= 40) return false;

    final s = t.modelToViewDeltaX(PmConstants.cannonLength) / 275;
    final d = viewPos - pivot;
    final rad = model.cannonAngle * math.pi / 180;
    final local = Offset(
          d.dx * math.cos(rad) - d.dy * math.sin(rad),
          d.dx * math.sin(rad) + d.dy * math.cos(rad),
        ) /
        s;
    // 只认炮管身段（local.dx 足够大），不含枪尾关节
    return local.dx >= 28 &&
        local.dx <= 287 &&
        local.dy >= -23 &&
        local.dy <= 83;
  }

  bool _hitTarget(Offset viewPos) {
    final t = transform;
    final center = t.modelToView(Offset(controller.model.target.x, 0));
    final rx = t.modelToViewDeltaX(PmConstants.targetWidth) / 2;
    final ry = rx * PmConstants.targetHeight / PmConstants.targetWidth;
    // 靶面 + 下方读数标签
    final targetRect = Rect.fromCenter(
        center: center, width: rx * 2 + 12, height: ry * 2 + 34);
    return targetRect.contains(viewPos);
  }

  PmDragTarget _hitTest(Offset viewPos) {
    final model = controller.model;
    final t = transform;
    // 工具优先（可在画面上自由拖动 / 拖回 toolbox）
    if (model.dataProbe.isActive &&
        PmToolsHitTest.hitProbe(t, model.dataProbe, viewPos)) {
      return PmDragTarget.probe;
    }
    if (model.measuringTape.isActive) {
      if (PmToolsHitTest.hitTapeTip(t, model.measuringTape, viewPos)) {
        return PmDragTarget.tapeTip;
      }
      if (PmToolsHitTest.hitTapeBase(t, model.measuringTape, viewPos)) {
        return PmDragTarget.tapeBase;
      }
    }
    // 高度（十字）优先于炮管转角
    if (_hitCannonHeight(viewPos)) return PmDragTarget.cannonHeight;
    if (_hitCannonBarrel(viewPos)) return PmDragTarget.cannonAngle;
    if (_hitTarget(viewPos)) return PmDragTarget.target;
    return PmDragTarget.none;
  }

  // ── 手势 ──────────────────────────────────────────────────────────────

  int? _pointerId;

  @override
  void dispose() {
    _unbindPointer();
    super.dispose();
  }

  void _unbindPointer() {
    final id = _pointerId;
    if (id != null) {
      GestureBinding.instance.pointerRouter.removeRoute(id, _onRoutedPointer);
      _pointerId = null;
    }
  }

  void _beginPointerDrag(Offset pos) {
    final model = controller.model;
    final t = transform;
    setState(() => _dragging = _hitTest(pos));
    switch (_dragging) {
      case PmDragTarget.cannonAngle:
        _startAngle = model.cannonAngle;
        final pivot = t.modelToView(Offset(0, model.cannonHeight));
        _startPointAngle = (pos - pivot).direction;
      case PmDragTarget.cannonHeight:
        _startPointerY = pos.dy;
        _startHeightViewY = t.modelToView(Offset(0, model.cannonHeight)).dy;
      case PmDragTarget.target:
        _startPointerX = pos.dx;
        _startTargetX = model.target.x;
      case PmDragTarget.probe:
        _toolGrabOffset = pos - t.modelToView(model.dataProbe.position);
        _toolHasLeftToolbox = true;
      case PmDragTarget.tapeBase:
        _toolGrabOffset = pos - t.modelToView(model.measuringTape.basePosition);
        _toolHasLeftToolbox = true;
      case PmDragTarget.tapeTip:
        _toolGrabOffset = pos - t.modelToView(model.measuringTape.tipPosition);
        _toolHasLeftToolbox = true;
      case PmDragTarget.none:
        break;
    }
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_pointerId != null) return;
    _pointerId = e.pointer;
    GestureBinding.instance.pointerRouter.addRoute(e.pointer, _onRoutedPointer);
    _beginPointerDrag(e.localPosition);
  }

  /// 上层工具叠层命中卷尺/探针时接管指针（画在右侧面板之上）。
  bool tryHandleToolPointerDown(int pointer, Offset scenePos) {
    if (_pointerId != null) return false;
    final hit = _hitTest(scenePos);
    if (hit != PmDragTarget.probe &&
        hit != PmDragTarget.tapeBase &&
        hit != PmDragTarget.tapeTip) {
      return false;
    }
    _pointerId = pointer;
    GestureBinding.instance.pointerRouter.addRoute(pointer, _onRoutedPointer);
    _beginPointerDrag(scenePos);
    return true;
  }

  void _onRoutedPointer(PointerEvent e) {
    if (e.pointer != _pointerId) return;
    if (e is PointerMoveEvent) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      _applyDrag(box.globalToLocal(e.position));
    } else if (e is PointerUpEvent || e is PointerCancelEvent) {
      _unbindPointer();
      _finishPointerDrag();
    }
  }

  /// toolbox 拖出时的转发入口（坐标须已是 scene 坐标系）
  void dragToolTo(Offset pos) => _applyDrag(pos);

  void _applyDrag(Offset pos) {
    final model = controller.model;
    final t = transform;
    switch (_dragging) {
      case PmDragTarget.cannonAngle:
        // CannonNode:462-491
        final pivot = t.modelToView(Offset(0, model.cannonHeight));
        final mouseAngle = (pos - pivot).direction;
        final changeDeg = (_startPointAngle - mouseAngle) * 180 / math.pi;
        final unbounded = _startAngle + changeDeg;
        final h = model.cannonHeight;
        final minAngle = h < 4
            ? PmConstants.angleRangeMins[h.floor()]
            : PmConstants.cannonAngleMin;
        const maxAngle = PmConstants.cannonAngleMax;
        if (unbounded >= minAngle && unbounded <= maxAngle) {
          final delta = widget.angleSnapDegrees;
          model.setCannonAngle((unbounded / delta).round() * delta);
        } else if (maxAngle + minAngle < 2 * model.cannonAngle) {
          model.setCannonAngle(maxAngle);
        } else {
          model.setCannonAngle(minAngle.toDouble());
        }
      case PmDragTarget.cannonHeight:
        // CannonNode:506-524
        final heightChange = pos.dy - _startPointerY;
        final unbounded =
            t.viewToModel(Offset(0, _startHeightViewY + heightChange)).dy;
        if (unbounded >= PmConstants.cannonHeightMin &&
            unbounded <= PmConstants.cannonHeightMax) {
          model.setCannonHeight(unbounded.roundToDouble());
        } else if (PmConstants.cannonHeightMax + PmConstants.cannonHeightMin <
            2 * model.cannonHeight) {
          model.setCannonHeight(PmConstants.cannonHeightMax);
        } else {
          model.setCannonHeight(PmConstants.cannonHeightMin);
        }
      case PmDragTarget.target:
        // TargetNode:112-133：仅水平，snap 0.1，clamp 到视窗
        final dx = t.viewToModelDeltaX(pos.dx - _startPointerX);
        final minX = t.viewToModel(Offset.zero).dx;
        final maxX =
            t.viewToModel(const Offset(PmConstants.layoutWidth, 0)).dx;
        final unbounded = (_startTargetX + dx).clamp(minX, maxX);
        final snapped = (unbounded * 10).round() / 10;
        controller.model.target.x = snapped;
        controller.model.refresh();
      case PmDragTarget.probe:
        model.dataProbe.position =
            t.viewToModel(pos - _toolGrabOffset);
        model.dataProbe.updateData();
        model.refresh();
      case PmDragTarget.tapeBase:
        final newBase = t.viewToModel(pos - _toolGrabOffset);
        final delta = newBase - model.measuringTape.basePosition;
        model.measuringTape.basePosition = newBase;
        model.measuringTape.tipPosition =
            model.measuringTape.tipPosition + delta;
        model.refresh();
      case PmDragTarget.tapeTip:
        model.measuringTape.tipPosition =
            t.viewToModel(pos - _toolGrabOffset);
        model.refresh();
      case PmDragTarget.none:
        break;
    }
    _updateToolboxHysteresis();
  }

  void _finishPointerDrag() {
    if (isDraggingTool) {
      final box = widget.toolboxBoundsInScene?.call();
      if (box != null) _maybeReturnTool(box);
    } else if (_dragging == PmDragTarget.cannonHeight) {
      widget.controller.model.refresh();
    }
    setState(() => _dragging = PmDragTarget.none);
  }

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final t = transform;
    // 按下即拖（PhET DragListener），不走 GestureDetector 的 pan slop
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PmBackgroundPainter(
                transform: t,
                images: widget.images,
                flatironsVisible: widget.flatironsVisible,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: PmTargetPainter(transform: t, target: model.target),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: PmCannonPainter(
                transform: t,
                images: widget.images,
                height: model.cannonHeight,
                angleDegrees: model.cannonAngle,
                muzzleFlashAge: model.muzzleFlashAge,
                showHeightCue: widget.showHeightCue &&
                    _dragging != PmDragTarget.cannonHeight,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: PmTrajectoriesPainter(
                transform: t,
                images: widget.images,
                trajectories: model.trajectories,
                viewProperties: controller.viewProperties,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
