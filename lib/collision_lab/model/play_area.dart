import '../collision_lab_constants.dart';
import 'ball.dart';
import 'cl_vec.dart';

enum PlayAreaDimension { one, two }

/// Play-area box — `js/common/model/PlayArea.js` + screen subclasses.
class PlayArea {
  PlayArea({
    required this.dimension,
    required this.bounds,
    this.reflectingBorder = true,
    this.elasticityPercent = 100,
    this.elasticityEnabledMin = 0,
    this.elasticityLocked = false,
    this.gridVisible = false,
    this.gridCheckboxEnabled = true,
    this.inelasticCollisionType = InelasticCollisionType.stick,
  })  : _initialReflectingBorder = reflectingBorder,
        _initialElasticityPercent = elasticityPercent,
        _initialGridVisible = gridVisible,
        _initialInelasticCollisionType = inelasticCollisionType;

  factory PlayArea.intro() => PlayArea(
        dimension: PlayAreaDimension.one,
        bounds: ClBounds(
          minX: -2,
          minY: -CollisionLabConstants.playArea1dHeight / 2,
          maxX: 2,
          maxY: CollisionLabConstants.playArea1dHeight / 2,
        ),
        reflectingBorder: false,
        gridVisible: true,
        gridCheckboxEnabled: false,
      );

  factory PlayArea.explore1d() => PlayArea(
        dimension: PlayAreaDimension.one,
        bounds: ClBounds(
          minX: -2,
          minY: -CollisionLabConstants.playArea1dHeight / 2,
          maxX: 2,
          maxY: CollisionLabConstants.playArea1dHeight / 2,
        ),
        reflectingBorder: true,
        gridVisible: true,
        gridCheckboxEnabled: false,
      );

  factory PlayArea.explore2d() => PlayArea(
        dimension: PlayAreaDimension.two,
        bounds: const ClBounds(minX: -2, minY: -1, maxX: 2, maxY: 1),
        reflectingBorder: true,
        elasticityPercent: 100,
        elasticityEnabledMin: 5, // Explore2D forbids 0%
        gridVisible: false,
        gridCheckboxEnabled: true,
      );

  factory PlayArea.inelastic() => PlayArea(
        dimension: PlayAreaDimension.two,
        bounds: const ClBounds(minX: -2, minY: -1, maxX: 2, maxY: 1),
        reflectingBorder: true,
        elasticityPercent: 0,
        elasticityLocked: true,
        gridVisible: false,
        gridCheckboxEnabled: true,
        inelasticCollisionType: InelasticCollisionType.stick,
      );

  final PlayAreaDimension dimension;
  final ClBounds bounds;

  final bool _initialReflectingBorder;
  final double _initialElasticityPercent;
  final bool _initialGridVisible;
  final InelasticCollisionType _initialInelasticCollisionType;

  bool reflectingBorder;
  double elasticityPercent;
  final double elasticityEnabledMin;
  final bool elasticityLocked;
  bool gridVisible;
  final bool gridCheckboxEnabled;

  /// Stick vs Slip — only meaningful for Inelastic screen.
  InelasticCollisionType inelasticCollisionType;

  double get left => bounds.left;
  double get right => bounds.right;
  double get top => bounds.top;
  double get bottom => bounds.bottom;

  double getElasticity() => elasticityPercent / 100.0;

  void setElasticityPercent(double percent) {
    if (elasticityLocked) return;
    final stepped = (percent / CollisionLabConstants.elasticityPercentInterval)
            .round() *
        CollisionLabConstants.elasticityPercentInterval;
    elasticityPercent = stepped.clamp(
      elasticityEnabledMin,
      CollisionLabConstants.elasticityPercentMax,
    );
  }

  bool _touching(double edge, double playAreaEdge) =>
      (edge - playAreaEdge).abs() < CollisionLabConstants.zeroThreshold;

  bool isBallTouchingLeft(Ball ball) => _touching(ball.left, left);
  bool isBallTouchingRight(Ball ball) => _touching(ball.right, right);
  bool isBallTouchingBottom(Ball ball) => _touching(ball.bottom, bottom);
  bool isBallTouchingTop(Ball ball) => _touching(ball.top, top);

  bool isBallTouchingSide(Ball ball) =>
      isBallTouchingTop(ball) ||
      isBallTouchingBottom(ball) ||
      isBallTouchingLeft(ball) ||
      isBallTouchingRight(ball);

  bool fullyContainsBall(Ball ball) =>
      ball.left >= left &&
      ball.right <= right &&
      ball.bottom >= bottom &&
      ball.top <= top;

  bool containsAnyPartOfBall(ClVec position, double radius) {
    return position.x + radius > left &&
        position.x - radius < right &&
        position.y + radius > bottom &&
        position.y - radius < top;
  }

  bool containsAnyPartOf(Ball ball) =>
      containsAnyPartOfBall(ball.position, ball.radius);

  void reset() {
    reflectingBorder = _initialReflectingBorder;
    elasticityPercent = _initialElasticityPercent;
    gridVisible = _initialGridVisible;
    inelasticCollisionType = _initialInelasticCollisionType;
  }
}

enum InelasticCollisionType { stick, slip }
