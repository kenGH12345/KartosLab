/// Asset path helpers for Forces and Motion: Basics.
class FambAssets {
  FambAssets._();

  static const root = 'assets/simulations/forces_and_motion_basics';
  static const images = '$root/images';
  static const pushPull = '$images/pushPullFigures';
  static const sounds = '$root/sounds';

  static const cart = '$images/cart.svg';
  static const rope = '$images/rope.png';
  static const grass = '$images/grass.png';
  static const skateboard = '$images/skateboard.svg';
  static const mountains = '$images/mountains.svg';
  static const cloud = '$images/cloud1.svg';
  static const brickTile = '$images/brickTile.png';
  static const icicle = '$images/icicle.png';
  static const fridge = '$images/fridge.svg';
  static const crate = '$images/crate.svg';
  static const trashCan = '$images/trashCan.svg';
  static const mystery = '$images/mysteryObject01.svg';
  static const waterBucket = '$images/waterBucket.svg';

  static const golfClap = '$sounds/golfClap.mp3';

  static String pusher(int index) {
    final i = index.clamp(0, 30);
    return '$pushPull/pusher_$i.png';
  }

  static const pusherStanding = '$pushPull/pusher_straight_on.png';
  static const pusherFallen = '$pushPull/pusher_fall_down.png';

  /// Puller PNG: color BLUE|RED|PURPLE|ORANGE, size '', '_lrg_', '_small_',
  /// pose 0=leaning, 3=standing.
  static String puller({
    required String color,
    required String size, // '' medium, 'lrg', 'small'
    required int pose, // 0 or 3
  }) {
    final sizePart = size.isEmpty ? '' : '${size}_';
    return '$pushPull/pull_figure_$sizePart${color}_$pose.png';
  }
}
