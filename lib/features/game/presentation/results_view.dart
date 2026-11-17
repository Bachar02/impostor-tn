import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/game_components.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/features/game/application/game_route.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-09 Results: the only public screen that shows the word, the roles
/// and the guess, after the game is over (PRD §8). Votes as counts per
/// ballot (D-22). Only "play again" is pinned (Q-30 (1)).
class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
    required this.session,
    required this.onPlayAgain,
    required this.onChangeSetup,
    required this.onHome,
    this.busy = false,
    this.error,
  });

  final GameSession session;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeSetup;
  final VoidCallback onHome;
  final bool busy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    final phase = session.phase as ResultPhase;
    final outcome = phase.outcome;
    final word = session.word;
    String nameOf(PlayerId id) => session.playerById(id).name;

    final (stampLabel, stampKind) = switch (outcome.winner) {
      Winner.impostor => (l10n.resultImpostorWins, WinnerStampKind.impostor),
      Winner.civilians => (l10n.resultCiviliansWin, WinnerStampKind.civilians),
      Winner.draw => (l10n.resultDraw, WinnerStampKind.draw),
    };
    final explanation = switch (outcome) {
      CivilianNominated() => l10n.resultCivilianOut,
      RunoffDraw() => l10n.resultDrawNote,
      ImpostorGuessed() => null,
    };

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(
        top: TesskraLayout.sectionGap,
        bottom: TesskraSpacing.s2,
      ),
      child: Text(
        text,
        style: TesskraTypography.titleM.copyWith(color: c.textPrimary),
      ),
    );

    Widget ballot(String title, Ballot ballot) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TesskraTypography.labelM.copyWith(color: c.textSecondary),
        ),
        for (final MapEntry(key: id, value: count) in tallyRows(ballot))
          VoteTallyRow(name: nameOf(id), count: count),
      ],
    );

    return ScreenFrame(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: TesskraLayout.sectionGap),
          Center(
            child: WinnerStamp(label: stampLabel, kind: stampKind),
          ),
          if (explanation != null) ...[
            const SizedBox(height: TesskraLayout.sectionGap),
            Text(
              explanation,
              textAlign: TextAlign.center,
              style: TesskraTypography.bodyL.copyWith(color: c.textPrimary),
            ),
          ],
          const SizedBox(height: TesskraLayout.sectionGap),
          SecretWordPlaque(
            caption: l10n.revealWordLabel,
            word: word.canonical,
            chip: l10n.revealCategory(word.category),
          ),
          if (outcome case ImpostorGuessed(
            :final rawGuess,
            :final correct,
          )) ...[
            const SizedBox(height: TesskraLayout.sectionGap),
            Container(
              padding: const EdgeInsets.all(TesskraLayout.cardPadding),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(TesskraRadii.md),
                border: Border.all(
                  color: c.border,
                  width: TesskraBorders.standard,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resultGuessLabel,
                    style: TesskraTypography.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  Text(
                    directionIsolate(FinalGuessMatching.displayForm(rawGuess)),
                    style: TesskraTypography.titleM.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: TesskraSpacing.s2),
                  Row(
                    children: [
                      TesskraIcon(
                        correct ? TesskraIcons.check : TesskraIcons.x,
                        color: correct ? c.success : c.errorText,
                      ),
                      const SizedBox(width: TesskraSpacing.s2),
                      Text(
                        correct
                            ? l10n.resultGuessCorrect
                            : l10n.resultGuessWrong,
                        style: TesskraTypography.labelM.copyWith(
                          color: correct ? c.success : c.errorText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          heading(l10n.playersTitle),
          for (final (index, player) in session.players.indexed) ...[
            RoleRevealRow(
              position: index + 1,
              name: player.name,
              isImpostor: player.id == session.impostor,
              roleLabel: player.id == session.impostor
                  ? l10n.roleImpostor
                  : l10n.roleCivilian,
            ),
            const SizedBox(height: TesskraLayout.itemGap),
          ],
          heading(l10n.resultVotesTitle),
          for (final b in phase.ballots)
            ballot(
              b.kind == BallotKind.first
                  ? l10n.resultFirstBallot
                  : l10n.voteRunoffTitle,
              b,
            ),
          const SizedBox(height: TesskraLayout.sectionGap),
          TesskraButton(
            label: l10n.actionChangeSetup,
            variant: TesskraButtonVariant.secondary,
            onPressed: busy ? null : onChangeSetup,
          ),
          const SizedBox(height: TesskraLayout.itemGap),
          TesskraButton(
            label: l10n.actionHome,
            variant: TesskraButtonVariant.text,
            onPressed: busy ? null : onHome,
          ),
        ],
      ),
      actions: [
        if (error != null)
          TesskraBanner(message: error!, kind: TesskraBannerKind.error),
        TesskraButton(
          label: l10n.actionPlayAgain,
          variant: TesskraButtonVariant.accent,
          icon: TesskraIcons.rotateCcw,
          loading: busy,
          onPressed: onPlayAgain,
        ),
      ],
    );
  }
}
