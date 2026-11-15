import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';

/// Renders an icon from the approved set, tinted like a Material [Icon].
///
/// Icons are never auto-mirrored: `docs/ARABIC_LOCALIZATION.md` §2 assigns
/// explicit directional icons for RTL (`arrowRight` = back, `chevronLeft` =
/// forward).
class TesskraIcon extends StatelessWidget {
  const TesskraIcon(
    this.icon, {
    super.key,
    this.size = TesskraSizes.icon,
    this.color,
    this.semanticLabel,
  });

  final TesskraIcons icon;
  final double size;

  /// Defaults to the ambient [IconTheme] colour.
  final Color? color;

  /// Null marks the icon as decorative and hides it from screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      icon.assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
