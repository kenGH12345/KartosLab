/// 核渲染 Painter：按 zLayer 自后向前绘制核子渐变球。
///
/// 视觉逐项对标 shred `ParticleNode`：
/// - 径向渐变：中心偏左上 (-0.4r, -0.4r)、半径 1.6r、白色 → 基色（3D 观感）
/// - 描边 = 基色
/// - 半径 = [BanConstants.nucleonRadius]（10 px，与原版一致）
///
/// 基色 [已确认] PARTICLE_COLORS：质子 #D14600、中子 ≈#737373（gray 加深 10%）。
/// 电子云：[已确认] ParticleAtomNode 单个径向渐变圆，z 在核子之后
/// （先画云再画核子）。空核虚线圆同文件 emptyAtomCircle。
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../common/widgets/drag_drop_workspace.dart';
import '../ban_constants.dart';
import '../model/build_a_nucleus_state.dart';
import '../model/electron_cloud.dart';
import '../model/nucleon.dart';
import '../model/nucleus_layout.dart';

class NucleusPainter extends CustomPainter {
  NucleusPainter({
    required this.state,
    required this.proj,
    this.showElectronCloud = true,
  });

  final BuildANucleusState state;
  final CanvasProjection proj;

  /// [已确认] ShowElectronCloudCheckbox → electronCloud.visible
  final bool showElectronCloud;

  static const Color protonColor = Color(BanConstants.protonColorValue);
  static const Color neutronColor = Color(BanConstants.neutronColorValue);

  @override
  void paint(Canvas canvas, Size size) {
    // z-order [已确认] ParticleAtomNode.options.children：
    // emptyAtomCircle → electronCloud → nucleonLayers（云在核子后面）。
    _paintEmptyAtomCircle(canvas);
    if (showElectronCloud) _paintElectronCloud(canvas);

    // 核内核子 + 衰变发射粒子按 zLayer 混排（β 发射粒子在换型核子之后一层，
    // [已确认] betaDecay 的 zLayer+1）。
    final nucleons = <Nucleon>[...state.protons, ...state.neutrons]
      ..sort((a, b) => b.zLayer.compareTo(a.zLayer));
    final emitted = state.outgoingParticles.toList()
      ..sort((a, b) => b.zLayer.compareTo(a.zLayer));
    // 合并两类并保持「zLayer 大者先画」： emitted 与核内共享层级体系。
    final merged = <Object>[...nucleons, ...emitted];
    merged.sort((a, b) {
      final za = a is Nucleon ? a.zLayer : (a as EmittedParticle).zLayer;
      final zb = b is Nucleon ? b.zLayer : (b as EmittedParticle).zLayer;
      return zb.compareTo(za);
    });
    for (final item in merged) {
      if (item is Nucleon) {
        _paintNucleon(canvas, item);
      } else {
        _paintEmitted(canvas, item as EmittedParticle);
      }
    }
    // 飞行中的核子（生成器 → 核中心途中）。[已确认] incoming 粒子原版可见
    for (final n in state.incomingNucleons) {
      _paintNucleon(canvas, n);
    }
    // 归位动画中的核子（飞回生成器途中）。[已确认] animateAndRemoveParticle
    // 飞行阶段粒子仍可见
    for (final n in state.returningNucleons) {
      _paintNucleon(canvas, n);
    }
    // 拖拽中的核子不在核内列表，zLayer 0 = 最前（最后绘制）。
    // [已确认] BANModel userControlledListener
    for (final n in state.draggedNucleons) {
      _paintNucleon(canvas, n);
    }
  }

  /// 空核虚线圆。仅 massNumber==0 可见。
  /// [已确认] ParticleAtomNode.emptyAtomCircle：radius = particleRadius-1、
  /// stroke Color.GRAY、lineDash [2,2]、lineWidth 1；
  /// Multilink 在 proton+neutron===0 时 visible。
  void _paintEmptyAtomCircle(Canvas canvas) {
    if (state.massNumber != 0) return;
    final center = proj.origin;
    final r = (BanConstants.nucleonRadius - 1) * proj.scale;
    _paintDashedCircle(
      canvas,
      center,
      r,
      const Color(0xFF808080), // [已确认] scenery Color.GRAY = CSS gray
    );
  }

