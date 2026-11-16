import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/text/bidi.dart';

/// "{current} / {total}" in `numericM`, as an isolated left-to-right run
/// (SCREEN_SPECIFICATIONS §1.3). On carbon the border is `borderStrong`.
class CountPill extends StatelessWidget {
  const CountPill({
    super.key,
    required this.current,
    required this.total,
    this.semanticLabel,
  });

  final int current;
  final int total;

  /// Spoken instead of the digits, if given.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    final border = tokens.isCarbon ? (c.borderStrong ?? c.border) : c.border;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Container(
        constraints: const BoxConstraints(minHeight: TesskraSpacing.s8),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: TesskraSpacing.s3,
          vertical: TesskraSpacing.s1,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TesskraRadii.pill),
          border: Border.all(color: border, width: TesskraBorders.standard),
        ),
        child: Text(
          ltrIsolate('$current / $total'),
          style: tokens.numericM,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
