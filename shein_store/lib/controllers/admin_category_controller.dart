import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/mock_data_service.dart';

class AdminCategoryController extends ChangeNotifier {
  AdminCategoryController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;

  List<CategoryModel> get categories => _mockDataService.categories;
}
