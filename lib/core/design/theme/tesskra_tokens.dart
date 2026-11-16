import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_colors.dart';

/// Which of the two Tesskra grounds a theme draws on.
enum TesskraSurface {
  /// Public screens the whole table may see.
  paper,

  /// Screens one player sees alone (`PrivateScope`).
  carbon,
}

/// Theme extension carrying the Tesskra tokens that have no Material slot.
///
/// Read it with `TesskraTokens.of(context)`.
@immutable
final class TesskraTokens extends ThemeExtension<TesskraTokens> {
  const TesskraTokens({
    required this.surface,
    required this.colors,
    required this.numericL,
    required this.numericM,
  });

  final TesskraSurface surface;
  final TesskraColors colors;
  final TextStyle numericL;
  final TextStyle numericM;

  static TesskraTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<TesskraTokens>();
    if (tokens == null) {
      throw StateError('TesskraTokens is missing from the active theme.');
    }
    return tokens;
  }

  bool get isCarbon => surface == TesskraSurface.carbon;

  @override
  TesskraTokens copyWith({
    TesskraSurface? surface,
    TesskraColors? colors,
    TextStyle? numericL,
    TextStyle? numericM,
  }) {
    return TesskraTokens(
      surface: surface ?? this.surface,
      colors: colors ?? this.colors,
      numericL: numericL ?? this.numericL,
      numericM: numericM ?? this.numericM,
    );
  }

  /// The paper ↔ carbon change is a designed sheet transition
  /// (`carbonIn` / `carbonOut`), never a colour cross-fade, so tokens snap.
  @override
  TesskraTokens lerp(TesskraTokens? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}
