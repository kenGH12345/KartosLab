import 'dart:ui';

/// 统一画布投影：world ↔ screen 仿射变换（screen = world × scale × zoom + origin）。
///
/// 合并自 CanvasProjection（原 drag_drop_workspace.dart · optics 系 · origin 固定 0.55H）
/// 与 SceneProjection（原 circuit 两处重复定义 · origin 注入 + zoom）。
/// 消费模式见 DropCanvas.projectionFactory（drag_drop_workspace.dart）。
///
/// - [origin]：world 原点在屏幕上的位置（如 optics: (w/2, h*0.55) 光轴；circuit: (w/2, h/2) 中心）
/// - [scale]：世界单位 → 屏幕像素的基础换算（optics: 20；circuit: 1）
/// - [zoom]：用户交互缩放（circuit 0.6~2.0；默认 1.0 = 无缩放）
class SceneProjection {
  const SceneProjection({
    required this.origin,
    this.scale = 1.0,
    this.zoom = 1.0,
  });

  final Offset origin;
  final double scale;
  final double zoom;

  /// 有效比例（scale × zoom）
  double get effectiveScale => scale * zoom;

  Offset toScreen(Offset world) => Offset(
        world.dx * scale * zoom + origin.dx,
        world.dy * scale * zoom + origin.dy,
      );

  Offset toWorld(Offset screen) => Offset(
        (screen.dx - origin.dx) / (scale * zoom),
        (screen.dy - origin.dy) / (scale * zoom),
      );

  double toScreenLength(double world) => world * scale * zoom;
}
