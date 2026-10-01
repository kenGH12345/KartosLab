import 'package:flutter/material.dart';

import '../model/balloons_static_electricity_constants.dart';

/// View layout constants — PhET `BASEConstants` / `BASEColors` / `BASEView` / `ControlPanel`.
abstract final class BaseViewLayout {
  static const double layoutWidth = BaseConstants.width;
  static const double layoutHeight = BaseConstants.height;

  static const Color backgroundColor = Color(0xFF97D0FF);

  /// Control button fill — `BASEColors.controlButtonBaseColorProperty`.
  static const Color controlButtonBaseColor = Color.fromRGBO(255, 200, 0, 1);

  static const double bottomControlSpacing = 10;
  static const double controlsLeft = 70;
  static const double visibilityControlsSpacing = 50;

  /// `ResetAllButton` scale 0.96 × default scenery-phet radius 20.5.
  static const double resetAllRadius = 20.5 * 0.96;

  static const double balloonIconScale = 0.14;
  static const double greenBalloonIconX = 160;

  /// Tether attachment below knot — `BALLOON_TIE_POINT_HEIGHT`.
  static const double balloonTiePointHeight = 14;

  /// Wall image intrinsic size (source `wall.png`).
  static const double wallImageWidth = 97;
  static const double wallImageHeight = 755;

  /// Sweater image intrinsic → model scale.
  static const double sweaterImageWidth = 650;
  static const double sweaterImageHeight = 817;
}

/// Asset paths for Balloons and Static Electricity (original PhET PNGs / sounds).
abstract final class BaseAssets {
  static const String _imageRoot =
      'assets/simulations/balloons_and_static_electricity/images';
  static const String _soundRoot =
      'assets/simulations/balloons_and_static_electricity/sounds';

  static const String yellowBalloon = '$_imageRoot/balloonYellow.png';
  static const String greenBalloon = '$_imageRoot/balloonGreen.png';
  static const String sweater = '$_imageRoot/sweater.png';
  static const String wall = '$_imageRoot/wall.png';

  static const String balloonGrab = '$_soundRoot/balloonGrab006.mp3';
  static const String balloonRelease = '$_soundRoot/balloonRelease006.mp3';
  static const String balloonHitSweater = '$_soundRoot/balloonHitSweater.mp3';
  static const String wallContact = '$_soundRoot/wallContact.mp3';
  static const String chargeDeflection = '$_soundRoot/chargeDeflection.mp3';
  static const String carrier000 = '$_soundRoot/carrier000.wav';
  static const String carrier002 = '$_soundRoot/carrier002.wav';
}
