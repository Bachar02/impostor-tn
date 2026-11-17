import 'dart:async';

import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/role_ticket.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/game/role_view.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

enum TicketPhase { sealed, revealed, saving, saveError }

/// PRV-02 Role ticket. [role] is given only in [TicketPhase.revealed]; in
/// every other phase the ticket is built sealed, so the secret leaves the
/// tree in the frame the phase changes (PRD §5, §12).
class TicketView extends StatefulWidget {
  const TicketView({
    super.key,
    required this.name,
    required this.phase,
    required this.onReveal,
    required this.onAcknowledge,
    required this.onBack,
    this.role,
  });

  final String name;
  final TicketPhase phase;
  final RoleView? role;
  final VoidCallback onReveal;

  /// Also the retry after a save error (C3 only).
  final VoidCallback onAcknowledge;
  final VoidCallback onBack;

  /// "Got it" is disabled for the first 800 ms after the reveal
  /// (INTERACTIONS_AND_ANIMATIONS.md §5; no token yet, Q-23 (4)).
  static const ackLock = Duration(milliseconds: 800);

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView>
    with SingleTickerProviderStateMixin {
  Timer? _lock;
  bool _locked = false;

  /// `ticketReveal`, linear 0 → 1. Settled at 1 when the view is built
  /// already revealed.
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    value: widget.phase == TicketPhase.revealed ? 1 : 0,
  );

  /// Where on [_reveal] the seal is gone and the secret may be built:
  /// 300 of 420 ms, or 0 with reduced motion (a plain 120 ms fade).
  double _sealEnd = 0;
  late final _sealLift = CurvedAnimation(parent: _reveal, curve: Curves.linear);
  late final _secretIn = CurvedAnimation(parent: _reveal, curve: Curves.linear);

  /// Q-30 (4): "got it" moves to the pinned area when, under the ticket, it
  /// would not be fully visible. Decided after layout, once per view.
  bool _pinAck = false;
  final _ackKey = GlobalKey();

  void _checkFold() {
    if (_pinAck || !mounted) return;
    final box = _ackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final media = MediaQuery.of(context);
    final visibleBottom =
        media.size.height -
        media.viewPadding.bottom -
        TesskraLayout.screenPaddingBottom;
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    if (bottom > visibleBottom + 0.5) setState(() => _pinAck = true);
  }

  @override
  void initState() {
    super.initState();
    _syncLock();
  }

  @override
  void didUpdateWidget(TicketView old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase) _syncLock();
    if (old.phase == TicketPhase.sealed &&
        widget.phase == TicketPhase.revealed) {
      final reduced = MediaQuery.disableAnimationsOf(context);
      _sealEnd = reduced
          ? 0
          : 1 -
                TesskraMotion.ticketSecretIn.inMicroseconds /
                    TesskraMotion.ticketReveal.inMicroseconds;
      // Reduced motion: no lift, the secret fades in over the whole 120 ms.
      _sealLift.curve = reduced
          ? const Threshold(0)
          : Interval(0, _sealEnd, curve: TesskraCurves.enter);
      _secretIn.curve = reduced ? Curves.linear : Interval(_sealEnd, 1);
      _reveal
        ..duration = reduced
            ? TesskraMotion.ticketReduced
            : TesskraMotion.ticketReveal
        ..forward(from: 0);
    }
  }

  void _syncLock() {
    _lock?.cancel();
    _locked = widget.phase == TicketPhase.revealed;
    if (_locked) {
      _lock = Timer(TicketView.ackLock, () {
        if (mounted) setState(() => _locked = false);
      });
    }
  }

  @override
  void dispose() {
    _lock?.cancel();
    _sealLift.dispose();
    _secretIn.dispose();
    _reveal.dispose();
    super.dispose();
  }

  /// The secret is built only in the revealed phase and only once the seal
  /// has lifted off (ticketReveal; INTERACTIONS_AND_ANIMATIONS §6).
  bool get _secretShown =>
      widget.phase == TicketPhase.revealed && _reveal.value >= _sealEnd;

  RoleTicketContent _content(AppLocalizations l10n) {
    final label = l10n.revealRoleLabelSealed;
    return switch ((_secretShown, widget.role)) {
      // Parity layout (D-27): the role name opens the caption.
      (true, CivilianView(:final word, :final category)) => RevealedTicket(
        label: label,
        name: widget.name,
        caption: '${l10n.roleCivilian} · ${l10n.revealWordLabel}',
        bigText: word,
        chip: l10n.revealCategory(category),
      ),
      (true, ImpostorView(:final category)) => RevealedTicket(
        label: label,
        name: widget.name,
        caption: '${l10n.roleImpostor} · ${l10n.revealCategoryOnly}',
        bigText: category,
        chip: l10n.revealNoWord,
      ),
      _ => SealedTicket(
        label: label,
        name: widget.name,
        sealedText: l10n.revealSealed,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phase = widget.phase;
    final underTicket = phase != TicketPhase.sealed;
    if (underTicket && !_pinAck) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFold());
    }
    final ackButton = TesskraButton(
      key: _pinAck ? null : _ackKey,
      label: phase == TicketPhase.saveError ? l10n.actionRetry : l10n.revealAck,
      loading: phase == TicketPhase.saving,
      onPressed: _locked ? null : widget.onAcknowledge,
    );

    return ScreenFrame(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrivacyHint(text: l10n.privacyOnlyYou),
          const SizedBox(height: TesskraLayout.sectionGap),
          AnimatedBuilder(
            animation: _reveal,
            builder: (context, _) => RoleTicket(
              content: _content(l10n),
              sealLift: widget.phase == TicketPhase.revealed ? _sealLift : null,
              secretIn: _secretIn,
            ),
          ),
          if (phase == TicketPhase.saveError) ...[
            const SizedBox(height: TesskraLayout.itemGap),
            TesskraBanner(
              message: l10n.stateError,
              kind: TesskraBannerKind.error,
            ),
          ],
          if (underTicket && !_pinAck) ...[
            const SizedBox(height: TesskraLayout.itemGap),
            ackButton,
          ],
        ],
      ),
      // Sealed: "show me my role" and "back" in the pinned area, a different
      // place from "got it" (PRV-02 layout item 3).
      actions: phase == TicketPhase.sealed
          ? [
              TesskraButton(label: l10n.revealShow, onPressed: widget.onReveal),
              TesskraButton(
                label: l10n.actionBack,
                variant: TesskraButtonVariant.secondary,
                onPressed: widget.onBack,
              ),
            ]
          : [if (_pinAck) ackButton],
    );
  }
}
