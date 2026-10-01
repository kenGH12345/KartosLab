/// Balancing Act asset paths — original PhET images only.
abstract final class BaAssets {
  static const String _root = 'assets/simulations/balancing_act/images';
  static const String _objects = '$_root/objects';
  static const String _usa = '$_root/usa';

  static const String fireExtinguisher = '$_objects/fireExtinguisher.svg';
  static const String trashCan = '$_objects/trashCan.svg';

  static const String usaBoyStanding = '$_usa/usaBoyStanding.svg';
  static const String usaGirlStanding = '$_usa/usaGirlStanding.svg';
  static const String usaManStanding = '$_usa/usaManStanding.svg';
  static const String usaWomanStanding = '$_usa/usaWomanStanding.svg';

  // Game chrome
  static const String gameIcon = '$_root/gameIcon.svg';
  static const String gameLevel1Icon = '$_root/gameLevel1Icon.svg';
  static const String gameLevel2Icon = '$_root/gameLevel2Icon.svg';
  static const String gameLevel3Icon = '$_root/gameLevel3Icon.svg';
  static const String gameLevel4Icon = '$_root/gameLevel4Icon.svg';
  static const String plankBalanced = '$_root/plankBalanced.svg';
  static const String plankTippedLeft = '$_root/plankTippedLeft.svg';
  static const String plankTippedRight = '$_root/plankTippedRight.svg';

  // Game object catalog
  static const String fireHydrant = '$_objects/fireHydrant.svg';
  static const String television = '$_objects/oldTelevision.svg';
  static const String woodCrate = '$_objects/woodCrateTall.svg';
  static const String flowerPot = '$_objects/flowerPot.svg';
  static const String blueBucket = '$_objects/blueBucket.svg';
  static const String yellowBucket = '$_objects/yellowBucket.svg';
  static const String metalBucket = '$_objects/metalBucket.svg';
  static const String pottedPlant = '$_objects/pottedPlant.svg';
  static const String tire = '$_objects/tire.svg';
  static const String rock1 = '$_objects/rock1.svg';
  static const String rock4 = '$_objects/rock4.svg';
  static const String rock6 = '$_objects/rock6.svg';
  static const String tinyRock = '$_objects/tinyRock.svg';
  static const String cinderBlock = '$_objects/cinderBlock.svg';
  static const String puppy = '$_objects/puppy.svg';
  static const String sodaBottle = '$_objects/sodaBottle.svg';
  static const String barrel = '$_objects/barrel.svg';

  static String mysteryObject(int id) {
    final n = (id + 1).toString().padLeft(2, '0');
    return '$_objects/mysteryObject$n.svg';
  }

  static const List<String> gameLevelIcons = [
    gameLevel1Icon,
    gameLevel2Icon,
    gameLevel3Icon,
    gameLevel4Icon,
  ];
}
