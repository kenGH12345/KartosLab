import 'package:kratos/energy_skate_park/model/skater_image_set.dart';

/// View-only visibility + presentation flags (not physics state).
class EspViewProperties {
  bool pieChartVisible = false;
  bool barGraphVisible = true;
  bool speedVisible = false;
  bool gridVisible = false;
  bool referenceHeightVisible = false;

  /// SkaterNode.selectedSkaterProperty — appearance only, independent of mass.
  int selectedSkaterIndex = SkaterImageSet.defaultIndex;

  void reset({bool barGraphDefault = true}) {
    pieChartVisible = false;
    barGraphVisible = barGraphDefault;
    speedVisible = false;
    gridVisible = false;
    referenceHeightVisible = false;
    // PhET: selectedSkater persists across model reset (SkaterNode property).
  }
}
