import 'package:flutter/animation.dart';

/// `docs/design/tokens/animations.json → durations`.
///
/// When `MediaQuery.disableAnimations` is on, components must use the
/// `reducedMotion` values documented per interaction in the token file.
abstract final class TesskraDurations {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
  static const reveal = Duration(milliseconds: 420);
  static const themeShift = Duration(milliseconds: 520);
  static const stagger = Duration(milliseconds: 40);
}

/// `docs/design/tokens/animations.json → curves`.
abstract final class TesskraCurves {
  static const standard = Cubic(0.2, 0, 0, 1);
  static const enter = Cubic(0, 0, 0, 1);
  static const exit = Cubic(0.3, 0, 1, 1);
  static const stamp = Cubic(0.34, 1.56, 0.64, 1);
  static const linear = Cubic(0, 0, 1, 1);
}
