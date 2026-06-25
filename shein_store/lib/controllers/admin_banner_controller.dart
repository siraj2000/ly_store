import 'package:flutter/material.dart';

import '../services/mock_data_service.dart';

class AdminBannerController extends ChangeNotifier {
  AdminBannerController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;

  List<String> get banners => _mockDataService.promoBanners;
}
