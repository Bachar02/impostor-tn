import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/private_scope.dart';
import 'package:impostor_tn/core/design/widgets/role_ticket.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/game/content/content_text.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

import '../../../support/proposed_category_labels.dart';
import 'widget_harness.dart';

/// The proposed category labels (D-37) against the content text rules and
/// the two components that display them: the pack card (as a pack title)
/// and the role ticket (as a category). Labels are referred to by index so
/// test names carry no content.
void main() {
  final l10n = lookupAppLocalizations(const Locale('ar'));

  double margin(Size size) => size.width < TesskraLayout.compactBreakpointWidth
      ? TesskraLayout.screenMarginHCompact
      : TesskraLayout.screenMarginH;

  test('every proposed label passes the content text rules', () {
    for (final label in proposedLabels) {
      expect(ContentText.check(label), isNull);
    }
  });

  test('the proposed labels are distinct', () {
    expect(proposedLabels.toSet(), hasLength(proposedLabels.length));
  });

  group('as a pack title on the pack card', () {
    for (final (frame, size, scale) in frames) {
      testWidgets('every label fits without overflow at $frame', (
        tester,
      ) async {
        await pumpRtl(
          tester,
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: margin(size)),
            child: Column(
              children: [
                for (final (i, label) in proposedLabels.indexed)
                  WordPackCard(
                    title: label,
                    meta: l10n.packWordCount('${20 + i}'),
                    state: PackCardState.values[i % 3],
                    selectedLabel: l10n.packSelected,
                    onTap: () {},
                  ),
              ],
            ),
          ),
          size: size,
          textScale: scale,
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(WordPackCard), findsNWidgets(proposedLabels.length));
      });
    }
  });

  group('as a category on the role ticket', () {
    Future<Size> ticketSize(
      WidgetTester tester,
      RevealedTicket content,
      Size size,
      double scale,
    ) async {
      await pumpRtl(
        tester,
        PrivateScope(
          onLeaveForeground: () {},
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: margin(size)),
            child: RoleTicket(content: content),
          ),
        ),
        size: size,
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byType(RoleTicket));
    }

    // SYNTHETIC: a short placeholder word, not content.
    RevealedTicket civilian(String category) => RevealedTicket(
      label: l10n.revealRoleLabelSealed,
      name: 'لاعب',
      caption: '${l10n.roleCivilian} · ${l10n.revealWordLabel}',
      bigText: 'كلمة',
      chip: l10n.revealCategory(category),
    );

    RevealedTicket impostor(String category) => RevealedTicket(
      label: l10n.revealRoleLabelSealed,
      name: 'لاعب',
      caption: '${l10n.roleImpostor} · ${l10n.revealCategoryOnly}',
      bigText: category,
      chip: l10n.revealNoWord,
    );

    // D-39: two lines reserved for the category on both tickets, so every
    // label keeps both tickets identical at every frame. `frames` includes
    // 360 and 320 wide at text scale 1.5.
    for (final (frame, size, scale) in frames) {
      for (final (i, label) in proposedLabels.indexed) {
        testWidgets('label #$i keeps both tickets the same size at $frame', (
          tester,
        ) async {
          final c = await ticketSize(tester, civilian(label), size, scale);
          final m = await ticketSize(tester, impostor(label), size, scale);

          expect(m, c, reason: 'D-27 parity');
        });
      }
    }

    // Not vacuous: at least one label really wraps the Civilian's chip
    // onto two lines, so the chip reserve is exercised above.
    testWidgets('a proposed label wraps the chip at 320 wide, scale 1.5', (
      tester,
    ) async {
      var wrapped = 0;
      for (final label in proposedLabels) {
        await ticketSize(tester, civilian(label), const Size(320, 568), 1.5);
        final chip = find.text(l10n.revealCategory(label));
        if (tester.getSize(chip).height > _chipLine(1.5) * 1.5) wrapped++;
      }

      expect(wrapped, greaterThan(0));
    });

    // SYNTHETIC: a category long enough to wrap at the 40 floor on the
    // Impostor ticket and in the Civilian's chip, but within two lines.
    const twoLineCategory = 'صنف طويل برشة';

    for (final (frame, size, scale) in frames) {
      testWidgets('a two-line category keeps parity at $frame', (tester) async {
        final c = await ticketSize(
          tester,
          civilian(twoLineCategory),
          size,
          scale,
        );
        final m = await ticketSize(
          tester,
          impostor(twoLineCategory),
          size,
          scale,
        );
        final big = tester.getSize(find.text(twoLineCategory)).height;

        expect(big, greaterThan(_floorLine), reason: 'wraps at the floor');
        expect(big, lessThanOrEqualTo(2 * _floorLine + 0.5));
        expect(m, c, reason: 'D-27 parity');
      });
    }
  });
}

/// One line of the chip text (`labelM`, 16 × 1.3) at [scale].
double _chipLine(double scale) =>
    TesskraTypography.labelM.fontSize! *
    scale *
    TesskraTypography.labelM.height!;

/// One line of the big text at its 40 floor.
final _floorLine =
    TesskraTypography.displayXLMinFontSize *
    TesskraTypography.displayXL.height!;
