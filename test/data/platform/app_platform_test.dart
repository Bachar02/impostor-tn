import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/platform/app_platform.dart';

/// The Dart side of the app's channel. The Android side (MainActivity.kt)
/// is not exercised here and has not been verified on a device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  void answer(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(AppPlatform.channel, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  tearDown(() {
    calls.clear();
    messenger.setMockMethodCallHandler(AppPlatform.channel, null);
  });

  test('protection on and off send setSecure with the flag', () async {
    answer((_) => null);

    expect(
      await const PlatformScreenProtection().setProtected(on: true),
      isTrue,
    );
    expect(
      await const PlatformScreenProtection().setProtected(on: false),
      isTrue,
    );

    expect(calls.map((c) => (c.method, c.arguments)), [
      ('setSecure', true),
      ('setSecure', false),
    ]);
  });

  test('a platform failure is reported as false, not thrown', () async {
    answer((_) => throw PlatformException(code: 'bad_argument'));

    expect(
      await const PlatformScreenProtection().setProtected(on: true),
      isFalse,
    );
  });

  test('the private directory comes from the platform', () async {
    answer((_) => '/data/user/0/app/no_backup');

    expect(
      (await AppPlatform.privateFilesDirectory()).path,
      '/data/user/0/app/no_backup',
    );
  });

  test('a missing directory is an error, never a guessed path', () async {
    answer((_) => null);

    expect(AppPlatform.privateFilesDirectory(), throwsA(isA<Exception>()));
  });
}
