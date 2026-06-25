import 'package:flutter/material.dart';

import '../models/app_preferences_model.dart';
import '../services/mock_data_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  late AppPreferencesModel preferences;

  void load() {
    preferences = _mockDataService.preferences;
    notifyListeners();
  }

  void changeCountry(String value) {
    preferences = preferences.copyWith(country: value);
    _sync();
  }

  void changeCurrency(String value) {
    preferences = preferences.copyWith(currency: value);
    _sync();
  }

  void changeTheme(String value) {
    preferences = preferences.copyWith(themeMode: value);
    _sync();
  }

  void toggleNotifications(bool enabled) {
    preferences = preferences.copyWith(notificationsEnabled: enabled);
    _sync();
  }

  void _sync() {
    _mockDataService.preferences = preferences;
    notifyListeners();
  }
}
