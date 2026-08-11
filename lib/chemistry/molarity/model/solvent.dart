import 'package:flutter/material.dart';

/// 溶剂不可变数据（对齐蓝本 `Solvent.Water`）。
@immutable
class Solvent {
  const Solvent({this.formula = 'H\u2082O', this.color = const Color(0xFFE0FFFF)});

  final String formula;
  final Color color;
}
