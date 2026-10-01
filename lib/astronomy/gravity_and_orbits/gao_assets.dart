/// Asset paths + labels for Gravity and Orbits.
library;

import 'gao_constants.dart';
import 'model/body_type.dart';
import 'model/gao_body.dart';

class GaoAssets {
  GaoAssets._();

  static String bodyImage(GaoBody body) {
    switch (body.type) {
      case GaoBodyType.star:
        return GaoConstants.sunAsset;
      case GaoBodyType.planet:
        return (body.mass - body.tickMass).abs() < 1e-6 * body.tickMass
            ? GaoConstants.earthAsset
            : GaoConstants.planetGenericAsset;
      case GaoBodyType.moon:
        return (body.mass - body.tickMass).abs() < 1e-6 * body.tickMass
            ? GaoConstants.moonAsset
            : GaoConstants.moonGenericAsset;
      case GaoBodyType.satellite:
        return GaoConstants.spaceStationAsset;
    }
  }

  static String labelFor(GaoBodyType type) {
    switch (type) {
      case GaoBodyType.star:
        return 'Star';
      case GaoBodyType.planet:
        return 'Planet';
      case GaoBodyType.moon:
        return 'Moon';
      case GaoBodyType.satellite:
        return 'Satellite';
    }
  }
}
