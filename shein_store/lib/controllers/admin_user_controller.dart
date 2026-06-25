import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class AdminUserController extends ChangeNotifier {
  AdminUserController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;

  List<UserModel> get customers => _mockDataService.customers;

  void toggleActive(UserModel user) {
    _mockDataService.updateUser(user.copyWith(isActive: !user.isActive));
    notifyListeners();
  }
}
