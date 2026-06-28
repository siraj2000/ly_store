import 'dart:async';

import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../services/mock_data_service.dart';

enum AppLanguage { system, english, arabic }

class LanguageController extends ChangeNotifier {
  LanguageController({
    required LocalStorageService localStorageService,
    required MockDataService mockDataService,
  }) : _localStorageService = localStorageService,
       _mockDataService = mockDataService {
    _applyLanguage(_restoreStoredLanguageSync(), persist: false);
    _isInitialized = true;
  }

  static const String _localeStorageKey = 'app_locale';
  static const String _legacyLocaleStorageKey = 'app_language';

  final LocalStorageService _localStorageService;
  final MockDataService _mockDataService;

  AppLanguage _selectedLanguage = AppLanguage.system;
  Locale? _locale;
  bool _isInitialized = false;

  AppLanguage get selectedLanguage => _selectedLanguage;
  Locale? get locale => _locale;
  bool get isArabic => _locale?.languageCode == 'ar';
  bool get isEnglish => _locale?.languageCode == 'en';
  bool get isInitialized => _isInitialized;
  TextDirection directionFor(Locale locale) =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  Future<void> initializeLanguage() async {
    final stored = await _restoreStoredLanguage();
    _applyLanguage(stored, persist: false);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _applyLanguage(language, persist: true);
    notifyListeners();
  }

  Future<void> setArabic() => setLanguage(AppLanguage.arabic);

  Future<void> setEnglish() => setLanguage(AppLanguage.english);

  Future<void> useSystemLanguage() => setLanguage(AppLanguage.system);

  Future<AppLanguage> _restoreStoredLanguage() async {
    final directValue = _localStorageService.getString(_localeStorageKey);
    if (directValue != null && directValue.isNotEmpty) {
      return _languageFromStoredValue(directValue);
    }

    final legacyValue = _localStorageService.getString(_legacyLocaleStorageKey);
    if (legacyValue != null && legacyValue.isNotEmpty) {
      final migrated = _languageFromStoredValue(legacyValue);
      await _localStorageService.saveString(
        _localeStorageKey,
        _storedValueFor(migrated),
      );
      await _localStorageService.remove(_legacyLocaleStorageKey);
      return migrated;
    }

    final preferenceLanguage = _mockDataService.preferences.language;
    return _languageFromStoredValue(preferenceLanguage);
  }

  AppLanguage _restoreStoredLanguageSync() {
    final directValue = _localStorageService.getString(_localeStorageKey);
    if (directValue != null && directValue.isNotEmpty) {
      return _languageFromStoredValue(directValue);
    }

    final legacyValue = _localStorageService.getString(_legacyLocaleStorageKey);
    if (legacyValue != null && legacyValue.isNotEmpty) {
      return _languageFromStoredValue(legacyValue);
    }

    return _languageFromStoredValue(_mockDataService.preferences.language);
  }

  void _applyLanguage(AppLanguage language, {required bool persist}) {
    _selectedLanguage = language;
    _locale = switch (language) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.arabic => const Locale('ar'),
    };
    if (persist) {
      final storedValue = _storedValueFor(language);
      unawaited(
        _localStorageService.saveString(_localeStorageKey, storedValue),
      );
      _mockDataService.preferences = _mockDataService.preferences.copyWith(
        language: storedValue,
      );
    }
  }

  AppLanguage _languageFromStoredValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'ar':
      case 'arabic':
      case 'العربية':
        return AppLanguage.arabic;
      case 'en':
      case 'english':
        return AppLanguage.english;
      default:
        return AppLanguage.system;
    }
  }

  String _storedValueFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => 'system',
      AppLanguage.english => 'en',
      AppLanguage.arabic => 'ar',
    };
  }
}
