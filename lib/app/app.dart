import 'package:flutter/material.dart';
import 'package:impostor_tn/app/app_start.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// Application root: one locale (`ar`, RTL) and the public Tesskra theme.
///
/// Private screens opt into `TesskraTheme.private` locally; it is not the
/// system dark theme, so `darkTheme` is deliberately left unset.
class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  static const locale = Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: TesskraTheme.public,
      home: const AppStart(),
    );
  }
}
