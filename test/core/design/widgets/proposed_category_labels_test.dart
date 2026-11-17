import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/game/content/content_text.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

import '../../../support/proposed_category_labels.dart';
import '../../../support/ticket_category_fit.dart';
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
    // D-39: two lines reserved for the category on both tickets, so every
    // label keeps both tickets identical at every frame. `frames` includes
    // 360 and 320 wide at text scale 1.5.
    for (final (frame, size, scale) in frames) {
      for (final (i, label) in proposedLabels.indexed) {
        testWidgets('label #$i keeps both tickets the same size at $frame', (
          tester,
        ) async {
          final fit = await measureCategory(tester, label, size, scale);

          expect(fit.parity, isTrue, reason: 'D-27 parity: $fit');
          expect(fit.fits, isTrue, reason: 'within two lines: $fit');
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
        final fit = await measureCategory(
          tester,
          label,
          const Size(320, 568),
          1.5,
        );
        if (fit.chipHeight > chipLine(1.5) * 1.5) wrapped++;
      }

      expect(wrapped, greaterThan(0));
    });

    // SYNTHETIC: a category long enough to wrap at the 40 floor on the
    // Impostor ticket, but within two lines.
    const twoLineCategory = 'صنف طويل برشة';

    for (final (frame, size, scale) in frames) {
      testWidgets('a two-line category keeps parity at $frame', (tester) async {
        final fit = await measureCategory(tester, twoLineCategory, size, scale);

        expect(fit.bigTextHeight, greaterThan(floorLine), reason: 'wraps');
        expect(fit.fits, isTrue, reason: '$fit');
      });
    }
  });
}
