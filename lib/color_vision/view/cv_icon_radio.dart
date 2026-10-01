import 'package:flutter/material.dart';

/// PhET `RectangularRadioButtonGroup` style used by Color Vision.
///
/// Yellow border selected (1.3) / deselected (0.6), black base, [Image.asset] icons.
class CvIconRadioGroup<T> extends StatelessWidget {
  const CvIconRadioGroup({
    super.key,
    required this.values,
    required this.assetPaths,
    required this.groupValue,
    required this.onChanged,
    this.iconScale = 0.74,
    this.spacing = 13,
    this.xMargin = 2,
    this.yMargin = 2,
    this.orientation = Axis.horizontal,
  });

  final List<T> values;
  final List<String> assetPaths;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final double iconScale;
  final double spacing;
  final double xMargin;
  final double yMargin;
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    assert(values.length == assetPaths.length);
    final children = <Widget>[];
    for (var i = 0; i < values.length; i++) {
      if (i > 0) {
        children.add(SizedBox(
          width: orientation == Axis.horizontal ? spacing : 0,
          height: orientation == Axis.vertical ? spacing : 0,
        ));
      }
      children.add(CvIconRadioButton<T>(
        value: values[i],
        groupValue: groupValue,
        assetPath: assetPaths[i],
        onChanged: onChanged,
        iconScale: iconScale,
        xMargin: xMargin,
        yMargin: yMargin,
      ));
    }
    return orientation == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class CvIconRadioButton<T> extends StatelessWidget {
  const CvIconRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.assetPath,
    required this.onChanged,
    this.iconScale = 0.74,
    this.xMargin = 2,
    this.yMargin = 2,
  });

  final T value;
  final T groupValue;
  final String assetPath;
  final ValueChanged<T> onChanged;
  final double iconScale;
  final double xMargin;
  final double yMargin;

  bool get selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Opacity(
        opacity: selected ? 1.0 : 0.8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.yellow,
              width: selected ? 1.3 : 0.6,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Transform.scale(
            scale: iconScale,
            child: Image.asset(assetPath, filterQuality: FilterQuality.medium),
          ),
        ),
      ),
    );
  }
}
