import 'package:flutter/material.dart';

import '../models/store_review_model.dart';
import '../repositories/marketplace_repository.dart';
import '../services/mock_data_service.dart';

class StoreReviewController extends ChangeNotifier {
  StoreReviewController({
    required MarketplaceRepository marketplaceRepository,
    required MockDataService mockDataService,
  }) : _marketplaceRepository = marketplaceRepository,
       _mockDataService = mockDataService;

  final MarketplaceRepository _marketplaceRepository;
  final MockDataService _mockDataService;

  List<StoreReviewModel> reviews = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorCode;

  Future<void> loadStoreReviews(String storeId) async {
    isLoading = true;
    errorCode = null;
    notifyListeners();
    try {
      reviews = await _marketplaceRepository.getReviewsByStore(storeId);
    } catch (_) {
      errorCode = 'load_failed';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool canCustomerRateStore(String customerId, String storeId, String orderId) {
    return _mockDataService.sellerOrders.any(
      (order) =>
          order.customerId == customerId &&
          order.storeId == storeId &&
          order.masterOrderId == orderId &&
          (order.status == 'Delivered' || order.status == 'Review'),
    );
  }

  double calculateAverageRating(String storeId) {
    final items = _mockDataService.reviewsByStore(storeId);
    if (items.isEmpty) {
      return 0;
    }
    return items.fold<double>(0, (sum, item) => sum + item.rating) /
        items.length;
  }

  Future<void> submitStoreReview(StoreReviewModel review) async {
    isSubmitting = true;
    errorCode = null;
    notifyListeners();
    try {
      await _marketplaceRepository.saveStoreReview(review);
      await _marketplaceRepository.recalculateStoreRating(review.storeId);
      reviews = await _marketplaceRepository.getReviewsByStore(review.storeId);
    } catch (_) {
      errorCode = 'submit_failed';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreReview(StoreReviewModel review) async {
    await submitStoreReview(review);
  }

  Future<void> deleteStoreReview(String reviewId, String storeId) async {
    isSubmitting = true;
    errorCode = null;
    notifyListeners();
    try {
      await _marketplaceRepository.deleteStoreReview(reviewId);
      await _marketplaceRepository.recalculateStoreRating(storeId);
      reviews = await _marketplaceRepository.getReviewsByStore(storeId);
    } catch (_) {
      errorCode = 'delete_failed';
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
