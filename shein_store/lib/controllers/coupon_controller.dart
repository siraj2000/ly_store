import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class CouponController extends ChangeNotifier {
  CouponController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  AuthController? _authController;
  List<CouponModel> get allCoupons =>
      _authController?.currentUser?.coupons ?? _mockDataService.coupons;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }
}
