import 'dart:math' as math;
import 'dart:ui';

import '../../layout/buoyancy_global_layout_spec.dart';
import '../camera/buoyancy_camera_config.dart';
import 'bvec3.dart';

/// Minimal source-faithful THREE perspective adapter.
///
/// KartosLab has no THREE/flutter_gl renderer (MISSING). This adapter is
/// ADAPTABLE: same camera position / lookAt / up / zoom / viewOffset / FOV
/// concepts as `THREEModelViewTransform`, not a 2D meter→pixel multiply.
class BuoyancyThreeTransform {
  BuoyancyThreeTransform({
    required this.camera,
    required this.frame,
  }) {
    _build();
  }

  final BuoyancyCameraConfig camera;
  final BuoyancyDesignFrame frame;

  late final BVec3 _camX;
  late final BVec3 _camY;
  late final BVec3 _camZ;
  late final double _tanHalfFov;

  void _build() {
    // THREE.Matrix4.lookAt(eye, target, up) → camera world axes.
    var z = (camera.position - camera.lookAt);
    if (z.length == 0) {
      z = const BVec3(0, 0, 1);
    }
    z = z.normalized();
    var x = camera.up.cross(z);
    if (x.length == 0) {
      z = BVec3(z.x + 0.0001, z.y, z.z).normalized();
      x = camera.up.cross(z);
    }
    x = x.normalized();
    final y = z.cross(x).normalized();
    _camX = x;
    _camY = y;
    _camZ = z;
    _tanHalfFov = math.tan(camera.fovDegrees * math.pi / 360);
  }

  /// World / model meters → camera space (THREE: camera looks down −Z).
  BVec3 worldToCamera(BVec3 world) {
    final d = world - camera.position;
    return BVec3(d.dot(_camX), d.dot(_camY), d.dot(_camZ));
  }

  /// Camera space → NDC xy (clip.w divided). z kept as camera z for depth.
  Offset cameraToNdc(BVec3 cam) {
    final denom = -cam.z;
    if (denom.abs() < 1e-12) {
      return Offset.zero;
    }
    final aspect = buoyancyDesignWidth / buoyancyDesignHeight;
    final ndcX =
        cam.x * camera.zoom / (_tanHalfFov * aspect * denom);
    final ndcY = cam.y * camera.zoom / (_tanHalfFov * denom);
    return Offset(ndcX, ndcY);
  }

  /// NDC → Joist layoutBounds pixels (+y down) plus source viewOffset.
  Offset ndcToDesign(Offset ndc) {
    return Offset(
      (ndc.dx * 0.5 + 0.5) * buoyancyDesignWidth + camera.viewOffset.dx,
      (1 - (ndc.dy * 0.5 + 0.5)) * buoyancyDesignHeight + camera.viewOffset.dy,
    );
  }

  Offset designToViewport(Offset design) => frame.designToViewport(design);

  Offset modelToView(BVec3 world) =>
      designToViewport(ndcToDesign(cameraToNdc(worldToCamera(world))));

  Offset modelMetersToView(double x, double y, [double z = 0]) =>
      modelToView(BVec3(x, y, z));

  /// Screen viewport → world ray (`getRayFromScreenPoint`).
  BuoyancyRay rayFromViewport(Offset viewportPoint) {
    final design = frame.viewportToDesign(viewportPoint);
    final ndcX = ((design.dx - camera.viewOffset.dx) / buoyancyDesignWidth - 0.5) * 2;
    final ndcY = (0.5 - (design.dy - camera.viewOffset.dy) / buoyancyDesignHeight) * 2;
    final aspect = buoyancyDesignWidth / buoyancyDesignHeight;
    final tan = _tanHalfFov / camera.zoom;
    BVec3 camDir(double zCam) {
      // Point on view plane at camera-z = zCam (negative = in front).
      return BVec3(ndcX * tan * aspect * -zCam, ndcY * tan * -zCam, zCam);
    }

    final nearCam = camDir(-camera.near);
    final farCam = camDir(-camera.far);
    BVec3 camToWorld(BVec3 c) =>
        camera.position + _camX * c.x + _camY * c.y + _camZ * c.z;
    final o = camToWorld(nearCam);
    final f = camToWorld(farCam);
    return BuoyancyRay(o, (f - o).normalized());
  }

  /// Intersect ray with plane z = planeZ (source uses Plane3(Z_UNIT, z)).
  BVec3? intersectZPlane(BuoyancyRay ray, double planeZ) {
    if (ray.direction.z.abs() < 1e-12) {
      return null;
    }
    final t = (planeZ - ray.origin.z) / ray.direction.z;
    if (t < 0) {
      return null;
    }
    return ray.at(t);
  }
}
