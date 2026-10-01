import 'single_spring_system.dart';

/// Intro screen. Two unrelated single-spring systems. `js/intro/model/IntroModel.ts`.
///
/// Not series and not parallel. Visibility of the second system is a view
/// concern; both models exist for the lifetime of the screen.
class IntroModel {
  IntroModel()
      : system1 = SingleSpringSystem.intro(),
        system2 = SingleSpringSystem.intro();

  final SingleSpringSystem system1;
  final SingleSpringSystem system2;

  void reset() {
    system1.reset();
    system2.reset();
  }
}
