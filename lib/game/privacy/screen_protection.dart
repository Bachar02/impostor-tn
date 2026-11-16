/// Blocks screenshots and app-switcher previews while a game runs (PRD §12,
/// D-18: the whole game, from start until it ends or is left). Implemented
/// in `lib/data/platform`.
abstract interface class ScreenProtection {
  /// True when the platform confirmed the change. A caller that needs
  /// protection must not show private content after a false (ADR-0006).
  Future<bool> setProtected({required bool on});
}
