// Copyright 2024-2026, University of Colorado Boulder
/// CoinsScreen 是 Coins 屏幕入口
///
/// 对应官方：js/coins/CoinsScreen.ts
library;


import 'package:flutter/material.dart';
import 'model/coins_model.dart';
import 'view/coins_screen_view.dart';

class CoinsScreen extends StatefulWidget {
  const CoinsScreen({super.key});

  @override
  State<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  late final CoinsModel _model;

  @override
  void initState() {
    super.initState();
    _model = CoinsModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CoinsScreenView(model: _model);
  }
}
