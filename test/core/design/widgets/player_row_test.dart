import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/game/game_rules.dart';

import 'widget_harness.dart';

/// PlayerRow with edit and delete side by side: no overflow with the
/// longest names at 320 wide and text scale 1.5, both buttons keep full
/// 48 × 48 targets, and the name gives way (ellipsis), not the buttons.
void main() {
  // Names at the 16-character limit (D-15), wide Arabic and wide Latin.
  final names = ['م' * GameRules.maxNameLength, 'W' * GameRules.maxNameLength];

  for (final (frame, size, scale) in frames) {
    for (final (i, name) in names.indexed) {
      for (final canDelete in [true, false]) {
        testWidgets(
          'long name #$i, delete ${canDelete ? 'on' : 'off'}, at $frame',
          (tester) async {
            await pumpRtl(
              tester,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TesskraLayout.screenMarginHCompact,
                ),
                child: PlayerRow(
                  position: 12,
                  name: name,
                  editLabel: 'edit',
                  onEdit: () {},
                  deleteLabel: 'delete',
                  onDelete: canDelete ? () {} : null,
                ),
              ),
              size: size,
              textScale: scale,
            );

            expect(tester.takeException(), isNull);
            final row = tester.getRect(find.byType(PlayerRow));
            final buttons = find.byType(TesskraIconButton);
            expect(buttons, findsNWidgets(2));
            for (final button in buttons.evaluate()) {
              final rect = tester.getRect(find.byWidget(button.widget));
              expect(rect.size, const Size.square(TesskraSizes.iconButton));
              expect(row.contains(rect.center), isTrue);
            }
            final text = tester.widget<Text>(find.textContaining(name));
            expect(text.overflow, TextOverflow.ellipsis);
            expect(text.maxLines, 1);
          },
        );
      }
    }
  }

  testWidgets('RTL: delete is at the far end, edit next to it', (tester) async {
    await pumpRtl(
      tester,
      PlayerRow(
        position: 1,
        name: 'Sami',
        editLabel: 'edit',
        onEdit: () {},
        deleteLabel: 'delete',
        onDelete: () {},
      ),
    );

    Rect of(TesskraIcons icon) => tester.getRect(
      find.byWidgetPredicate((w) => w is TesskraIconButton && w.icon == icon),
    );
    final edit = of(TesskraIcons.pencil);
    final delete = of(TesskraIcons.trash);
    expect(delete.right, lessThanOrEqualTo(edit.left));
    expect(find.bySemanticsLabel('delete'), findsOneWidget);
    expect(find.bySemanticsLabel('edit'), findsOneWidget);
  });
}
