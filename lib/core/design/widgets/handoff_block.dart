import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/count_pill.dart';
import 'package:impostor_tn/core/design/widgets/fitted_display_text.dart';
import 'package:impostor_tn/core/text/bidi.dart';

/// The neutral handoff content (PRV-01, DESIGN_SYSTEM §5 "Handoff block"):
/// "pass the phone to", the name, and the position. Nothing else, so it is
/// identical for reveal, voting and the runoff. The "I am {name}" button
/// belongs to the screen's pinned action area.
class HandoffBlock extends StatelessWidget {
  const HandoffBlock({
    super.key,
    required this.passLabel,
    required this.name,
    this.position,
    this.total,
  }) : assert((position == null) == (total == null));

  final String passLabel;
  final String name;

  /// Omitted for the final guess (PRV-01 layout item 3).
  final int? position;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          passLabel,
          textAlign: TextAlign.center,
          style: TesskraTypography.bodyL.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: TesskraSpacing.s3),
        // Shrinks to fit, two lines at most (Q-23 (3) draft resolution).
        FittedDisplayText(
          directionIsolate(name),
          style: TesskraTypography.displayL.copyWith(color: c.textPrimary),
          minFontSize: TesskraTypography.displayLMinFontSize,
          maxLines: 2,
        ),
        if (position case final position?) ...[
          const SizedBox(height: TesskraSpacing.s4),
          Center(
            child: CountPill(current: position, total: total!),
          ),
        ],
      ],
    );
  }
}
