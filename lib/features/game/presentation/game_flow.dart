import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/private_scope.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_controller.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/game/application/game_route.dart';
import 'package:impostor_tn/features/game/application/game_steps.dart';
import 'package:impostor_tn/features/game/presentation/discussion_view.dart';
import 'package:impostor_tn/features/game/presentation/guess_view.dart';
import 'package:impostor_tn/features/game/presentation/handoff_view.dart';
import 'package:impostor_tn/features/game/presentation/leave_dialog.dart';
import 'package:impostor_tn/features/game/presentation/results_view.dart';
import 'package:impostor_tn/features/game/presentation/tally_view.dart';
import 'package:impostor_tn/features/game/presentation/ticket_view.dart';
import 'package:impostor_tn/features/game/presentation/vote_view.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/privacy/screen_protection.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// Where the group goes after leaving the game.
enum GameExit { home, changeSetup }

/// The one route of a running game (ADR-0002). The screen is a function of
/// the saved game and of [GameUiState] (`routeGame`); this widget only
/// runs checkpoints through [GameController] and keeps the local view
/// state. It holds no rule.
class GameFlow extends ConsumerStatefulWidget {
  const GameFlow({super.key, required this.onExit, this.coldStart = false});

  /// Called after C8 has committed, with the retained roster.
  final void Function(GameExit exit, SavedRoster roster) onExit;

  /// Opened from launch with a saved, unfinished game: show PRV-05 first.
  final bool coldStart;

  @override
  ConsumerState<GameFlow> createState() => _GameFlowState();
}

class _GameFlowState extends ConsumerState<GameFlow> {
  late GameUiState _ui = GameUiState(gate: widget.coldStart);
  String? _sessionId;

  // Private-screen detail that must never outlive the screen.
  TicketPhase _ticket = TicketPhase.sealed;
  PlayerId? _selection;
  bool _reviewing = false;

  /// A tally reached live animates; one reached by recovery does not.
  bool _animateTally = false;
  bool _busy = false;
  String? _error;
  String? _screenKey;

  /// The current screen replaced a private one: its outgoing child must not
  /// be kept for a transition.
  bool _enteredFromPrivate = false;
  bool _dialogOpen = false;

  /// Raised each time the app is hidden. A save that started before a hide
  /// must not reopen a private screen or show its error when it ends (F11:
  /// the destination is worked out from saved state, never from the screen).
  int _hideEpoch = 0;

  /// D-18: true once the platform confirmed screenshot protection.
  bool _protected = false;

  late final ScreenProtection _protection;

  @override
  void initState() {
    super.initState();
    _protection = ref.read(screenProtectionProvider);
    unawaited(_protect());
  }

  @override
  void dispose() {
    // The game is left or the route is gone: protection ends (D-18).
    unawaited(_protection.setProtected(on: false));
    super.dispose();
  }

  Future<bool> _protect() async {
    final ok = await _protection.setProtected(on: true);
    if (mounted) setState(() => _protected = ok);
    return ok;
  }

  GameController get _games => ref.read(gameControllerProvider.notifier);

  AppLocalizations get _l10n => AppLocalizations.of(context);

  /// Runs a checkpoint with the loading state; on failure keeps the screen
  /// and shows the retryable error (SCREEN_SPECIFICATIONS §1.6).
  Future<Checkpoint<T>> _run<T>(Future<Checkpoint<T>> Function() action) async {
    final epoch = _hideEpoch;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await action();
    if (!mounted) return result;
    setState(() {
      _busy = false;
      // Hidden meanwhile: the screen was already reset to the handoff.
      if (epoch != _hideEpoch) return;
      if (result is! Saved<T>) {
        _error = switch (result) {
          Refused(reason: RefusalReason.noEligibleWord) => _l10n.errorNoWords,
          _ => _l10n.stateError,
        };
      }
    });
    return result;
  }

  void _closePrivate() {
    _ui = _ui.closePrivate();
    _ticket = TicketPhase.sealed;
    _selection = null;
    _reviewing = false;
  }

  /// F11 warm return: the secret leaves at once, back to the handoff. A C3
  /// in flight finishes on its own and moves on.
  void _onHidden() {
    _hideEpoch++;
    if (_dialogOpen) {
      Navigator.of(context).pop();
      _dialogOpen = false;
    }
    if (_ui.view != null) {
      setState(_closePrivate);
      // A hidden app gets no frames; force one so the secret is gone from
      // the last rendered frame too, not only from the tree.
      SchedulerBinding.instance.scheduleForcedFrame();
    }
  }

