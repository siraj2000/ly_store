import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/user_role.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class AdminProductApprovalController extends ChangeNotifier {
  AdminProductApprovalController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  AuthController? _authController;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  bool get _isAdmin => _authController?.currentRole == UserRole.admin;

  List<ProductModel> get pendingProducts =>
      _isAdmin ? _mockDataService.pendingProducts() : [];
  List<ProductModel> get allProducts =>
      _isAdmin ? _mockDataService.allProducts : [];

  void approveProduct(String productId) {
    if (!_isAdmin) return;
    _mockDataService.approveProduct(productId);
    notifyListeners();
  }

  void rejectProduct(String productId) {
    if (!_isAdmin) return;
    _mockDataService.rejectProduct(productId);
    notifyListeners();
  }

  void removeProduct(String productId) {
    if (!_isAdmin) return;
    _mockDataService.deleteProduct(productId);
    notifyListeners();
  }
}
