import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/app/app.dart';
import 'package:impostor_tn/app/app_licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();
  runApp(const ProviderScope(child: ImpostorApp()));
}
