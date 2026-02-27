import 'package:habitstack/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Global localization instance
late AppLocalizations t;

const localizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

String onGenerateTitle(context) {
  t = AppLocalizations.of(context)!;
  return t.appTitle;
}
