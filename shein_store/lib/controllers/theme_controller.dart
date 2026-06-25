import 'dart:async';

import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';
import '../services/mock_data_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode;
  final LocalStorageService _localStorageService;
  final MockDataService _mockDataService;

  ThemeController({
    required LocalStorageService localStorageService,
    required MockDataService mockDataService,
    ThemeMode initialMode = ThemeMode.system,
  }) : _themeMode = initialMode,
       _localStorageService = localStorageService,
       _mockDataService = mockDataService;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final preferenceValue = toPreferenceValue();
    unawaited(_localStorageService.saveThemeMode(preferenceValue));
    _mockDataService.preferences = _mockDataService.preferences.copyWith(
      themeMode: preferenceValue,
    );
    notifyListeners();
  }

  void setThemeModeFromString(String value) {
    switch (value) {
      case 'light':
        setThemeMode(ThemeMode.light);
        break;
      case 'dark':
        setThemeMode(ThemeMode.dark);
        break;
      default:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  void toggleDarkMode() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
      return;
    }
    setThemeMode(ThemeMode.dark);
  }

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  String toPreferenceValue() {
    return switch (_themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
