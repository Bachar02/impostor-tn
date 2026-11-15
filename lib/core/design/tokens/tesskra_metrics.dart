/// Spacing, layout, sizes, borders and radii in logical pixels.
/// Mirrors `docs/design/tokens/spacing.json` and `radii.json`.
library;

/// 4-pt spacing scale (`spacing.json → scale`). The suffix is the scale key.
abstract final class TesskraSpacing {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// `spacing.json → layout`.
abstract final class TesskraLayout {
  static const double screenMarginH = 24;
  static const double screenMarginHCompact = 16;
  static const double compactBreakpointWidth = 360;
  static const double screenPaddingTop = 16;
  static const double screenPaddingBottom = 24;
  static const double sectionGap = 24;
  static const double itemGap = 12;
  static const double cardPadding = 16;
  static const double cardPaddingLarge = 20;
  static const double ticketPadding = 20;
  static const double dialogPadding = 24;
  static const double maxContentWidth = 480;

  /// Horizontal screen margin for a given available width.
  static double screenMarginFor(double width) =>
      width < compactBreakpointWidth ? screenMarginHCompact : screenMarginH;
}

/// `spacing.json → sizes`.
abstract final class TesskraSizes {
  static const double touchTargetMin = 48;
  static const double buttonPrimaryHeight = 60;
  static const double buttonSecondaryHeight = 52;
  static const double buttonCompactHeight = 44;
  static const double iconButton = 48;
  static const double icon = 24;
  static const double iconSmall = 20;
  static const double inputHeight = 56;
  static const double playerRowHeight = 64;
  static const double voteOptionHeight = 64;
  static const double appBarHeight = 56;
  static const double badge = 40;
  static const double stampSmall = 56;
  static const double stampLarge = 96;
  static const double ticketNotchDiameter = 24;
}

/// `spacing.json → borders`.
abstract final class TesskraBorders {
  static const double hairline = 1.5;
  static const double standard = 2.5;
  static const double strong = 3.5;
  static const double dashLength = 8;
  static const double dashGap = 6;
}

/// `radii.json`.
abstract final class TesskraRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
