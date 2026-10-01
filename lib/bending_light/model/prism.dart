import 'bl_vec2.dart';
import 'intersection.dart';
import 'prism_geometry.dart';

/// Prism wrapper (`Prism.ts`).
class Prism {
  Prism(this.shape, this.typeName) {
    _updateTranslated();
  }

  PrismShape shape;
  final String typeName;
  BlVec2 position = BlVec2.zero;
  late PrismShape translatedShape;

  void _updateTranslated() {
    translatedShape =
        shape.getTranslatedInstance(position.x, position.y);
  }

  void translate(double dx, double dy) {
    position = position.plusXY(dx, dy);
    _updateTranslated();
  }

  void setPosition(BlVec2 p) {
    position = p;
    _updateTranslated();
  }

  void rotate(double deltaAngle) {
    shape = shape.getRotatedInstance(deltaAngle, shape.getRotationCenter());
    _updateTranslated();
  }

  List<Intersection> getIntersections(BlVec2 rayTail, BlVec2 rayDir) =>
      translatedShape.getIntersections(rayTail, rayDir);

  bool contains(BlVec2 point) => translatedShape.containsPoint(point);

  Prism copy() => Prism(shape.getTranslatedInstance(0, 0), typeName)
    ..setPosition(position);
}
