import '../models/category_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/seller_order_model.dart';
import '../models/store_model.dart';
import '../models/store_review_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import 'marketplace_repository.dart';

// Local repository is used for demo only. Replace with secure backend API repository for production and multi-device synchronization.
class LocalMarketplaceRepository implements MarketplaceRepository {
  LocalMarketplaceRepository({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _mockDataService.categories;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return _mockDataService.platformOrders;
  }

  @override
  Future<List<SellerOrderModel>> getSellerOrders() async {
    return _mockDataService.sellerOrders;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    return _mockDataService.allProducts;
  }

  @override
  Future<StoreModel?> getStoreById(String storeId) async {
    return _mockDataService.storeById(storeId);
  }

  @override
  Future<StoreModel?> getStoreBySellerId(String sellerId) async {
    return _mockDataService.storeBySellerId(sellerId);
  }

  @override
  Future<List<StoreModel>> getStores() async {
    return _mockDataService.stores;
  }

  @override
  Future<List<StoreReviewModel>> getStoreReviews() async {
    return _mockDataService.storeReviews;
  }

  @override
  Future<List<UserModel>> getUsers() async {
    return _mockDataService.allUsers;
  }

  @override
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    return _mockDataService.notificationsForUser(userId);
  }

  @override
  Future<List<StoreReviewModel>> getReviewsByStore(String storeId) async {
    return _mockDataService.reviewsByStore(storeId);
  }

  @override
  Future<List<StoreReviewModel>> getReviewsByCustomer(String customerId) async {
    return _mockDataService.reviewsByCustomer(customerId);
  }

  @override
  Future<StoreReviewModel?> getReviewForOrderStore(
    String customerId,
    String orderId,
    String storeId,
  ) async {
    return _mockDataService.getReviewForOrderStore(
      customerId,
      orderId,
      storeId,
    );
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    _mockDataService.updateOrder(order);
  }

  @override
  Future<void> saveSellerOrder(SellerOrderModel order) async {
    _mockDataService.updateSellerOrder(order);
  }

  @override
  Future<void> saveSellerOrders(List<SellerOrderModel> orders) async {
    _mockDataService.saveSellerOrders(orders);
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    _mockDataService.addOrUpdateProduct(product);
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    _mockDataService.saveProducts(products);
  }

  @override
  Future<void> saveStore(StoreModel store) async {
    _mockDataService.addOrUpdateStore(store);
  }

  @override
  Future<void> saveStores(List<StoreModel> stores) async {
    _mockDataService.saveStores(stores);
  }

  @override
  Future<void> saveStoreReview(StoreReviewModel review) async {
    _mockDataService.saveStoreReview(review);
  }

  @override
  Future<void> deleteStoreReview(String reviewId) async {
    _mockDataService.deleteStoreReview(reviewId);
  }

  @override
  Future<void> recalculateStoreRating(String storeId) async {
    _mockDataService.recalculateStoreRating(storeId);
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    _mockDataService.createNotification(notification);
  }

  @override
  Future<void> createNotifications(
    List<NotificationModel> notifications,
  ) async {
    _mockDataService.createNotifications(notifications);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    _mockDataService.markNotificationRead(notificationId);
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    _mockDataService.markAllNotificationsRead(userId);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _mockDataService.deleteNotification(notificationId);
  }

  @override
  Future<void> clearNotifications(String userId) async {
    _mockDataService.clearNotifications(userId);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _mockDataService.updateUser(user);
  }

  @override
  Future<void> deactivateStore(String storeId, {String reason = ''}) async {
    _mockDataService.deactivateStore(storeId, reason: reason);
  }

  @override
  Future<void> reactivateStore(String storeId) async {
    _mockDataService.reactivateStore(storeId);
  }
}
