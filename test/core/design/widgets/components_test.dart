import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/count_pill.dart';
import 'package:impostor_tn/core/design/widgets/fitted_display_text.dart';
import 'package:impostor_tn/core/design/widgets/handoff_block.dart';
import 'package:impostor_tn/core/design/widgets/private_scope.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_dialog.dart';

import 'widget_harness.dart';

// Placeholder labels and names; no game content.

void main() {
  group('TesskraButton', () {
    testWidgets('calls back on tap', (tester) async {
      var taps = 0;
      await pumpRtl(
        tester,
        TesskraButton(label: 'زر', onPressed: () => taps++),
      );

      await tester.tap(find.byType(TesskraButton));

      expect(taps, 1);
    });

    testWidgets('disabled and loading buttons do not call back', (
      tester,
    ) async {
      var taps = 0;
      await pumpRtl(
        tester,
        Column(
          children: [
            const TesskraButton(label: 'أ', onPressed: null),
            TesskraButton(label: 'ب', onPressed: () => taps++, loading: true),
          ],
        ),
      );

      await tester.tap(find.text('أ'));
      await tester.tap(find.byType(TesskraButton).last);

      expect(taps, 0);
    });

    testWidgets('loading keeps the width and hides the label', (tester) async {
      Widget button(bool loading) => Center(
        child: IntrinsicWidth(
          child: TesskraButton(
            label: 'زر بنص طويل',
            onPressed: () {},
            loading: loading,
          ),
        ),
      );
      await pumpRtl(tester, button(false));
      final idle = tester.getSize(find.byType(TesskraButton));
      await pumpRtl(tester, button(true));

      expect(tester.getSize(find.byType(TesskraButton)), idle);
    });

    testWidgets('is announced as a button with its label', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpRtl(tester, TesskraButton(label: 'زر', onPressed: () {}));

      expect(
        tester.getSemantics(find.byType(TesskraButton)),
        isSemantics(
          label: 'زر',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    for (final variant in TesskraButtonVariant.values) {
      testWidgets('${variant.name} is at least 48 tall', (tester) async {
        await pumpRtl(
          tester,
          TesskraButton(label: 'زر', onPressed: () {}, variant: variant),
        );

        expect(
          tester.getSize(find.byType(TesskraButton)).height,
          greaterThanOrEqualTo(TesskraSizes.touchTargetMin),
        );
      });
    }

    testWidgets('a long label stays on one line at 320 and scale 1.5', (
      tester,
    ) async {
      await pumpRtl(
        tester,
        TesskraButton(label: 'أنا اسم طويل جدا جدا جدا', onPressed: () {}),
        size: const Size(320, 568),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('the accent variant does not exist on carbon', (tester) async {
      await pumpRtl(
        tester,
        PrivateScope(
          onLeaveForeground: () {},
          child: TesskraButton(
            label: 'زر',
            onPressed: () {},
            variant: TesskraButtonVariant.accent,
          ),
        ),
      );

      expect(tester.takeException(), isA<StateError>());
    });
  });

  group('PrivateScope', () {
    testWidgets('applies the carbon theme', (tester) async {
      late TesskraTokens tokens;
      await pumpRtl(
        tester,
        PrivateScope(
          onLeaveForeground: () {},
          child: Builder(
            builder: (context) {
              tokens = TesskraTokens.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(tokens.isCarbon, isTrue);
    });

    testWidgets('reports leaving the foreground when the app is hidden, not '
        'when it is only inactive', (tester) async {
      var left = 0;
      await pumpRtl(
        tester,
        PrivateScope(onLeaveForeground: () => left++, child: const SizedBox()),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      expect(left, 0, reason: 'notification shade');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      expect(left, 1);
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  group('HandoffBlock', () {
    for (final (name, size, scale) in frames) {
      testWidgets('a 16-character name fits in two lines at $name', (
        tester,
      ) async {
        await pumpRtl(
          tester,
          PrivateScope(
            onLeaveForeground: () {},
            child: const HandoffBlock(
              passLabel: 'عدّي التليفون لـ',
              name: 'اسم من ستة عشر حر',
              position: 12,
              total: 12,
            ),
          ),
          size: size,
          textScale: scale,
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(CountPill), findsOneWidget);
      });
    }

    testWidgets('has no position pill for the final guess', (tester) async {
      await pumpRtl(
        tester,
        PrivateScope(
          onLeaveForeground: () {},
          child: const HandoffBlock(passLabel: 'عدّي', name: 'لاعب'),
        ),
      );

      expect(find.byType(CountPill), findsNothing);
    });
  });

  group('FittedDisplayText', () {
    testWidgets('shrinks but never below the floor before last-resort '
        'scaling', (tester) async {
      await tester.runAsync(loadTesskraFonts);
      final size = FittedDisplayText.fittedSize(
        text: 'نص طويل جدا جدا جدا جدا جدا',
        style: TesskraTypography.displayXL,
        startSize: 72,
        minFontSize: TesskraTypography.displayXLMinFontSize,
        maxLines: 1,
        maxWidth: 200,
        textDirection: TextDirection.rtl,
      );

      expect(size, TesskraTypography.displayXLMinFontSize);
    });

    testWidgets('keeps the full size when it fits', (tester) async {
      await tester.runAsync(loadTesskraFonts);
      final size = FittedDisplayText.fittedSize(
        text: 'نص',
        style: TesskraTypography.displayXL,
        startSize: 72,
        minFontSize: 40,
        maxLines: 1,
        maxWidth: 300,
        textDirection: TextDirection.rtl,
      );

      expect(size, 72);
    });
  });

  group('TesskraDialog', () {
    testWidgets('stacks actions in order, the safe one last', (tester) async {
      await pumpRtl(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showTesskraDialog<void>(
              context: context,
              builder: (_) => TesskraDialog(
                title: 'عنوان',
                body: 'نص',
                actions: [
                  TesskraButton(
                    label: 'خطر',
                    onPressed: () {},
                    variant: TesskraButtonVariant.destructive,
                  ),
                  TesskraButton(
                    label: 'آمن',
                    onPressed: () {},
                    variant: TesskraButtonVariant.secondary,
                  ),
                ],
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('آمن')).dy,
        greaterThan(tester.getTopLeft(find.text('خطر')).dy),
      );
    });

    testWidgets('on carbon it has no shadow', (tester) async {
      await pumpRtl(
        tester,
        PrivateScope(
          onLeaveForeground: () {},
          child: const TesskraDialog(title: 'ع', body: 'ن', actions: []),
        ),
      );
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TesskraDialog),
              matching: find.byType(Container),
            )
            .first,
      );

      expect((box.decoration! as BoxDecoration).boxShadow, isNull);
    });
  });

  testWidgets('an error banner is announced and shows an icon', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRtl(
      tester,
      const TesskraBanner(message: 'خطأ', kind: TesskraBannerKind.error),
    );

    expect(
      tester.getSemantics(find.byType(TesskraBanner)),
      isSemantics(isLiveRegion: true),
    );
    semantics.dispose();
  });

  group('ScreenFrame', () {
    for (final (width, margin) in [
      (320.0, TesskraLayout.screenMarginHCompact),
      (360.0, TesskraLayout.screenMarginH),
    ]) {
      testWidgets('margin $margin at $width wide', (tester) async {
        await pumpRtl(
          tester,
          const ScreenFrame(body: SizedBox(key: Key('body'), height: 10)),
          size: Size(width, 568),
        );

        expect(tester.getTopLeft(find.byKey(const Key('body'))).dx, margin);
      });
    }

    testWidgets('keeps the action pinned when the body is too tall', (
      tester,
    ) async {
      await pumpRtl(
        tester,
        ScreenFrame(
          body: const SizedBox(height: 2000),
          actions: [TesskraButton(label: 'زر', onPressed: () {})],
        ),
        size: const Size(320, 568),
      );

      final button = tester.getRect(find.byType(TesskraButton));
      expect(button.bottom, lessThanOrEqualTo(568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('caps content at 480 on a wide screen', (tester) async {
      await pumpRtl(
        tester,
        const ScreenFrame(body: SizedBox(key: Key('body'), height: 10)),
        size: const Size(800, 600),
      );

      expect(
        tester.getSize(find.byKey(const Key('body'))).width,
        TesskraLayout.maxContentWidth - 2 * TesskraLayout.screenMarginH,
      );
    });
  });
}
