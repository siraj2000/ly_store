import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/controllers/product_controller.dart';
import 'package:stylehub_store/models/review_model.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<
    ({
      MockDataService mockData,
      ProductController products,
      AuthController auth,
    })
  >
  buildControllers() async {
    SharedPreferences.setMockInitialValues({});
    final localStorage = await LocalStorageService.create();
    final mockData = await MockDataService.create(
      localStorageService: localStorage,
    );
    final auth = AuthController(authService: AuthService(mockData));
    final products = ProductController(
      productService: ProductService(mockData),
      mockDataService: mockData,
    )..products = mockData.products;
    products.bind(authController: auth);
    return (mockData: mockData, products: products, auth: auth);
  }

  test('reviewsForProduct returns only reviews for that product', () async {
    final (:mockData, :products, :auth) = await buildControllers();
    auth.replaceUser(mockData.userById('customer_1')!);
    products.bind(authController: auth);

    final deliveredOrder = mockData
        .ordersForCustomer('customer_1')
        .firstWhere((order) => order.status == 'Delivered');
    final productId = deliveredOrder.items.first.product.id;

    final existing = products.currentCustomerReviewForProduct(productId);
    if (existing != null) {
      final result = await products.saveProductReview(
        productId: productId,
        rating: 5,
        comment: 'Excellent delivered product.',
        existingReview: existing,
      );
      expect(result.success, isTrue);
    }
    expect(
      products
          .reviewsForProduct(productId)
          .every((review) => review.productId == productId),
      isTrue,
    );
  });

  test('guest and non-purchasing customer cannot submit a review', () async {
    final (:mockData, :products, :auth) = await buildControllers();
    final productId = mockData.products.first.id;

    expect(
      products.reviewEligibilityForProduct(productId).reason,
      ReviewEligibilityReason.notLoggedIn,
    );

    auth.replaceUser(mockData.userById('customer_1')!);
    products.bind(authController: auth);
    final orderedIds = mockData
        .ordersForCustomer('customer_1')
        .expand((order) => order.items.map((item) => item.product.id))
        .toSet();
    final notPurchased = mockData.products.firstWhere(
      (product) => !orderedIds.contains(product.id),
    );

    expect(
      products.reviewEligibilityForProduct(notPurchased.id).reason,
      ReviewEligibilityReason.notPurchased,
    );
  });

  test(
    'delivered purchase can create one review and update rating summary',
    () async {
      final (:mockData, :products, :auth) = await buildControllers();
      auth.replaceUser(mockData.userById('customer_1')!);
      products.bind(authController: auth);

      final reviewOrder = mockData
          .ordersForCustomer('customer_1')
          .firstWhere((order) => order.status == 'Delivered');
      final productId = reviewOrder.items.first.product.id;
      final existing = products.currentCustomerReviewForProduct(productId);
      if (existing != null) {
        final editResult = await products.saveProductReview(
          productId: productId,
          rating: 5,
          comment: 'Updated review after delivery.',
          existingReview: existing,
        );
        expect(editResult.success, isTrue);
      } else {
        final eligibility = products.reviewEligibilityForProduct(productId);
        expect(eligibility.canReview, isTrue);
        final result = await products.saveProductReview(
          productId: productId,
          rating: 5,
          comment: 'Great quality after delivery.',
        );
        expect(result.success, isTrue);
      }

      final summary = products.ratingSummaryForProduct(productId);
      expect(summary.reviewCount, greaterThanOrEqualTo(1));
      expect(summary.averageRating, greaterThan(0));
    },
  );

  test('paid active order is enough to show review eligibility', () async {
    final (:mockData, :products, :auth) = await buildControllers();
    auth.replaceUser(mockData.userById('customer_1')!);
    products.bind(authController: auth);

    final processingOrder = mockData
        .ordersForCustomer('customer_1')
        .firstWhere((order) => order.status == 'Processing');
    final productId = processingOrder.items.first.product.id;
    final eligibility = products.reviewEligibilityForProduct(productId);

    expect(eligibility.canReview, isTrue);
    expect(eligibility.eligibleOrderId, processingOrder.id);
  });

  test('unpaid order product is not eligible for review', () async {
    final (:mockData, :products, :auth) = await buildControllers();
    auth.replaceUser(mockData.userById('customer_1')!);
    products.bind(authController: auth);

    final unpaidOrder = mockData
        .ordersForCustomer('customer_1')
        .firstWhere((order) => order.status == 'Unpaid');
    final productId = unpaidOrder.items.first.product.id;

    expect(
      products.reviewEligibilityForProduct(productId).reason,
      ReviewEligibilityReason.paymentNotCompleted,
    );
    expect(
      (await products.saveProductReview(
        productId: productId,
        rating: 5,
        comment: 'Should not be accepted yet.',
      )).success,
      isFalse,
    );
  });

  test('seller direct submit is rejected', () async {
    final (:mockData, :products, :auth) = await buildControllers();
    auth.replaceUser(mockData.sellers.first);
    products.bind(authController: auth);

    final productId = mockData.products.first.id;
    final result = await products.saveProductReview(
      productId: productId,
      rating: 5,
      comment: 'Seller should not be able to review as customer.',
    );

    expect(result.success, isFalse);
    expect(
      products.reviewEligibilityForProduct(productId).reason,
      ReviewEligibilityReason.notCustomer,
    );
  });

  test(
    'duplicate product review is prevented unless editing existing review',
    () async {
      final (:mockData, :products, :auth) = await buildControllers();
      auth.replaceUser(mockData.userById('customer_1')!);
      products.bind(authController: auth);

      final reviewOrder = mockData
          .ordersForCustomer('customer_1')
          .firstWhere((order) => order.status == 'Delivered');
      final productId = reviewOrder.items.first.product.id;
      final firstReview = products.currentCustomerReviewForProduct(productId);

      if (firstReview == null) {
        final result = await products.saveProductReview(
          productId: productId,
          rating: 4,
          comment: 'First review for duplicate check.',
        );
        expect(result.success, isTrue);
      }

      final duplicate = await products.saveProductReview(
        productId: productId,
        rating: 3,
        comment: 'Trying to submit duplicate review.',
      );
      expect(duplicate.success, isFalse);
      expect(
        products.reviewEligibilityForProduct(productId).reason,
        ReviewEligibilityReason.alreadyReviewed,
      );
    },
  );
}
