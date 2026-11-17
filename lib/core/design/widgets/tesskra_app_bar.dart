import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';

/// App bar of paper screens (SCREEN_SPECIFICATIONS §1.2): height 56, an
/// optional start button (back), the title, an optional end element.
class TesskraAppBar extends StatelessWidget {
  const TesskraAppBar({super.key, this.title, this.leading, this.trailing});

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  /// "titleL at 22 as drawn in the reference" (§1.2). Not a token.
  static const double titleSize = 22;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return SizedBox(
      height: TesskraSizes.appBarHeight,
      child: Row(
        children: [
          ?leading,
          if (leading != null) const SizedBox(width: TesskraSpacing.s2),
          Expanded(
            child: title == null
                ? const SizedBox()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TesskraTypography.titleL.copyWith(
                        fontSize: titleSize,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
