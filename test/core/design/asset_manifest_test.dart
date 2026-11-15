// Content validation for the design package: every asset the manifest lists
// exists with the recorded size, and everything the app bundles is a real,
// manifest-listed, shippable file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';

void main() {
  final manifest = jsonDecode(
    File('docs/design/ASSET_MANIFEST.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final assets = (manifest['assets'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final byPath = {for (final a in assets) a['path'] as String: a};

  Iterable<String> filesOnDisk() =>
      Directory('docs/design/assets')
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'));

  test('manifest lists exactly the files on disk, with matching sizes', () {
    expect(byPath.keys.toSet(), filesOnDisk().toSet());
    for (final asset in assets) {
      final path = asset['path'] as String;
      expect(File(path).lengthSync(), asset['bytes'], reason: path);
    }
  });

  test('the package still contains the 43 audited assets', () {
    expect(assets, hasLength(43));
  });

  test('TesskraIcons covers every manifest icon and nothing else', () {
    final manifestIcons = {
      for (final a in assets)
        if (a['type'] == 'icon') a['path'] as String,
    };
    final enumIcons = {for (final i in TesskraIcons.values) i.assetPath};
    expect(enumIcons, manifestIcons);
  });

  test('bundled logos and licences are manifest assets that may ship', () {
    for (final path in [...TesskraLogos.all, ...TesskraLicenseFiles.all]) {
      final entry = byPath[path];
      expect(entry, isNotNull, reason: '$path is not in the manifest');
      expect(entry!['status'], isNot('preview'), reason: path);
    }
  });

  test('pubspec bundles only existing, non-preview design files', () {
    // Comment lines may mention paths; only real entries count.
    final pubspec = File('pubspec.yaml')
        .readAsLinesSync()
        .where((line) => !line.trimLeft().startsWith('#'))
        .join(' ');
    final referenced = RegExp(r'''(docs/design/assets/[^\s"']+)''')
        .allMatches(pubspec)
        .map((m) => m.group(1)!)
        .toSet();
    expect(referenced, isNotEmpty);

    for (final ref in referenced) {
      if (ref.endsWith('/')) {
        expect(Directory(ref).existsSync(), isTrue, reason: ref);
        final shipped = byPath.keys.where((p) => p.startsWith(ref));
        for (final path in shipped) {
          expect(byPath[path]!['status'], isNot('preview'), reason: path);
        }
      } else {
        expect(byPath, contains(ref), reason: '$ref is not in the manifest');
        expect(byPath[ref]!['status'], isNot('preview'), reason: ref);
      }
    }

    // Both font licences and the icon licence must be inside the bundle.
    for (final licence in TesskraLicenseFiles.all) {
      expect(
        referenced.any((r) => r == licence || licence.startsWith(r)),
        isTrue,
        reason: '$licence is not bundled',
      );
    }
  });

  test('every font file named in typography.json is bundled', () {
    final typography = jsonDecode(
      File('docs/design/tokens/typography.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final families = typography['families'] as Map<String, dynamic>;
    final display = families['display'] as Map<String, dynamic>;
    final text = families['text'] as Map<String, dynamic>;
    final fontFiles = [
      ...(display['files'] as List<dynamic>).cast<String>(),
      ...(text['files'] as Map<String, dynamic>).values.cast<String>(),
    ];
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final font in fontFiles) {
      expect(File(font).existsSync(), isTrue, reason: font);
      expect(pubspec, contains(font), reason: '$font missing from pubspec');
    }
  });
}
