import 'dart:io';

import 'package:flutter/services.dart';
import 'package:impostor_tn/game/privacy/screen_protection.dart';

/// The app's own platform channel, handled in `MainActivity.kt`
/// (ADR-0003, ADR-0006).
abstract final class AppPlatform {
  static const channel = MethodChannel('impostor_tn/platform');

  /// App-private storage that Android also excludes from backups
  /// (`Context.getNoBackupFilesDir()`, D-17).
  static Future<Directory> privateFilesDirectory() async {
    final path = await channel.invokeMethod<String>('privateFilesDirectory');
    if (path == null || path.isEmpty) {
      throw const FileSystemException('No private files directory');
    }
    return Directory(path);
  }
}

/// [ScreenProtection] through `FLAG_SECURE` (ADR-0006, D-18).
final class PlatformScreenProtection implements ScreenProtection {
  const PlatformScreenProtection();

  @override
  Future<bool> setProtected({required bool on}) async {
    try {
      await AppPlatform.channel.invokeMethod<void>('setSecure', on);
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
