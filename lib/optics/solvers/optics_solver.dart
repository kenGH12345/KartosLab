import 'dart:ui';

import '../models/optics_world.dart';
import '../models/optical_element.dart';
import '../models/lens_element.dart';
import '../models/light_source_element.dart';
import '../models/screen_element.dart';
import '../physics/optics_math.dart';

class RayPath {
  const RayPath({required this.points, this.virtualPoints = const [], this.isBoundary = false});
  final List<Offset> points;
  final List<Offset> virtualPoints;
  final bool isBoundary;
}

class ImageStage {
  const ImageStage({
    required this.elementId, required this.objectPoint, required this.imagePoint,
    required this.objectDistance, required this.imageDistance,
    required this.magnification, required this.isVirtual,
  });
  final String elementId;
  final Offset objectPoint, imagePoint;
  final double objectDistance, imageDistance, magnification;
  final bool isVirtual;
}

class SolvedOptics {
  const SolvedOptics({
    required this.rays, this.virtualRays = const [], this.imageInfo,
    this.imageStages = const [], this.screenHits = const [],
  });
  final List<RayPath> rays;
  final List<RayPath> virtualRays;
  final ImageInfo? imageInfo;
  final List<ImageStage> imageStages;
  final List<ScreenHit> screenHits;
}

class ImageInfo {
  const ImageInfo({
    required this.imagePoint, required this.imageHeight, required this.imageX,
    required this.isVirtual, required this.magnification, required this.focalLength,
  });
  final Offset imagePoint;
  final double imageHeight, imageX, magnification, focalLength;
  final bool isVirtual;
}

class OpticalSolver {
  static const _extend = 30.0;

  SolvedOptics solve(OpticsWorld world) {
    final sources = world.elements.whereType<LightSourceElement>().toList();
    if (sources.isEmpty) return const SolvedOptics(rays: []);

    final elements = world.elements.where((e) => e is! LightSourceElement).toList();
    final imageStages = <ImageStage>[];
    final imageInfo = _computeImageChain(world, sources.first, imageStages);

    final allRays = <RayPath>[];
    final virtualRays = <RayPath>[];
    final screenHits = <ScreenHit>[];

    final lenses = elements.whereType<LensElement>().toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    for (final source in sources) {
      _drawLensRays(source, lenses, imageStages, allRays, virtualRays);
    }
    _collectScreenHits(elements, allRays, screenHits);

    return SolvedOptics(
      rays: allRays, virtualRays: virtualRays,
      imageInfo: imageInfo, imageStages: imageStages, screenHits: screenHits,
    );
  }

  void _drawLensRays(LightSourceElement src, List<LensElement> lenses,
      List<ImageStage> stages, List<RayPath> outRays, List<RayPath> virtualRays) {
    if (lenses.isEmpty) return;

    final objH = src.objectHeight;
    Offset curObj = Offset(src.x, src.y - objH / 2); // 笔尖（svg顶端）
    int stageIdx = 0;

    for (final lens in lenses) {
      final stage = stageIdx < stages.length ? stages[stageIdx] : null;
      final imgPt = stage?.imagePoint;
      final isVirt = stage?.isVirtual ?? false;
      if (stage == null) break;

      // ── 经典二光线法（物理教材标准画法） ──
      // 光线1: 平行光 → 经过透镜 → 过焦点 → 汇聚到像
      // 光线2: 中心光 → 直穿透镜中心 → 不偏折 → 汇聚到像
      final parallelHit = Offset(lens.x, curObj.dy); // 平行光水平打到透镜
      final centerHit = Offset(lens.x, lens.y);       // 中心光直穿透镜中心
      final ip = imgPt!; // stage 非空，imgPt 确定非 null

      if (!isVirt) {
        // 实像：两条光线都汇聚到像点
        outRays.add(RayPath(
          points: [curObj, parallelHit, ip,
            OpticsMath.extendFrom(ip, ip - parallelHit, _extend)],
          isBoundary: false));

        outRays.add(RayPath(
          points: [curObj, centerHit, ip,
            OpticsMath.extendFrom(ip, ip - centerHit, _extend)],
          isBoundary: true));
      } else {
        // 虚像：光线向前延伸，虚线连到虚像
        outRays.add(RayPath(
          points: [curObj, parallelHit,
            OpticsMath.extendFrom(parallelHit, parallelHit - ip, _extend)],
          virtualPoints: [parallelHit, ip],
          isBoundary: false));

        outRays.add(RayPath(
          points: [curObj, centerHit,
            OpticsMath.extendFrom(centerHit, centerHit - ip, _extend)],
          virtualPoints: [centerHit, ip],
          isBoundary: true));
      }

      curObj = ip;
      stageIdx++;
    }
  }

  void _collectScreenHits(List<OpticalElement> elements, List<RayPath> rays, List<ScreenHit> hits) {
    for (final screen in elements.whereType<ScreenElement>()) {
      for (final r in rays) {
        if (r.points.length < 2) continue;
        // 检测光线任意相邻段是否穿过光屏（支持双向光线）
        for (var i = 0; i < r.points.length - 1; i++) {
          final a = r.points[i];
          final b = r.points[i + 1];
          if ((a.dx - screen.x) * (b.dx - screen.x) >= 0) continue; // 同侧，未穿过
          final t = (screen.x - a.dx) / (b.dx - a.dx);
          final y = a.dy + t * (b.dy - a.dy);
          if ((y - screen.y).abs() < screen.height / 2) {
            hits.add(ScreenHit(screenId: screen.id, point: Offset(screen.x, y), intensity: 1.0));
            break; // 每条光线最多命中一次该光屏
          }
        }
      }
    }
  }

  ImageInfo? _computeImageChain(OpticsWorld world, LightSourceElement source, List<ImageStage> outStages) {
    final lenses = world.elements.whereType<LensElement>().toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    if (lenses.isEmpty) return null;

    Offset curObj = Offset(source.x, source.y - source.objectHeight / 2); // 笔尖
    ImageStage? lastStage;
    double lastFocalLength = 0;

    for (final lens in lenses) {
      final f = lens.lensKind == LensType.convex ? lens.focalLength.abs() : -lens.focalLength.abs();
      final u = lens.x - curObj.dx;
      if (u.abs() < 0.001) continue;
      final v = OpticsMath.imageDistance(u, f);
      final mag = -v / u;
      final imgPt = Offset(lens.x + v, lens.y + (curObj.dy - lens.y) * mag);
      final stage = ImageStage(
        elementId: lens.id, objectPoint: curObj, imagePoint: imgPt,
        objectDistance: u, imageDistance: v, magnification: mag, isVirtual: v < 0,
      );
      outStages.add(stage);
      curObj = imgPt;
      lastStage = stage;
      lastFocalLength = lens.focalLength;
    }

    if (lastStage == null) return null;
    final h = lastStage.magnification * source.objectHeight;
    return ImageInfo(
      imagePoint: lastStage.imagePoint, imageHeight: h,
      imageX: lastStage.imagePoint.dx, isVirtual: lastStage.isVirtual,
      magnification: lastStage.magnification, focalLength: lastFocalLength,
    );
  }
}
