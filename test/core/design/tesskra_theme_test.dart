import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_colors.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_palette.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';

void main() {
  group('TesskraTheme', () {
    test('public theme is the paper theme', () {
      final theme = TesskraTheme.public;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, TesskraPalette.paper);
      expect(theme.colorScheme.primary, TesskraPalette.stamp);
      expect(theme.colorScheme.onPrimary, TesskraPalette.paperRaised);
      expect(theme.colorScheme.secondary, TesskraPalette.mustard);
      expect(theme.colorScheme.onSurface, TesskraPalette.ink);
      expect(theme.colorScheme.outline, TesskraPalette.ink);
      expect(
        theme.extension<TesskraTokens>()!.colors,
        same(TesskraColors.public),
      );
    });

    test('private theme is the carbon theme', () {
      final theme = TesskraTheme.private;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, TesskraPalette.carbon);
      expect(theme.colorScheme.primary, TesskraPalette.mustard);
      expect(theme.colorScheme.onPrimary, TesskraPalette.carbon);
      expect(theme.colorScheme.onSurface, TesskraPalette.paper);
      expect(
        theme.extension<TesskraTokens>()!.colors,
        same(TesskraColors.private),
      );
    });

    test('private theme carries no role colour', () {
      // Privacy: both roles must look identical on carbon screens.
      const c = TesskraColors.private;
      final used = {
        c.background,
        c.surface,
        c.textPrimary,
        c.textSecondary,
        c.textDisabled,
        c.border,
        c.borderStrong,
        c.primary,
        c.primaryPressed,
        c.onPrimary,
        c.success,
        c.error,
        c.focusRing,
        c.ticket,
        c.onTicket,
      };
      expect(used, isNot(contains(TesskraRoleColors.civilian)));
      expect(used, isNot(contains(TesskraRoleColors.impostor)));
    });

    test('text theme follows the DESIGN_SYSTEM §7 mapping', () {
      final text = TesskraTheme.public.textTheme;
      void same(TextStyle? actual, TextStyle token) {
        expect(actual!.fontFamily, token.fontFamily);
        expect(actual.fontSize, token.fontSize);
        expect(actual.fontWeight, token.fontWeight);
        expect(actual.color, TesskraPalette.ink);
      }

      same(text.displayLarge, TesskraTypography.displayXL);
      same(text.displayMedium, TesskraTypography.displayL);
      same(text.displaySmall, TesskraTypography.displayM);
      same(text.headlineSmall, TesskraTypography.titleL);
      same(text.titleLarge, TesskraTypography.titleM);
      same(text.bodyLarge, TesskraTypography.bodyL);
      same(text.bodyMedium, TesskraTypography.bodyM);
      same(text.labelLarge, TesskraTypography.labelL);
      same(text.labelMedium, TesskraTypography.labelM);
      same(text.bodySmall, TesskraTypography.caption);
    });
  });

  group('TesskraTokens', () {
    testWidgets('of() returns the tokens of the nearest theme', (tester) async {
      late TesskraTokens outer;
      late TesskraTokens inner;
      await tester.pumpWidget(
        MaterialApp(
          theme: TesskraTheme.public,
          home: Builder(
            builder: (context) {
              outer = TesskraTokens.of(context);
              return Theme(
                data: TesskraTheme.private,
                child: Builder(
                  builder: (context) {
                    inner = TesskraTokens.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(outer.colors, same(TesskraColors.public));
      expect(inner.colors, same(TesskraColors.private));
    });

    testWidgets('of() fails loudly when the extension is missing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(() => TesskraTokens.of(context), throwsStateError);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('lerp snaps instead of blending paper and carbon', () {
      final a = TesskraTheme.public.extension<TesskraTokens>()!;
      final b = TesskraTheme.private.extension<TesskraTokens>()!;
      expect(a.lerp(b, 0.49), same(a));
      expect(a.lerp(b, 0.5), same(b));
      expect(a.lerp(null, 0.9), same(a));
    });
  });

  group('TesskraIcon', () {
    testWidgets('every icon in the set renders at the token size', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TesskraTheme.public,
          home: Wrap(
            children: [
              for (final icon in TesskraIcons.values) TesskraIcon(icon),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TesskraIcon), findsNWidgets(26));
      expect(
        tester.getSize(find.byType(TesskraIcon).first),
        const Size(24, 24),
      );
    });

    testWidgets('is decorative unless a semantic label is given', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: TesskraTheme.public,
          home: const Row(
            children: [
              TesskraIcon(TesskraIcons.lock),
              TesskraIcon(TesskraIcons.settings, semanticLabel: 'settings'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('settings'), findsOneWidget);
      handle.dispose();
    });
  });
}
