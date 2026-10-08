import 'package:flutter/material.dart';

import 'intro_screen.dart';
import 'more_tools_screen.dart';
import 'prisms_screen.dart';
import 'package:kratos/bending_light/bl_strings.dart';

/// Simple hub to open each Bending Light screen without Home.
class BendingLightHub extends StatelessWidget {
  const BendingLightHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(BlStrings.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const IntroScreen()),
                ),
                child: const Text(BlStrings.intro),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PrismsScreen()),
                ),
                child: const Text(BlStrings.prisms),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MoreToolsScreen(),
                  ),
                ),
                child: const Text(BlStrings.moreTools),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