  // ---- intents ------------------------------------------------------------

  Future<void> _confirmIdentity(ActiveGame game, HandoffScreen screen) async {
    if (!_protected && !await _protect()) {
      setState(() => _error = _l10n.stateError);
      return;
    }
    switch (game.session.phase) {
      case RevealPhase():
        final epoch = _hideEpoch;
        final result = await _run(() => _games.confirmIdentity(screen.player));
        if (result is Saved<ActiveGame> && mounted && epoch == _hideEpoch) {
          setState(() {
            _ui = _ui.open(screen.player, PrivateView.ticket);
            _ticket = TicketPhase.sealed;
          });
        }
      case FinalGuessPhase():
        setState(() => _ui = _ui.open(screen.player, PrivateView.guess));
      case _:
        setState(() => _ui = _ui.open(screen.player, PrivateView.vote));
    }
  }

  Future<void> _acknowledge(PlayerId player) async {
    // The secret leaves the tree in this frame, before C3 runs (PRV-02).
    setState(() => _ticket = TicketPhase.saving);
    Haptics.light();
    final epoch = _hideEpoch;
    final result = await _games.acknowledge(player);
    if (!mounted) return;
    if (epoch != _hideEpoch) {
      setState(_closePrivate);
      return;
    }
    setState(() {
      if (result is Saved<ActiveGame>) {
        _closePrivate();
      } else {
        _ticket = TicketPhase.saveError;
      }
    });
  }

  Future<void> _castVote(VoteScreen screen) async {
    final target = _selection;
    if (target == null) return;
    final result = await _run(
      () => _games.castVote(
        ballot: screen.ballot.kind,
        voter: screen.voter,
        target: target,
      ),
    );
    if (result case Saved(value: final game) when mounted) {
      Haptics.medium();
      setState(() {
        _closePrivate();
        // The vote closed its ballot: the tally comes next, live.
        _animateTally =
            GameSteps.openBallotKind(game.session) != screen.ballot.kind;
        if (game.session.phase is ResultPhase) {
          _ui = _ui.copyWith(resultViaBallot: true);
        }
      });
    }
  }

  Future<void> _submitGuess(String raw) async {
    final result = await _run(() => _games.submitFinalGuess(raw));
    if (result is Saved<ActiveGame> && mounted) {
      setState(() {
        _closePrivate();
        _ui = _ui.copyWith(resultViaBallot: false);
      });
    }
  }

  Future<void> _leave(GameExit exit) async {
    final result = await _run(_games.leave);
    if (result case Saved(value: final roster) when mounted) {
      widget.onExit(exit, roster);
    }
  }

  Future<void> _askLeave() async {
    _dialogOpen = true;
    // Over a private screen the dialog is carbon (OVL-02).
    final carbon = !_isPublicKey(_screenKey);
    final confirmed = await showLeaveDialog(context, carbon: carbon);
    _dialogOpen = false;
    if (confirmed && mounted) await _leave(GameExit.home);
  }

  void _back(GameScreen screen) {
    if (_busy) return;
    switch (screen) {
      case TicketScreen():
        switch (_ticket) {
          case TicketPhase.sealed:
            setState(_closePrivate);
          case TicketPhase.saveError:
            unawaited(_askLeave());
          case TicketPhase.revealed || TicketPhase.saving:
            break; // A secret may be on screen: back does nothing (F10).
        }
      case VoteScreen():
        setState(_closePrivate);
      case GuessScreen() when _reviewing:
        setState(() => _reviewing = false);
      case ResultsScreen():
        break;
      case ResumeGateScreen() ||
          HandoffScreen() ||
          GuessScreen() ||
          DiscussionScreen() ||
          TallyScreen():
        unawaited(_askLeave());
    }
  }

