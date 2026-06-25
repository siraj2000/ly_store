import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  String tr(String english, String arabic) => isArabic ? arabic : english;
}
