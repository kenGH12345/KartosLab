import "dart:ui";
import "package:flutter_test/flutter_test.dart";
import "package:kratos/color_vision/model/photon.dart";
import "package:kratos/color_vision/model/filter.dart";
import "package:kratos/color_vision/model/spot_light.dart";
import "package:kratos/color_vision/model/color_vision_state.dart";
import "package:kratos/color_vision/model/single_bulb_state.dart";
import "package:kratos/color_vision/solver/color_model.dart";
import "package:kratos/color_vision/solver/photon_beam.dart";

void main() {
  group("Photon", () {
    test("default values", () {
      final p = Photon();
      expect(p.x, 0); expect(p.y, 0);
      expect(p.color, const Color(0xFFFFFFFF));
      expect(p.alive, false); expect(p.filtered, false);
    });
    test("reset", () {
      final p = Photon();
      p.reset(42.0, 73.0, const Color(0xFFFF0000));
      expect(p.x, 42.0); expect(p.y, 73.0);
      expect(p.color, const Color(0xFFFF0000));
      expect(p.alive, true); expect(p.filtered, false);
    });
    test("kill", () {
      final p = Photon()..reset(10, 10, const Color(0xFF00FF00));
      p.filtered = true; p.kill();
      expect(p.alive, false); expect(p.filtered, false);
    });
  });

  group("Filter", () {
    test("none", () { expect(const Filter(type: FilterType.none).passRates, (1.0, 1.0, 1.0)); });
    test("red",  () { expect(const Filter(type: FilterType.red).passRates,   (1.0, 0.0, 0.0)); });
    test("green",() { expect(const Filter(type: FilterType.green).passRates, (0.0, 1.0, 0.0)); });
    test("blue", () { expect(const Filter(type: FilterType.blue).passRates,  (0.0, 0.0, 1.0)); });
    test("custom 0.5/0.3/0.1", () { expect(const Filter(type: FilterType.custom, customR:0.5, customG:0.3, customB:0.1).passRates, (0.5,0.3,0.1)); });
    test("custom defaults to 1.0", () { expect(const Filter(type: FilterType.custom).passRates, (1.0,1.0,1.0)); });
    test("default Filter", () { expect(const Filter().passRates, (1.0,1.0,1.0)); });
  });

  group("SpotLight", () {
    test("constructor", () {
      const sl = SpotLight(x:100, y:200, color:Color(0xFFFF0000), intensity:75);
      expect(sl.x, 100); expect(sl.y, 200); expect(sl.intensity, 75);
    });
    test("default intensity", () { expect(const SpotLight(x:0, y:0, color:Color(0xFF0000FF)).intensity, 100); });
    test("copyWith", () {
      const sl = SpotLight(x:1, y:2, color:Color(0xFF00FF00), intensity:50);
      final s2 = sl.copyWith(x:10, intensity:80);
      expect(s2.x, 10); expect(s2.y, 2); expect(s2.intensity, 80);
      expect(sl.x, 1); expect(sl.intensity, 50);
    });
  });

  group("ColorModel.mixRGB", () {
    test("full red",   () { final c = ColorModel.mixRGB(100,0,0); expect(c.r*255, closeTo(255,1)); expect(c.g*255, closeTo(0,1)); });
    test("full green", () { final c = ColorModel.mixRGB(0,100,0); expect(c.g*255, closeTo(255,1)); });
    test("full blue",  () { final c = ColorModel.mixRGB(0,0,100); expect(c.b*255, closeTo(255,1)); });
    test("yellow",     () { final c = ColorModel.mixRGB(100,100,0); expect(c.r*255, closeTo(255,1)); expect(c.g*255, closeTo(255,1)); expect(c.b*255, closeTo(0,1)); });
    test("white",      () { final c = ColorModel.mixRGB(100,100,100); expect(c.r*255, closeTo(255,1)); });
    test("black",      () { final c = ColorModel.mixRGB(0,0,0); expect(c.r*255, closeTo(0,1)); });
    test("half",       () { final c = ColorModel.mixRGB(50,50,50); expect(c.r*255, closeTo(128,5)); });
    test("clamp >100", () { expect(ColorModel.mixRGB(150,0,0).r*255, closeTo(255,1)); });
    test("clamp <0",   () { expect(ColorModel.mixRGB(-10,0,0).r*255, closeTo(0,1)); });
  });

  group("ColorModel.applyFilter", () {
    const w = Color(0xFFFFFFFF);
    test("none on white",      () { expect(ColorModel.applyFilter(w, const Filter(type:FilterType.none)), w); });
    test("red on white",       () { final c = ColorModel.applyFilter(w, const Filter(type:FilterType.red)); expect(c!.r*255, closeTo(255,1)); expect(c.g*255, closeTo(0,1)); });
    test("red on green -> null",() { expect(ColorModel.applyFilter(const Color(0xFF00FF00), const Filter(type:FilterType.red)), isNull); });
    test("custom 50%",         () { final c = ColorModel.applyFilter(w, const Filter(type:FilterType.custom, customR:0.5, customG:0.5, customB:0.5)); expect(c!.r*255, closeTo(128,5)); });
  });

  group("ColorModel.colorName", () {
    test("red",     () { expect(ColorModel.colorName(const Color(0xFFFF0000)), "Red"); });
    test("green",   () { expect(ColorModel.colorName(const Color(0xFF00FF00)), "Green"); });
    test("blue",    () { expect(ColorModel.colorName(const Color(0xFF0000FF)), "Blue"); });
    test("yellow",  () { expect(ColorModel.colorName(const Color(0xFFFFFF00)), "Yellow"); });
    test("magenta", () { expect(ColorModel.colorName(const Color(0xFFFF00FF)), "Magenta"); });
    test("cyan",    () { expect(ColorModel.colorName(const Color(0xFF00FFFF)), "Cyan"); });
    test("white",   () { expect(ColorModel.colorName(const Color(0xFFFFFFFF)), "White"); });
    test("black",   () { expect(ColorModel.colorName(const Color(0xFF010101)), "Black"); });
    test("mixed",   () { expect(ColorModel.colorName(const Color(0xFF808080)), "Mixed"); });
  });

  group("ColorModel.colorMatches", () {
    test("red",         () { expect(ColorModel.colorMatches(const Color(0xFFFF0000), "red"), true); });
    test("green",       () { expect(ColorModel.colorMatches(const Color(0xFF00FF00), "green"), true); });
    test("blue",        () { expect(ColorModel.colorMatches(const Color(0xFF0000FF), "blue"), true); });
    test("yellow",      () { expect(ColorModel.colorMatches(const Color(0xFFFFFF00), "yellow"), true); });
    test("magenta",     () { expect(ColorModel.colorMatches(const Color(0xFFFF00FF), "magenta"), true); });
    test("cyan",        () { expect(ColorModel.colorMatches(const Color(0xFF00FFFF), "cyan"), true); });
    test("white",       () { expect(ColorModel.colorMatches(const Color(0xFFFFFFFF), "white"), true); });
    test("black",       () { expect(ColorModel.colorMatches(const Color(0xFF000000), "black"), true); });
    test("unknown",     () { expect(ColorModel.colorMatches(const Color(0xFF808080), "orange"), false); });
    test("tolerance 30",() { expect(ColorModel.colorMatches(const Color(0xFF101010), "black", tolerance:30), true); });
  });

  group("ColorVisionState", () {
    test("defaults", () { final s = ColorVisionState(beams:[]); expect(s.redIntensity,100); expect(s.greenIntensity,100); expect(s.blueIntensity,100); expect(s.personPosition,300); });
    test("mixedColor white",  () { expect(ColorVisionState(beams:[]).mixedColor, const Color(0xFFFFFFFF)); });
    test("mixedColor yellow", () { final c = ColorVisionState(beams:[], redIntensity:100, greenIntensity:100, blueIntensity:0).mixedColor; expect(c.r*255, closeTo(255,1)); expect(c.g*255, closeTo(255,1)); expect(c.b*255, closeTo(0,1)); });
    test("mixedColor gray",   () { final c = ColorVisionState(beams:[], redIntensity:50, greenIntensity:50, blueIntensity:50).mixedColor; expect(c.r*255, closeTo(128,5)); });
    test("update red",   () { final s = ColorVisionState(beams:[]); s.updateIntensity(0,30); expect(s.redIntensity,30); });
    test("update green", () { final s = ColorVisionState(beams:[]); s.updateIntensity(1,40); expect(s.greenIntensity,40); });
    test("update blue",  () { final s = ColorVisionState(beams:[]); s.updateIntensity(2,60); expect(s.blueIntensity,60); });
    test("update OOB",   () { final s = ColorVisionState(beams:[]); s.updateIntensity(99,50); expect(s.redIntensity,100); });
  });

  group("SingleBulbState", () {
    late PhotonBeam beam;
    setUp(() { beam = PhotonBeam(color: const Color(0xFFFFFFFF), originX: 0, originY: 50); });
    tearDown(() { beam.clear(); });
    test("defaults", () { final s = SingleBulbState(beam:beam); expect(s.bulbMode, BulbMode.white); expect(s.filter.type, FilterType.none); expect(s.filterX, 200); });
    test("bulbColor default green", () { final s = SingleBulbState(beam:beam); expect(s.bulbWavelength, 550); expect(s.bulbColor.g*255, greaterThan(150)); });
    test("setBulbMode mono", () { final s = SingleBulbState(beam:beam); s.setBulbMode(BulbMode.mono); expect(s.beam.color, s.bulbColor); });
    test("setBulbMode white resets", () { final s = SingleBulbState(beam:beam); s.setBulbMode(BulbMode.mono); s.setBulbMode(BulbMode.white); expect(s.beam.color, const Color(0xFFFFFFFF)); });
    test("setBulbWavelength mono", () { final s = SingleBulbState(beam:beam); s.setBulbMode(BulbMode.mono); s.setBulbWavelength(650); expect(s.bulbColor.r*255, greaterThan(150)); expect(s.beam.color, s.bulbColor); });
    test("setBulbWavelength white no change", () { final s = SingleBulbState(beam:beam); s.setBulbWavelength(450); expect(s.beam.color, const Color(0xFFFFFFFF)); });
    test("setFilter resets filtered flags", () { final s = SingleBulbState(beam:beam); beam.stepInTime(1.0); for(final p in beam.alive){p.filtered=true;} s.setFilter(const Filter(type:FilterType.red)); for(final p in beam.alive){expect(p.filtered, false);} });
    test("dispose clears beam", () { final s = SingleBulbState(beam:beam); beam.stepInTime(1.0); s.dispose(); expect(beam.alive, isEmpty); });
  });
}
