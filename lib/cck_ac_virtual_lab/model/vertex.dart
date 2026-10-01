import 'cck_vec.dart';

class CckVertex {
  CckVertex(this.id, CckVec position)
      : x = position.x,
        y = position.y,
        unsnappedX = position.x,
        unsnappedY = position.y;

  final int id;
  double x;
  double y;
  double unsnappedX;
  double unsnappedY;
  double voltage = 0;

  CckVec get pos => CckVec(x, y);
  CckVec get unsnapped => CckVec(unsnappedX, unsnappedY);

  String get nodeId => '$id';
}