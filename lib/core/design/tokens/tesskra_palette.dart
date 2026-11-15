import 'dart:ui';

/// Raw Tesskra palette. Mirrors `docs/design/tokens/colors.json → palette`.
///
/// Widgets should read semantic colours from `TesskraColors` (via the theme),
/// not from this class. Kept in sync with the JSON by
/// `test/core/design/token_sync_test.dart`.
abstract final class TesskraPalette {
  static const paper = Color(0xFFF3EBDD);
  static const paperRaised = Color(0xFFFFFDF7);
  static const paperSunken = Color(0xFFEADFCB);
  static const paperEdge = Color(0xFFC9BEA8);
  static const ink = Color(0xFF1B2A4A);
  static const inkMuted = Color(0xFF4F5A73);
  static const inkDisabled = Color(0xFF8A8FA0);
  static const stamp = Color(0xFFC92D22);
  static const stampPressed = Color(0xFFA9241B);
  static const stampText = Color(0xFFB3261C);
  static const mustard = Color(0xFFE9A820);
  static const mustardPressed = Color(0xFFCF9212);
  static const mustardText = Color(0xFF7A5200);
  static const bottle = Color(0xFF1F6B4E);
  static const blueInk = Color(0xFF24508F);
  static const carbon = Color(0xFF141C30);
  static const carbonRaised = Color(0xFF1E2942);
  static const carbonOutline = Color(0xFF6B7798);
  static const carbonMuted = Color(0xFFB4BACB);
  static const coralLight = Color(0xFFFF8A7A);
  static const mintLight = Color(0xFF7FD1A8);
  static const shadowDeep = Color(0xFF0A0F1C);
}
