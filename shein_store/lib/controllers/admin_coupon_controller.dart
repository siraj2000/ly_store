import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../services/mock_data_service.dart';

class AdminCouponController extends ChangeNotifier {
  AdminCouponController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;

  List<CouponModel> get coupons => _mockDataService.coupons;
}
