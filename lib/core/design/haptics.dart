import 'dart:async';

import 'package:flutter/services.dart';

/// The haptic levels named in INTERACTIONS_AND_ANIMATIONS.md. Fire and
/// forget: a device without haptics simply does nothing. Identical for
/// Civilian and Impostor wherever both can see it (SCREEN_SPECIFICATIONS
/// §1.5).
abstract final class Haptics {
  static void light() => unawaited(HapticFeedback.lightImpact());
  static void medium() => unawaited(HapticFeedback.mediumImpact());
  static void heavy() => unawaited(HapticFeedback.heavyImpact());
  static void selection() => unawaited(HapticFeedback.selectionClick());

  /// Invalid field (SCREEN_SPECIFICATIONS §1.6 "error haptic").
  static void error() => unawaited(HapticFeedback.vibrate());
}
