import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/widgets/private_scope.dart';
import 'package:impostor_tn/core/design/widgets/role_ticket.dart';

import 'widget_harness.dart';

// SYNTHETIC TEST CONTENT: placeholder Arabic and Latin text, not game words.
const _label = 'دور';
const _name = 'لاعب تجربة';
const _civilian = RevealedTicket(
  label: _label,
  name: _name,
  caption: 'دور أ · نص صغير',
  bigText: 'كلمة',
  chip: 'شريحة: نص',
);
const _impostor = RevealedTicket(
  label: _label,
  name: _name,
  caption: 'دور ب طويل · نص صغير آخر',
  bigText: 'صنف أطول بكثير',
  chip: 'شريحة أطول من الأولى',
);

Future<void> pumpTicket(
  WidgetTester tester,
  RoleTicketContent content, {
  Size size = const Size(360, 720),
  double textScale = 1,
}) => pumpRtl(
  tester,
  PrivateScope(
    onLeaveForeground: () {},
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RoleTicket(content: content),
    ),
  ),
  size: size,
  textScale: textScale,
);

List<Type> widgetTypes(WidgetTester tester) => [
  for (final element
      in find
          .descendant(
            of: find.byType(RoleTicket),
            matching: find.byWidgetPredicate((_) => true),
          )
          .evaluate())
    element.widget.runtimeType,
];

void main() {
  group('parity between the two revealed tickets (D-27)', () {
    for (final (name, size, scale) in frames) {
      testWidgets('same size at $name', (tester) async {
        await pumpTicket(tester, _civilian, size: size, textScale: scale);
        final civilian = tester.getSize(find.byType(RoleTicket));
        await pumpTicket(tester, _impostor, size: size, textScale: scale);
        final impostor = tester.getSize(find.byType(RoleTicket));

        expect(impostor, civilian);
      });
    }

    // Laid-out lines are rounded to whole pixels; the reserve rounds each
    // line up, so a big text at full size and one that had to shrink give
    // the same ticket. 1.15 is a scale where the full-size line rounds up
    // (72 × 1.15 × 1.3 = 107.64 → 108) and sets the reserve.
    for (final (name, size, scale) in [
      ...frames,
      ('360x720 scale 1.15', const Size(360, 720), 1.15),
      ('320x568 scale 1.15', const Size(320, 568), 1.15),
    ]) {
      testWidgets('full-size and shrunk big text give one size at $name', (
        tester,
      ) async {
        RevealedTicket withBig(String text) => RevealedTicket(
          label: _label,
          name: _name,
          caption: 'نص',
          bigText: text,
          chip: 'شريحة',
        );
        await pumpTicket(tester, withBig('ب'), size: size, textScale: scale);
        final full = tester.getSize(find.byType(RoleTicket));
        await pumpTicket(
          tester,
          withBig('كلمتان طويلتان'),
          size: size,
          textScale: scale,
        );

        expect(tester.getSize(find.byType(RoleTicket)), full);
      });
    }

    testWidgets('same widget structure, only the text differs', (tester) async {
      await pumpTicket(tester, _civilian);
      final civilian = widgetTypes(tester);
      await pumpTicket(tester, _impostor);

      expect(widgetTypes(tester), civilian);
    });

    testWidgets('the top row keeps the player name after the reveal', (
      tester,
    ) async {
      await pumpTicket(
        tester,
        const SealedTicket(label: _label, name: _name, sealedText: 'مخفي'),
      );
      final sealedTop = tester.getRect(find.textContaining(_name));
      await pumpTicket(tester, _civilian);

      expect(tester.getRect(find.textContaining(_name)), sealedTop);
    });
  });

  testWidgets('a sealed ticket shows no secret', (tester) async {
    await pumpTicket(
      tester,
      const SealedTicket(label: _label, name: _name, sealedText: 'مخفي'),
    );

    expect(find.text('كلمة'), findsNothing);
    expect(find.textContaining('شريحة'), findsNothing);
    expect(find.text('مخفي'), findsOneWidget);
  });

  testWidgets('secret text is not selectable', (tester) async {
    await pumpTicket(tester, _civilian);

    expect(find.byType(SelectableText), findsNothing);
    expect(find.byType(SelectionArea), findsNothing);
  });

  for (final (name, size, scale) in frames) {
    testWidgets('a 16-character name and a long text fit at $name', (
      tester,
    ) async {
      await pumpTicket(
        tester,
        const RevealedTicket(
          label: _label,
          name: 'اسم من ستة عشر حر',
          caption: 'نص · نص',
          bigText: 'كلمتان طويلتان',
          chip: 'شريحة',
        ),
        size: size,
        textScale: scale,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(RoleTicket)).width,
        lessThanOrEqualTo(size.width),
      );
    });
  }

  test('content does not print its text', () {
    expect(_civilian.toString(), isNot(contains('كلمة')));
  });
}
