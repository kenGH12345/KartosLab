import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/assets/esp_asset_loader.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';
import 'package:kratos/energy_skate_park/widgets/skater_image_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EspAssetLoader', () {
    test('loads core runtime bundle (scenery + usa skaters)', () async {
      await EspAssetLoader.loadCoreRuntime();
    });

    test('loads all usa skater headshots and body poses', () async {
      await EspAssetLoader.loadUsaSkaters();
      for (var i = 0; i < SkaterImageSet.count; i++) {
        final set = SkaterImageSet.at(i);
        final pair = await SkaterImageCache.instance.loadSet(i);
        expect(pair.left, isNotNull, reason: set.leftAsset);
        expect(pair.right, isNotNull, reason: set.rightAsset);
        final head = await SkaterImageCache.instance.loadHeadshot(i);
        expect(head, isNotNull, reason: set.headshotAsset);
      }
    });

    test('screen tab icons exist in bundle', () async {
      await EspAssetLoader.load(EspAssets.introScreenIcon);
      await EspAssetLoader.load(EspAssets.measureScreenIcon);
      await EspAssetLoader.load(EspAssets.graphsScreenIcon);
      await EspAssetLoader.load(EspAssets.playgroundScreenIcon);
    });

    test('cement texture and mountains scenery assets exist', () async {
      await EspAssetLoader.load(EspAssets.mountains);
      await EspAssetLoader.load(EspAssets.cementTextureDark);
    });

    test('scenery-phet measuring tape and eraser assets exist', () async {
      await EspAssetLoader.loadAll(EspAssets.sceneryPhetBundle);
    });
  });
}
