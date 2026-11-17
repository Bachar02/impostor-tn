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

/// `docs/design/tokens/animations.json → named`: the values of the named
/// interactions the app plays. Numbers that the token file gives only in an
/// `effect` sentence are mirrored here and checked against that sentence by
/// `token_sync_test.dart`.
abstract final class TesskraMotion {
  /// carbonIn / carbonOut (INTERACTIONS_AND_ANIMATIONS §4).
  static const carbonShift = TesskraDurations.themeShift;

  /// carbonIn: private content fades in over the last 140 ms.
  static const carbonContentIn = Duration(milliseconds: 140);

  /// carbonIn / carbonOut with reduced motion: a 140 ms cross-fade.
  static const carbonReduced = Duration(milliseconds: 140);

  /// ticketReveal: the seal lifts by 24 and fades; the secret content fades
  /// in only during the last 120 ms, after the seal is gone.
  static const ticketReveal = TesskraDurations.reveal;
  static const ticketSecretIn = Duration(milliseconds: 120);
  static const ticketSealLift = 24.0;

  /// ticketReveal with reduced motion: a 120 ms fade.
  static const ticketReduced = Duration(milliseconds: 120);

  /// winnerReveal: the stamp slams in, then the headline rises.
  static const winnerReveal = Duration(milliseconds: 600);

  /// winnerReveal with reduced motion: a 140 ms fade.
  static const winnerReduced = Duration(milliseconds: 140);

  /// stampIn: scale 1.6 to 1; used by the winner stamp's slam.
  static const stampScale = 1.6;

  /// listItemIn: fade and 8 rise; listItemOut: fade and collapse.
  static const listItemIn = TesskraDurations.base;
  static const listItemOut = TesskraDurations.fast;
  static const listItemRise = 8.0;
}