  /// 电子云：单个填充圆，无轨道点、无动画。
  /// 渐变 [已确认] BANConstants.ELECTRON_CLOUD_FILL_GRADIENT：
  /// RadialGradient(0,0,0 → 0,0,r) stop 0 alpha 1、stop 0.9 alpha 0。
  void _paintElectronCloud(Canvas canvas) {
    final reading = ElectronCloudReading.fromState(state);
    if (reading.isTransparent) return;
    final center = proj.origin;
    // [推测] atomCenter.x → origin.dx（原版 SCREEN_VIEW_ATOM_CENTER_X = width/3）
    final radius = reading.viewRadius(center.dx);
    if (radius <= 0) return;
    const electron = Color(BanConstants.electronColorValue);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [electron, electron.withValues(alpha: 0)],
          [0.0, 0.9],
        ),
    );
  }

  void _paintDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    const dash = 2.0;
    const gap = 2.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash < metric.length) ? d + dash : metric.length;
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  /// 衰变发射粒子。颜色 [已确认] PARTICLE_COLORS：electron 蓝、
  /// positron rgb(53,182,74)；半径 8（ShredConstants.ELECTRON_RADIUS）。
  /// α 渲染为 2p2n 菱形簇（[已确认] AlphaParticle 内部即 reconfigureNucleus
  /// 四核子菱形）。
  void _paintEmitted(Canvas canvas, EmittedParticle p) {
    final center = proj.toScreen(Offset(p.x, p.y));
    switch (p.type) {
      case EmittedParticleType.proton:
        _paintBall(canvas, center, BanConstants.nucleonRadius * proj.scale,
            const Color(BanConstants.protonColorValue));
      case EmittedParticleType.neutron:
        _paintBall(canvas, center, BanConstants.nucleonRadius * proj.scale,
            const Color(BanConstants.neutronColorValue));
      case EmittedParticleType.electron:
        _paintBall(canvas, center, 8 * proj.scale, Colors.blue);
      case EmittedParticleType.positron:
        _paintBall(
            canvas, center, 8 * proj.scale, const Color(0xFF35B64A));
      case EmittedParticleType.alpha:
        _paintAlphaCluster(canvas, center);
    }
  }

  /// α 簇：2p2n 菱形（复用 NucleusLayout 的 4 核子情形）。
  void _paintAlphaCluster(Canvas canvas, Offset center) {
    final members = [
      Nucleon(id: -1, type: NucleonType.proton),
      Nucleon(id: -2, type: NucleonType.proton),
      Nucleon(id: -3, type: NucleonType.neutron),
      Nucleon(id: -4, type: NucleonType.neutron),
    ];
    NucleusLayout.reconfigure(
      members.where((n) => n.type == NucleonType.proton).toList(),
      members.where((n) => n.type == NucleonType.neutron).toList(),
      nucleonRadius: BanConstants.nucleonRadius * proj.scale,
    );
    for (final m in members) {
      _paintBall(
          canvas,
          center + Offset(m.destX, m.destY),
          BanConstants.nucleonRadius * proj.scale,
          m.type == NucleonType.proton
              ? const Color(BanConstants.protonColorValue)
              : const Color(BanConstants.neutronColorValue));
    }
  }

  void _paintNucleon(Canvas canvas, Nucleon nucleon) {
    final center = proj.toScreen(Offset(nucleon.x, nucleon.y));
    final r = BanConstants.nucleonRadius * proj.scale;
    _paintBall(canvas, center, r, baseColorFor(nucleon));
  }

  /// 核子当前基色：β 换色动画中按 colorProgress 线性插值（旧类型色 →
  /// 新型色）；渐变随基色同步（与 ParticleNode 由基色重建填充同构）。
  /// [已确认] changeNucleonType 的 Color.interpolateRGBA（逐通道线性，
  /// 与 Color.lerp 等价）
  static Color baseColorFor(Nucleon nucleon) {
    final target =
        nucleon.type == NucleonType.proton ? protonColor : neutronColor;
    final from = nucleon.colorAnimatingFrom;
    if (from == null) return target;
    final fromColor = from == NucleonType.proton ? protonColor : neutronColor;
    return Color.lerp(fromColor, target, nucleon.colorProgress)!;
  }

  /// 渐变球：[已确认] ParticleNode.updateFill——径向渐变中心偏左上
  /// (-0.4r, -0.4r)、半径 1.6r、白 → 基色；描边 = 基色。
  void _paintBall(Canvas canvas, Offset center, double r, Color base) {
    final gradientCenter = Offset(center.dx - r * 0.4, center.dy - r * 0.4);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        gradientCenter,
        r * 1.6,
        [Colors.white, base],
      );
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = base);
  }

  // 核子位置/计数在 State 内就地可变，无法靠引用比较判断 → 恒重绘（与工程
  // 现有 painter 惯例一致，画面元素少、开销可忽略）。
  @override
  bool shouldRepaint(NucleusPainter oldDelegate) => true;
}
