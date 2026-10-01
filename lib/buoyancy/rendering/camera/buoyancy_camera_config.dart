import 'dart:ui';

import '../../layout/buoyancy_global_layout_spec.dart';
import '../transform/bvec3.dart';

/// Source camera knobs from `DensityBuoyancyScreenView` / Compare overrides.
///
/// Not a 2D pan. LayoutSpec owns screen regions; this owns THREE camera state.
class BuoyancyCameraConfig {
  const BuoyancyCameraConfig({
    required this.position,
    required this.lookAt,
    required this.up,
    required this.zoom,
    required this.viewOffset,
    this.fovDegrees = 50,
    this.near = 0.1,
    this.far = 100,
  });

  /// THREE.PerspectiveCamera default vertical FOV.
  final double fovDegrees;
  final double near;
  final double far;
  final BVec3 position;
  final BVec3 lookAt;
  final BVec3 up;
  final double zoom;
  final Offset viewOffset;

  /// Default Buoyancy screens (Explore/Lab/Shapes/Applications).
  factory BuoyancyCameraConfig.buoyancyDefault() => BuoyancyCameraConfig(
        position: BVec3(
          buoyancyDefaultCameraPosition.x,
          buoyancyDefaultCameraPosition.y,
          buoyancyDefaultCameraPosition.z,
        ),
        lookAt: BVec3(
          buoyancyCameraLookAt.x,
          buoyancyCameraLookAt.y,
          buoyancyCameraLookAt.z,
        ),
        up: const BVec3(0, 0, -1),
        zoom: buoyancyDefaultCameraZoom,
        viewOffset: Offset.zero,
      );

  /// Compare / Buoyancy Basics: lookAt (0,-0.1,0), viewOffset (-25,0).
  factory BuoyancyCameraConfig.compare() => BuoyancyCameraConfig(
        position: BVec3(
          buoyancyDefaultCameraPosition.x,
          buoyancyDefaultCameraPosition.y,
          buoyancyDefaultCameraPosition.z,
        ),
        lookAt: BVec3(
          buoyancyBasicsCameraLookAt.x,
          buoyancyBasicsCameraLookAt.y,
          buoyancyBasicsCameraLookAt.z,
        ),
        up: const BVec3(0, 0, -1),
        zoom: buoyancyDefaultCameraZoom,
        viewOffset: buoyancyBasicsViewOffset,
      );
}
