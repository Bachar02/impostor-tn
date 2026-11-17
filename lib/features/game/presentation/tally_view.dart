import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/game_components.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_app_bar.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/features/game/application/game_route.dart';
import 'package:impostor_tn/features/game/presentation/discussion_view.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-08 Vote tally: counts only, never who voted for whom (D-22).
class TallyView extends StatefulWidget {
  const TallyView({
    super.key,
    required this.ballot,
    required this.outcome,
    required this.nameOf,
    required this.animate,
    required this.onContinue,
    required this.onClose,
  });

  final Ballot ballot;
  final TallyOutcome outcome;
  final String Function(PlayerId) nameOf;

  /// False on recovery: the screen appears complete (PUB-08 interactions).
  final bool animate;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  /// `voteTally`: one mark every 160 ms, then the outcome (360 ms).
  static const markInterval = Duration(milliseconds: 160);

  @override
  State<TallyView> createState() => _TallyViewState();
}

class _TallyViewState extends State<TallyView>
    with SingleTickerProviderStateMixin {
  late final _rows = tallyRows(widget.ballot);
  late final int _totalMarks = _rows.fold(0, (sum, e) => sum + e.value);
  late final AnimationController _controller;
  final _outcomeKey = GlobalKey();
  int _shownMarks = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TallyView.markInterval * _totalMarks + TesskraDurations.slow,
    )..addListener(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = !widget.animate || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  void _tick() {
    final elapsed = _controller.duration! * _controller.value;
    final marks =
        (elapsed.inMicroseconds ~/ TallyView.markInterval.inMicroseconds).clamp(
          0,
          _totalMarks,
        );
    if (marks != _shownMarks) {
      if (marks > _shownMarks && widget.animate) Haptics.light();
      setState(() => _shownMarks = marks);
    }
    if (_controller.isCompleted) {
      if (widget.animate) Haptics.medium();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _outcomeKey.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(target, duration: TesskraDurations.slow);
        }
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    final done = _controller.isCompleted;
    final shown = done ? _totalMarks : _shownMarks;

    var before = 0;
    final rows = <Widget>[];
    for (final MapEntry(key: id, value: count) in _rows) {
      final visible = (shown - before).clamp(0, count);
      before += count;
      rows.add(
        VoteTallyRow(
          name: widget.nameOf(id),
          count: count,
          visibleMarks: visible,
        ),
      );
    }

    final (Widget outcome, String button) = switch (widget.outcome) {
      TallyNominatedCivilian(:final nominee) => (
        Text(
          l10n.tallyNominated(directionIsolate(widget.nameOf(nominee))),
          textAlign: TextAlign.center,
          style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
        ),
        l10n.actionSeeResult,
      ),
      TallyImpostorCaught(:final nominee) => (
        Column(
          children: [
            Text(
              l10n.tallyImpostorCaught(
                directionIsolate(widget.nameOf(nominee)),
              ),
              textAlign: TextAlign.center,
              style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: TesskraSpacing.s2),
            Text(
              l10n.tallyFinalChance,
              textAlign: TextAlign.center,
              style: TesskraTypography.bodyL.copyWith(color: c.textSecondary),
            ),
          ],
        ),
        l10n.handoffPassTo(directionIsolate(widget.nameOf(nominee))),
      ),
      TallyFirstBallotTie() => (
        TesskraBanner(
          message: l10n.voteTie,
          kind: TesskraBannerKind.warning,
          icon: TesskraIcons.equal,
        ),
        l10n.actionRunoffStart,
      ),
      TallyRunoffTie() => (
        TesskraBanner(
          message: l10n.resultDrawNote,
          kind: TesskraBannerKind.warning,
          icon: TesskraIcons.equal,
        ),
        l10n.actionSeeResult,
      ),
    };

    return ScreenFrame(
      top: TesskraAppBar(
        title: l10n.tallyTitle,
        trailing: closeButton(context, widget.onClose),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: TesskraSpacing.s2),
          Center(
            child: PhaseChip(
              icon: TesskraIcons.vote,
              label: widget.ballot.kind == BallotKind.first
                  ? l10n.phaseVote
                  : l10n.voteRunoffTitle,
            ),
          ),
          const SizedBox(height: TesskraLayout.itemGap),
          ...rows,
          const SizedBox(height: TesskraLayout.sectionGap),
          AnimatedOpacity(
            key: _outcomeKey,
            opacity: done ? 1 : 0,
            duration: widget.animate ? TesskraDurations.slow : Duration.zero,
            child: outcome,
          ),
        ],
      ),
      actions: [
        TesskraButton(
          label: button,
          onPressed: done ? widget.onContinue : null,
        ),
      ],
    );
  }
}
