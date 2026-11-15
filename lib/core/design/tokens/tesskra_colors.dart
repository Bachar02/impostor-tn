import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_palette.dart';

/// Semantic colours for one Tesskra theme. Mirrors
/// `docs/design/tokens/colors.json → public / private`.
///
/// A field is nullable exactly when the token file does not define that role
/// for the theme (for example `accent` does not exist on private screens).
/// Do not fill those gaps in code; raise them as a design question instead.
@immutable
final class TesskraColors {
  const TesskraColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.success,
    required this.error,
    required this.focusRing,
    required this.shadow,
    required this.scrim,
    this.surfaceSunken,
    this.borderSubtle,
    this.borderStrong,
    this.accent,
    this.accentPressed,
    this.onAccent,
    this.onSuccess,
    this.warning,
    this.warningText,
    this.errorText,
    this.ticket,
    this.onTicket,
  });

  final Color background;
  final Color surface;
  final Color? surfaceSunken;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
  final Color? borderSubtle;
  final Color? borderStrong;
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color? accent;
  final Color? accentPressed;
  final Color? onAccent;
  final Color success;
  final Color? onSuccess;
  final Color? warning;
  final Color? warningText;
  final Color error;
  final Color? errorText;
  final Color focusRing;
  final Color shadow;

  /// Scrim colour with the token alpha already applied.
  final Color scrim;
  final Color? ticket;
  final Color? onTicket;

  /// Paper theme: screens the whole table may see.
  static const public = TesskraColors(
    background: TesskraPalette.paper,
    surface: TesskraPalette.paperRaised,
    surfaceSunken: TesskraPalette.paperSunken,
    textPrimary: TesskraPalette.ink,
    textSecondary: TesskraPalette.inkMuted,
    textDisabled: TesskraPalette.inkDisabled,
    border: TesskraPalette.ink,
    borderSubtle: TesskraPalette.paperEdge,
    primary: TesskraPalette.stamp,
    primaryPressed: TesskraPalette.stampPressed,
    onPrimary: TesskraPalette.paperRaised,
    accent: TesskraPalette.mustard,
    accentPressed: TesskraPalette.mustardPressed,
    onAccent: TesskraPalette.ink,
    success: TesskraPalette.bottle,
    onSuccess: TesskraPalette.paperRaised,
    warning: TesskraPalette.mustard,
    warningText: TesskraPalette.mustardText,
    error: TesskraPalette.stamp,
    errorText: TesskraPalette.stampText,
    focusRing: TesskraPalette.blueInk,
    shadow: TesskraPalette.ink,
    scrim: Color(0x99141C30), // carbon at alpha 0.6
  );

  /// Carbon theme: screens one player sees alone.
  static const private = TesskraColors(
    background: TesskraPalette.carbon,
    surface: TesskraPalette.carbonRaised,
    ticket: TesskraPalette.paper,
    onTicket: TesskraPalette.ink,
    textPrimary: TesskraPalette.paper,
    textSecondary: TesskraPalette.carbonMuted,
    textDisabled: TesskraPalette.carbonOutline,
    border: TesskraPalette.carbonOutline,
    borderStrong: TesskraPalette.paper,
    primary: TesskraPalette.mustard,
    primaryPressed: TesskraPalette.mustardPressed,
    onPrimary: TesskraPalette.carbon,
    success: TesskraPalette.mintLight,
    error: TesskraPalette.coralLight,
    focusRing: TesskraPalette.paper,
    shadow: TesskraPalette.shadowDeep,
    scrim: Color(0xB30A0F1C), // shadowDeep at alpha 0.7
  );
}

/// Role colours. Mirrors `colors.json → role`.
///
/// PUBLIC RESULT SCREENS ONLY. Never use on private (carbon) screens: both
/// roles must look identical at a glance there. Always pair with icon + label.
abstract final class TesskraRoleColors {
  static const civilian = TesskraPalette.blueInk;
  static const onCivilian = TesskraPalette.paperRaised;
  static const impostor = TesskraPalette.stamp;
  static const onImpostor = TesskraPalette.paperRaised;
}