  // ---- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    if (game == null) return const Scaffold(body: SizedBox.expand());
    if (game.sessionId != _sessionId) {
      // A new session (start or replay): nothing local carries over.
      if (_sessionId != null) _ui = const GameUiState();
      _sessionId = game.sessionId;
      _closePrivate();
    }
    final screen = routeGame(game, _ui);
    final key = _keyOf(screen);
    if (key != _screenKey) {
      _enteredFromPrivate = _isPrivateKey(_screenKey);
      _screenKey = key;
      _error = null;
    }
    final dropOutgoing = _enteredFromPrivate;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final child = _buildScreen(game, screen);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(screen);
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: reduce || dropOutgoing
              ? Duration.zero
              : TesskraDurations.base,
          // Out of a private screen the outgoing child is dropped in this
          // very frame, never kept for a fade: a secret leaves the tree in
          // the frame it is hidden (SCREEN_SPECIFICATIONS §1.5).
          // The structure never changes, so the current screen keeps its state.
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.center,
            children: [if (!dropOutgoing) ...previous, ?current],
          ),
          child: KeyedSubtree(key: ValueKey(key), child: child),
        ),
      ),
    );
  }

  static bool _isPublicKey(String? key) =>
      key != null &&
      (key == 'discussion' ||
          key.startsWith('tally') ||
          key.startsWith('results'));

  static bool _isPrivateKey(String? key) =>
      key != null &&
      (key.startsWith('ticket') ||
          key.startsWith('vote') ||
          key.startsWith('guess'));

  String _keyOf(GameScreen screen) => switch (screen) {
    ResumeGateScreen() => 'gate',
    HandoffScreen(:final player) => 'handoff-${player.value}',
    TicketScreen(:final player) => 'ticket-${player.value}',
    VoteScreen(:final voter, :final ballot) =>
      'vote-${ballot.kind.name}-${voter.value}',
    GuessScreen() => 'guess',
    DiscussionScreen() => 'discussion',
    TallyScreen(:final ballot) => 'tally-${ballot.kind.name}',
    ResultsScreen() => 'results-$_sessionId',
  };

  Widget _private(Widget child) =>
      PrivateScope(onLeaveForeground: _onHidden, child: child);

  Widget _buildScreen(ActiveGame game, GameScreen screen) {
    final session = game.session;
    String nameOf(PlayerId id) => session.playerById(id).name;
    switch (screen) {
      case ResumeGateScreen():
        return _private(
          ResumeGateView(
            onContinue: () => setState(() => _ui = _ui.copyWith(gate: false)),
            onLeave: () => unawaited(_askLeave()),
          ),
        );
      case HandoffScreen(:final player, :final position, :final total):
        return _private(
          HandoffView(
            name: nameOf(player),
            position: position,
            total: total,
            loading: _busy,
            error: _error,
            onConfirm: () => unawaited(_confirmIdentity(game, screen)),
          ),
        );
      case TicketScreen(:final player):
        return _private(
          TicketView(
            name: nameOf(player),
            phase: _ticket,
            // The role is read only while revealed (PRD §5, D-21).
            role: _ticket == TicketPhase.revealed
                ? game.roleViewForPendingPlayer()
                : null,
            onReveal: () {
              Haptics.medium();
              setState(() => _ticket = TicketPhase.revealed);
            },
            onAcknowledge: () => unawaited(_acknowledge(player)),
            onBack: () => setState(_closePrivate),
          ),
        );
      case VoteScreen(:final voter, :final ballot):
        return _private(
          VoteView(
            voterName: nameOf(voter),
            runoff: ballot.kind == BallotKind.runoff,
            choices: [
              for (final id in ballot.candidates)
                (id: id, name: nameOf(id), isVoter: id == voter),
            ],
            selected: _selection,
            saving: _busy,
            error: _error,
            onSelect: (id) {
              Haptics.selection();
              setState(() => _selection = id);
            },
            onConfirm: () => unawaited(_castVote(screen)),
            onBack: () => setState(_closePrivate),
          ),
        );
      case GuessScreen(:final impostor):
        return _private(
          GuessView(
            name: nameOf(impostor),
            reviewing: _reviewing,
            saving: _busy,
            error: _error,
            onReview: () => setState(() => _reviewing = true),
            onEdit: () => setState(() => _reviewing = false),
            onSubmit: (raw) => unawaited(_submitGuess(raw)),
          ),
        );
      case DiscussionScreen():
        return DiscussionView(
          loading: _busy,
          error: _error,
          onStartVote: () => unawaited(_run(_games.openVoting)),
          onClose: () => unawaited(_askLeave()),
        );
      case TallyScreen(:final ballot, :final outcome):
        return TallyView(
          ballot: ballot,
          outcome: outcome,
          nameOf: nameOf,
          animate: _animateTally,
          onClose: () => unawaited(_askLeave()),
          onContinue: () => setState(() {
            _animateTally = false;
            _ui = _ui.copyWith(seenTallies: {..._ui.seenTallies, ballot.kind});
          }),
        );
      case ResultsScreen():
        return ResultsView(
          session: session,
          busy: _busy,
          error: _error,
          onPlayAgain: () => unawaited(_run(_games.playAgain)),
          onChangeSetup: () => unawaited(_leave(GameExit.changeSetup)),
          onHome: () => unawaited(_leave(GameExit.home)),
        );
    }
  }
}
