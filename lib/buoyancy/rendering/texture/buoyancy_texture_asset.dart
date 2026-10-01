import 'package:flutter/material.dart';

import '../../domain/material/buoyancy_material.dart';

/// Source JPEG/PNG extracted from density-buoyancy-common `images/*.ts`.
class BuoyancyTextureAsset {
  BuoyancyTextureAsset._();

  static const wood = 'assets/buoyancy/images/wood_col.jpg';
  static const brick = 'assets/buoyancy/images/brick_col.jpg';
  static const foam = 'assets/buoyancy/images/foam_col.jpg';
  static const ice = 'assets/buoyancy/images/ice_col.jpg';
  static const metal = 'assets/buoyancy/images/metal_col.jpg';
  static const greyMetal = 'assets/buoyancy/images/grey_metal_col.jpg';
  static const boatIcon = 'assets/buoyancy/images/boat_icon.png';
  static const bottleIcon = 'assets/buoyancy/images/bottle_icon.png';
  static const singleCuboid = 'assets/buoyancy/images/single_cuboid.png';
  static const doubleCuboid = 'assets/buoyancy/images/double_cuboid.png';
  /// Source: scenery-phet `images/resetArrow.png` (Applications resetBoatButton).
  static const resetArrow = 'assets/buoyancy/images/reset_arrow.png';

  static const List<String> materialColorMaps = [
    wood,
    brick,
    foam,
    ice,
    metal,
    greyMetal,
  ];

  static String? pathForMaterial(BuoyancyMaterial m) {
    switch (m.id) {
      case 'wood':
        return wood;
      case 'brick':
        return brick;
      case 'styrofoam':
        return foam;
      case 'ice':
        return ice;
      case 'aluminum':
      case 'copper':
      case 'gold':
      case 'boatHull':
        return metal;
      case 'pvc':
      case 'concrete':
        return greyMetal;
      default:
        return null;
    }
  }

  static Color fallbackColor(BuoyancyMaterial m) {
    switch (m.id) {
      case 'wood':
        return const Color(0xFFB57A3E);
      case 'brick':
        return const Color(0xFFB54A3A);
      case 'styrofoam':
        return const Color(0xFFE8E0C8);
      case 'ice':
        return const Color(0xFFB8D4E8);
      case 'aluminum':
      case 'boatHull':
        return const Color(0xFFC5CCD4);
      case 'water':
        return const Color(0x6633AAFF);
      // Applications bottle uses customSolid; BottleView uses translucent white plastic.
      case 'custom':
        return const Color(0xAAD0D8E0);
      default:
        return const Color(0xFF888888);
    }
  }
}
