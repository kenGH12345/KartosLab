import 'package:flutter/material.dart';

import '../caf_colors.dart';
import '../caf_strings.dart';
import '../model/charges_and_fields_model.dart';
import 'charges_and_fields_screen.dart';

/// KARTOSLAB Home entry for Charges and Fields（电学与电路）.
class ChargesAndFieldsHome extends StatefulWidget {
  const ChargesAndFieldsHome({super.key});

  static const String title = CafStrings.title;
  static const String subtitle = CafStrings.subtitle;
  static const Color accentColor = Color(0xFFF79722);

  @override
  State<ChargesAndFieldsHome> createState() => ChargesAndFieldsHomeState();
}

class ChargesAndFieldsHomeState extends State<ChargesAndFieldsHome> {
  late ChargesAndFieldsModel model;

  @override
  void initState() {
    super.initState();
    model = ChargesAndFieldsModel();
  }

  void reinitializeForTest() {
    model = ChargesAndFieldsModel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CafColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: const Text(CafStrings.title),
        elevation: 0,
      ),
      body: ChargesAndFieldsScreen(model: model),
    );
  }
}
