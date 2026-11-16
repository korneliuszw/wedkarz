import 'package:flutter/material.dart';
import 'package:nad_parseta/l10n/generated/app_localizations.dart';

extension AppContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
  TextTheme get text => Theme.of(this).textTheme;
}
