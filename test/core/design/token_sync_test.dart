// Guards the contract in ADR-0004: the JSON files under docs/design/tokens are
// the source of truth and the hand-written Dart constants must match them.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_colors.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_palette.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';

Map<String, dynamic> _tokens(String name) {
  final file = File('docs/design/tokens/$name.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Color _hex(String hex) =>
    Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// Drops `$description` and `usage` style documentation keys.
Map<String, dynamic> _values(Map<String, dynamic> group) =>
    Map.of(group)..removeWhere((k, _) => k.startsWith(r'$') || k == 'usage');

void main() {
  final colors = _tokens('colors');
  final paletteJson = _values(colors['palette'] as Map<String, dynamic>);

  Color resolve(Object? token) {
    if (token is Map<String, dynamic>) {
      final base = resolve(token['color']);
      return base.withValues(alpha: (token['alpha'] as num).toDouble());
    }
    final ref = token! as String;
    final match = RegExp(r'^\{palette\.(\w+)\}$').firstMatch(ref);
    expect(match, isNotNull, reason: 'Unsupported colour reference $ref');
    return _hex(paletteJson[match!.group(1)] as String);
  }

  void expectSameColor(Color? actual, Color expected, String name) {
    expect(actual, isNotNull, reason: '$name is missing in Dart');
    expect(actual!.toARGB32(), expected.toARGB32(), reason: name);
  }

  group('colors.json', () {
    test('palette matches TesskraPalette', () {
      const dart = <String, Color>{
        'paper': TesskraPalette.paper,
        'paperRaised': TesskraPalette.paperRaised,
        'paperSunken': TesskraPalette.paperSunken,
        'paperEdge': TesskraPalette.paperEdge,
        'ink': TesskraPalette.ink,
        'inkMuted': TesskraPalette.inkMuted,
        'inkDisabled': TesskraPalette.inkDisabled,
        'stamp': TesskraPalette.stamp,
        'stampPressed': TesskraPalette.stampPressed,
        'stampText': TesskraPalette.stampText,
        'mustard': TesskraPalette.mustard,
        'mustardPressed': TesskraPalette.mustardPressed,
        'mustardText': TesskraPalette.mustardText,
        'bottle': TesskraPalette.bottle,
        'blueInk': TesskraPalette.blueInk,
        'carbon': TesskraPalette.carbon,
        'carbonRaised': TesskraPalette.carbonRaised,
        'carbonOutline': TesskraPalette.carbonOutline,
        'carbonMuted': TesskraPalette.carbonMuted,
        'coralLight': TesskraPalette.coralLight,
        'mintLight': TesskraPalette.mintLight,
        'shadowDeep': TesskraPalette.shadowDeep,
      };
      expect(dart.keys.toSet(), paletteJson.keys.toSet());
      for (final entry in dart.entries) {
        expectSameColor(
          entry.value,
          _hex(paletteJson[entry.key] as String),
          entry.key,
        );
      }
    });

    Map<String, Color?> semantic(TesskraColors c) => {
      'background': c.background,
      'surface': c.surface,
      'surfaceSunken': c.surfaceSunken,
      'textPrimary': c.textPrimary,
      'textSecondary': c.textSecondary,
      'textDisabled': c.textDisabled,
      'border': c.border,
      'borderSubtle': c.borderSubtle,
      'borderStrong': c.borderStrong,
      'primary': c.primary,
      'primaryPressed': c.primaryPressed,
      'onPrimary': c.onPrimary,
      'accent': c.accent,
      'accentPressed': c.accentPressed,
      'onAccent': c.onAccent,
      'success': c.success,
      'onSuccess': c.onSuccess,
      'warning': c.warning,
      'warningText': c.warningText,
      'error': c.error,
      'errorText': c.errorText,
      'focusRing': c.focusRing,
      'shadow': c.shadow,
      'scrim': c.scrim,
      'ticket': c.ticket,
      'onTicket': c.onTicket,
    };

    for (final (name, dartColors) in [
      ('public', TesskraColors.public),
      ('private', TesskraColors.private),
    ]) {
      test('$name theme matches TesskraColors.$name exactly', () {
        final json = _values(colors[name] as Map<String, dynamic>);
        final dart = semantic(dartColors);
        expect(
          json.keys.toSet().difference(dart.keys.toSet()),
          isEmpty,
          reason: 'Token roles with no Dart field',
        );
        for (final entry in dart.entries) {
          if (json.containsKey(entry.key)) {
            expectSameColor(entry.value, resolve(json[entry.key]), entry.key);
          } else {
            expect(
              entry.value,
              isNull,
              reason:
                  '${entry.key} is not defined for $name in colors.json; '
                  'Dart must not invent it',
            );
          }
        }
      });
    }

    test('role colours match TesskraRoleColors', () {
      final json = _values(colors['role'] as Map<String, dynamic>);
      const dart = <String, Color>{
        'civilian': TesskraRoleColors.civilian,
        'onCivilian': TesskraRoleColors.onCivilian,
        'impostor': TesskraRoleColors.impostor,
        'onImpostor': TesskraRoleColors.onImpostor,
      };
      expect(dart.keys.toSet(), json.keys.toSet());
      for (final entry in dart.entries) {
        expectSameColor(entry.value, resolve(json[entry.key]), entry.key);
      }
    });
  });

  void expectNumbers(
    Map<String, double> dart,
    Map<String, dynamic> json,
    String label,
  ) {
    expect(dart.keys.toSet(), json.keys.toSet(), reason: '$label keys');
    for (final entry in dart.entries) {
      expect(entry.value, json[entry.key], reason: '$label.${entry.key}');
    }
  }

  group('spacing.json and radii.json', () {
    final spacing = _tokens('spacing');

    test('scale', () {
      expectNumbers(
        const {
          '0': TesskraSpacing.s0,
          '1': TesskraSpacing.s1,
          '2': TesskraSpacing.s2,
          '3': TesskraSpacing.s3,
          '4': TesskraSpacing.s4,
          '5': TesskraSpacing.s5,
          '6': TesskraSpacing.s6,
          '8': TesskraSpacing.s8,
          '10': TesskraSpacing.s10,
          '12': TesskraSpacing.s12,
          '16': TesskraSpacing.s16,
        },
        spacing['scale'] as Map<String, dynamic>,
        'scale',
      );
    });

    test('layout', () {
      expectNumbers(
        const {
          'screenMarginH': TesskraLayout.screenMarginH,
          'screenMarginHCompact': TesskraLayout.screenMarginHCompact,
          'compactBreakpointWidth': TesskraLayout.compactBreakpointWidth,
          'screenPaddingTop': TesskraLayout.screenPaddingTop,
          'screenPaddingBottom': TesskraLayout.screenPaddingBottom,
          'sectionGap': TesskraLayout.sectionGap,
          'itemGap': TesskraLayout.itemGap,
          'cardPadding': TesskraLayout.cardPadding,
          'cardPaddingLarge': TesskraLayout.cardPaddingLarge,
          'ticketPadding': TesskraLayout.ticketPadding,
          'dialogPadding': TesskraLayout.dialogPadding,
          'maxContentWidth': TesskraLayout.maxContentWidth,
        },
        spacing['layout'] as Map<String, dynamic>,
        'layout',
      );
    });

    test('sizes', () {
      expectNumbers(
        const {
          'touchTargetMin': TesskraSizes.touchTargetMin,
          'buttonPrimaryHeight': TesskraSizes.buttonPrimaryHeight,
          'buttonSecondaryHeight': TesskraSizes.buttonSecondaryHeight,
          'buttonCompactHeight': TesskraSizes.buttonCompactHeight,
          'iconButton': TesskraSizes.iconButton,
          'icon': TesskraSizes.icon,
          'iconSmall': TesskraSizes.iconSmall,
          'inputHeight': TesskraSizes.inputHeight,
          'playerRowHeight': TesskraSizes.playerRowHeight,
          'voteOptionHeight': TesskraSizes.voteOptionHeight,
          'appBarHeight': TesskraSizes.appBarHeight,
          'badge': TesskraSizes.badge,
          'stampSmall': TesskraSizes.stampSmall,
          'stampLarge': TesskraSizes.stampLarge,
          'ticketNotchDiameter': TesskraSizes.ticketNotchDiameter,
        },
        spacing['sizes'] as Map<String, dynamic>,
        'sizes',
      );
    });

    test('borders', () {
      expectNumbers(
        const {
          'hairline': TesskraBorders.hairline,
          'standard': TesskraBorders.standard,
          'strong': TesskraBorders.strong,
          'dashLength': TesskraBorders.dashLength,
          'dashGap': TesskraBorders.dashGap,
        },
        spacing['borders'] as Map<String, dynamic>,
        'borders',
      );
    });

    test('compact margin applies strictly below the breakpoint', () {
      expect(TesskraLayout.screenMarginFor(359), 16);
      expect(TesskraLayout.screenMarginFor(360), 24);
    });

    test('radii', () {
      expectNumbers(
        const {
          'xs': TesskraRadii.xs,
          'sm': TesskraRadii.sm,
          'md': TesskraRadii.md,
          'lg': TesskraRadii.lg,
          'xl': TesskraRadii.xl,
          'pill': TesskraRadii.pill,
        },
        _values(_tokens('radii')),
        'radii',
      );
    });
  });

  group('shadows.json', () {
    final shadows = _tokens('shadows');

    void expectShadow(BoxShadow dart, String theme, String key) {
      final json =
          (shadows[theme] as Map<String, dynamic>)[key] as Map<String, dynamic>;
      final label = '$theme.$key';
      expect(
        dart.offset,
        Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble()),
        reason: label,
      );
      expect(dart.blurRadius, json['blur'], reason: label);
      expect(json['color'], '{$theme.shadow}', reason: label);
      final themeColors = theme == 'public'
          ? TesskraColors.public
          : TesskraColors.private;
      expect(
        dart.color.toARGB32(),
        themeColors.shadow.toARGB32(),
        reason: label,
      );
    }

    test('every non-empty shadow has a matching Dart constant', () {
      expectShadow(TesskraShadows.publicSm, 'public', 'sm');
      expectShadow(TesskraShadows.publicMd, 'public', 'md');
      expectShadow(TesskraShadows.publicLg, 'public', 'lg');
      expectShadow(TesskraShadows.privateTicket, 'private', 'ticket');
      expect((shadows['public'] as Map<String, dynamic>).keys.toSet(), {
        'none',
        'sm',
        'md',
        'lg',
      });
      expect((shadows['private'] as Map<String, dynamic>).keys.toSet(), {
        'none',
        'ticket',
      });
    });
  });

  group('animations.json', () {
    final animations = _tokens('animations');

    test('durations', () {
      const dart = <String, Duration>{
        'instant': TesskraDurations.instant,
        'fast': TesskraDurations.fast,
        'base': TesskraDurations.base,
        'slow': TesskraDurations.slow,
        'reveal': TesskraDurations.reveal,
        'themeShift': TesskraDurations.themeShift,
        'stagger': TesskraDurations.stagger,
      };
      final json = animations['durations'] as Map<String, dynamic>;
      expect(dart.keys.toSet(), json.keys.toSet());
      for (final entry in dart.entries) {
        expect(entry.value.inMilliseconds, json[entry.key], reason: entry.key);
      }
    });

    test('curves', () {
      const dart = <String, Cubic>{
        'standard': TesskraCurves.standard,
        'enter': TesskraCurves.enter,
        'exit': TesskraCurves.exit,
        'stamp': TesskraCurves.stamp,
        'linear': TesskraCurves.linear,
      };
      final json = animations['curves'] as Map<String, dynamic>;
      expect(dart.keys.toSet(), json.keys.toSet());
      for (final entry in dart.entries) {
        final c = entry.value;
        expect([c.a, c.b, c.c, c.d], json[entry.key], reason: entry.key);
      }
    });
  });

  group('typography.json', () {
    final typography = _tokens('typography');
    final styles = typography['styles'] as Map<String, dynamic>;
    const dart = <String, TextStyle>{
      'displayXL': TesskraTypography.displayXL,
      'displayL': TesskraTypography.displayL,
      'displayM': TesskraTypography.displayM,
      'titleL': TesskraTypography.titleL,
      'titleM': TesskraTypography.titleM,
      'bodyL': TesskraTypography.bodyL,
      'bodyM': TesskraTypography.bodyM,
      'labelL': TesskraTypography.labelL,
      'labelM': TesskraTypography.labelM,
      'caption': TesskraTypography.caption,
      'numericL': TesskraTypography.numericL,
      'numericM': TesskraTypography.numericM,
    };

    test('every style matches family, size, line height and weight', () {
      expect(dart.keys.toSet(), styles.keys.toSet());
      for (final entry in dart.entries) {
        final json = styles[entry.key] as Map<String, dynamic>;
        final style = entry.value;
        final weight = json['fontWeight'] as int;
        expect(style.fontFamily, json['fontFamily'], reason: entry.key);
        expect(style.fontSize, json['fontSize'], reason: entry.key);
        expect(style.height, json['lineHeight'], reason: entry.key);
        expect(style.fontWeight!.value, weight, reason: entry.key);
        expect(style.letterSpacing, 0, reason: entry.key);
        expect(
          style.fontFeatures != null,
          json.containsKey('fontFeatures'),
          reason: '${entry.key} tabular figures',
        );

        // The display family is a variable font: the weight must also be set
        // on the wght axis or Android renders the default instance.
        if (style.fontFamily == TesskraTypography.displayFamily) {
          expect(style.fontVariations, [
            FontVariation('wght', weight.toDouble()),
          ], reason: entry.key);
        }
      }
    });

    test('families, minimum sizes and rules', () {
      final families = typography['families'] as Map<String, dynamic>;
      expect(
        TesskraTypography.displayFamily,
        (families['display'] as Map<String, dynamic>)['name'],
      );
      expect(
        TesskraTypography.textFamily,
        (families['text'] as Map<String, dynamic>)['name'],
      );
      expect(
        TesskraTypography.displayXLMinFontSize,
        (styles['displayXL'] as Map<String, dynamic>)['minFontSize'],
      );
      expect(
        TesskraTypography.displayLMinFontSize,
        (styles['displayL'] as Map<String, dynamic>)['minFontSize'],
      );
      final rules = typography['rules'] as Map<String, dynamic>;
      expect(
        TesskraTypography.maxTextScaleSupported,
        rules['maxTextScaleSupported'],
      );
      final minAny = rules['minAnySize'] as num;
      for (final entry in dart.entries) {
        expect(
          entry.value.fontSize,
          greaterThanOrEqualTo(minAny),
          reason: entry.key,
        );
      }
    });
  });
}
