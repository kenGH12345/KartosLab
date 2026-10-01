/// Asset paths for John Travoltage — original PhET runtime PNGs / MP3s.
abstract final class JohnTravoltageAssets {
  static const String _imageRoot = 'assets/simulations/john_travoltage/images';
  static const String _soundRoot = 'assets/simulations/john_travoltage/sounds';

  static const String wallpaper = '$_imageRoot/wallpaper.png';
  static const String window = '$_imageRoot/window.png';
  static const String floor = '$_imageRoot/floor.png';
  static const String rug = '$_imageRoot/rug.png';
  static const String door = '$_imageRoot/door.png';
  static const String body = '$_imageRoot/body.png';
  static const String arm = '$_imageRoot/arm.png';
  static const String leg = '$_imageRoot/leg.png';

  static const String electricDischarge = '$_soundRoot/electricDischarge.mp3';
  static const String chargesInBody = '$_soundRoot/chargesInBody.mp3';
  static const String ouch = '$_soundRoot/ouch.mp3';
  static const String gazouch = '$_soundRoot/gazouch.mp3';
  static const String armPosition001 = '$_soundRoot/armPosition001.mp3';
  static const String armPosition002 = '$_soundRoot/armPosition002.mp3';
  static const String armPosition003 = '$_soundRoot/armPosition003.mp3';
  static const String armPosition004 = '$_soundRoot/armPosition004.mp3';
  static const String armPosition005 = '$_soundRoot/armPosition005.mp3';
  static const String armPosition006 = '$_soundRoot/armPosition006.mp3';

  static const List<String> armPositionSounds = [
    armPosition001,
    armPosition002,
    armPosition003,
    armPosition004,
    armPosition005,
    armPosition006,
  ];
}
