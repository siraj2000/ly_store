import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/mock_data_service.dart';

class CategoryController extends ChangeNotifier {
  CategoryController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  List<CategoryModel> categories = [];
  int selectedIndex = 0;

  void loadCategories() {
    categories =
        _mockDataService.categories.where((item) => item.isActive).toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    notifyListeners();
  }

  void selectCategory(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void selectCategoryById(String categoryId) {
    final index = categories.indexWhere((item) => item.id == categoryId);
    if (index >= 0) {
      selectCategory(index);
    }
  }

  CategoryModel? get selectedCategory {
    if (categories.isEmpty) return null;
    final safeIndex = selectedIndex.clamp(0, categories.length - 1);
    return categories[safeIndex];
  }

  CategoryModel? categoryById(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  List<CategoryModel> categoriesForHomePreview() =>
      List<CategoryModel>.from(categories);

  List<CategoryModel> categoriesForDepartment(String departmentId) {
    final normalized = departmentId.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') {
      return List<CategoryModel>.from(categories);
    }
    return categories.where((item) {
      final categoryId = item.id.toLowerCase();
      final parentId = item.parentCategoryId?.toLowerCase();
      final itemDepartment = item.departmentId.toLowerCase();
      if (itemDepartment == normalized) {
        return true;
      }
      switch (normalized) {
        case 'women':
          return {
            'women',
            'dresses',
            'tops',
            'beauty',
            'bags',
            'shoes',
            'jewelry',
          }.contains(categoryId);
        case 'men':
          return {'men', 'men-trends', 'shoes', 'bags'}.contains(categoryId);
        case 'kids':
          return {'kids', 'sleepwear'}.contains(categoryId);
        case 'curve':
          return {'curve', 'sleepwear', 'shoes', 'beauty'}.contains(categoryId);
        case 'home':
          return {
            'home',
            'house',
            'kitchen',
            'electronics',
          }.contains(categoryId);
        default:
          return parentId == normalized;
      }
    }).toList();
  }
}
