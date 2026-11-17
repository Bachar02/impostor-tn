import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/fitted_display_text.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/design/widgets/ticket_perforation.dart';
import 'package:impostor_tn/core/text/bidi.dart';

/// What the ticket shows. The two variants are the only states; neither
/// knows about roles, so a Civilian and an Impostor ticket are built from
/// the same fields and the same widgets (PRD §5, D-27).
sealed class RoleTicketContent {
  const RoleTicketContent({required this.label, required this.name});

  /// Small label above the name on the top row ("دور").
  final String label;

  /// The player's name. Stays on the top row after the reveal (D-27).
  final String name;

  @override
  String toString() => 'RoleTicketContent(<redacted>)';
}

/// Before the deliberate reveal. Has no field that could hold a secret.
final class SealedTicket extends RoleTicketContent {
  const SealedTicket({
    required super.label,
    required super.name,
    required this.sealedText,
  });

  /// "role hidden".
  final String sealedText;
}

/// After the reveal. Civilian: caption "civilian · secret word", the word,
/// chip "category: X". Impostor: caption "impostor · category only", the
/// category, chip "you don't know the word". Same fields either way.
final class RevealedTicket extends RoleTicketContent {
  const RevealedTicket({
    required super.label,
    required super.name,
    required this.caption,
    required this.bigText,
    required this.chip,
  });

  final String caption;
  final String bigText;
  final String chip;
}

/// The role ticket (DESIGN_SYSTEM §5, PRV-02) with the parity layout of
/// D-27 (renders `prv02_proposed_*`):
///
/// 1. The top row never changes on reveal: label and player name; only the
///    stamp icon changes from lock to person. The role name is in the
///    caption of the bottom block.
/// 2. The big text reserves the full `displayXL` line box whatever size it
///    is fitted to, so both roles give the same ticket height at every text
///    scale.
/// 3. The category gets two lines on both tickets (D-39): the big text
///    (the Impostor's category) reserves two lines at its 40 floor as well,
///    and the chip (the Civilian's "category: X") reserves two lines. A
///    category that needs a third line in either place breaks parity.
///
/// Secret text is plain, non-selectable text and announces nothing by
/// itself (Q-28 default).
class RoleTicket extends StatelessWidget {
  const RoleTicket({
    super.key,
    required this.content,
    this.sealLift,
    this.secretIn,
  });

  final RoleTicketContent content;

  /// `ticketReveal`, sealed content only: 0 → 1 lifts the seal by 24 and
  /// fades it out.
  final Animation<double>? sealLift;

  /// `ticketReveal`, revealed content only: the secret's opacity. The owner
  /// builds [RevealedTicket] only once the seal is gone, so no frame shows
  /// the seal and the secret together.
  final Animation<double>? secretIn;

  /// Drawn at 52 as in the approved renders (Q-23 (7) draft resolution;
  /// `sizes.stampSmall` is 56 and unused).
  static const double stampSize = 52;

  /// Bottom block minimum height (DESIGN_SYSTEM §5 "Role ticket").
  static const double bottomMinHeight = 206;

  /// Lines reserved for the category on both tickets (D-39).
  static const int categoryLines = 2;

  /// The stamp is rotated 6° (DESIGN_SYSTEM §5).
  static const double _stampTurn = 6 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final ink = c.onTicket!;
    final ticket = c.ticket!;
    final content = this.content;

    final topRow = Padding(
      padding: const EdgeInsets.all(TesskraLayout.ticketPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.label,
                  style: TesskraTypography.caption.copyWith(color: ink),
                ),
                Text(
                  directionIsolate(content.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TesskraTypography.titleL.copyWith(color: ink),
                ),
              ],
            ),
          ),
          const SizedBox(width: TesskraSpacing.s3),
          Transform.rotate(
            angle: _stampTurn,
            child: Container(
              width: stampSize,
              height: stampSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TesskraRadii.sm),
                border: Border.all(color: ink, width: TesskraBorders.strong),
              ),
              alignment: Alignment.center,
              child: TesskraIcon(switch (content) {
                SealedTicket() => TesskraIcons.lock,
                RevealedTicket() => TesskraIcons.user,
              }, color: ink),
            ),
          ),
        ],
      ),
    );

    final bottom = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: bottomMinHeight),
      child: Padding(
        padding: const EdgeInsets.all(TesskraLayout.ticketPadding),
        child: Center(
          child: switch (content) {
            SealedTicket(:final sealedText) => _Seal(
              lift: sealLift,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TesskraIcon(TesskraIcons.eyeOff, color: ink),
                  const SizedBox(height: TesskraSpacing.s2),
                  Text(
                    sealedText,
                    textAlign: TextAlign.center,
                    style: TesskraTypography.labelL.copyWith(color: ink),
                  ),
                ],
              ),
            ),
            RevealedTicket(:final caption, :final bigText, :final chip) =>
              FadeTransition(
                opacity: secretIn ?? kAlwaysCompleteAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: TesskraTypography.caption.copyWith(color: ink),
                    ),
                    FittedDisplayText(
                      bigText,
                      style: TesskraTypography.displayXL.copyWith(color: ink),
                      minFontSize: TesskraTypography.displayXLMinFontSize,
                      reserveHeight: true,
                      floorLinesReserved: categoryLines,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: _Chip.heightFor(
                          categoryLines,
                          MediaQuery.textScalerOf(context),
                        ),
                      ),
                      child: Center(
                        child: _Chip(text: chip, color: ink),
                      ),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ticket,
        borderRadius: BorderRadius.circular(TesskraRadii.lg),
        boxShadow: const [TesskraShadows.privateTicket],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topRow,
          TicketPerforation(lineColor: ink, notchColor: c.background),
          bottom,
        ],
      ),
    );
  }
}

/// The sealed content, lifting off during `ticketReveal`.
class _Seal extends StatelessWidget {
  const _Seal({required this.lift, required this.child});

  final Animation<double>? lift;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lift = this.lift;
    if (lift == null) return child;
    return AnimatedBuilder(
      animation: lift,
      builder: (context, child) => Opacity(
        opacity: 1 - lift.value,
        child: Transform.translate(
          offset: Offset(0, -TesskraMotion.ticketSealLift * lift.value),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  static const _paddingV = TesskraSpacing.s1;
  static const _style = TesskraTypography.labelM;

  /// Outer height of a chip whose text runs to [lines] lines. Laid-out
  /// lines are rounded to whole pixels, so each line is rounded up here.
  static double heightFor(int lines, TextScaler scaler) =>
      2 * (_paddingV + TesskraBorders.standard) +
      lines * (scaler.scale(_style.fontSize!) * _style.height!).ceilToDouble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s4,
        vertical: _paddingV,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TesskraRadii.pill),
        border: Border.all(color: color, width: TesskraBorders.standard),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        // labelM (16) where the reference uses 15 (Q-23 (1) draft).
        style: _style.copyWith(color: color),
      ),
    );
  }
}
