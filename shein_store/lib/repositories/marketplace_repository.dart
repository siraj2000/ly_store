import '../models/category_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/seller_order_model.dart';
import '../models/store_model.dart';
import '../models/store_review_model.dart';
import '../models/user_model.dart';

abstract class MarketplaceRepository {
  Future<List<UserModel>> getUsers();
  Future<List<ProductModel>> getProducts();
  Future<List<OrderModel>> getOrders();
  Future<List<SellerOrderModel>> getSellerOrders();
  Future<List<CategoryModel>> getCategories();
  Future<List<StoreModel>> getStores();
  Future<List<StoreReviewModel>> getStoreReviews();
  Future<StoreModel?> getStoreById(String storeId);
  Future<StoreModel?> getStoreBySellerId(String sellerId);
  Future<List<NotificationModel>> getNotificationsForUser(String userId);
  Future<List<StoreReviewModel>> getReviewsByStore(String storeId);
  Future<List<StoreReviewModel>> getReviewsByCustomer(String customerId);
  Future<StoreReviewModel?> getReviewForOrderStore(
    String customerId,
    String orderId,
    String storeId,
  );

  Future<void> saveUser(UserModel user);
  Future<void> saveProduct(ProductModel product);
  Future<void> saveProducts(List<ProductModel> products);
  Future<void> saveOrder(OrderModel order);
  Future<void> saveSellerOrder(SellerOrderModel order);
  Future<void> saveSellerOrders(List<SellerOrderModel> orders);
  Future<void> saveStore(StoreModel store);
  Future<void> saveStores(List<StoreModel> stores);
  Future<void> saveStoreReview(StoreReviewModel review);
  Future<void> deleteStoreReview(String reviewId);
  Future<void> recalculateStoreRating(String storeId);
  Future<void> createNotification(NotificationModel notification);
  Future<void> createNotifications(List<NotificationModel> notifications);
  Future<void> markNotificationRead(String notificationId);
  Future<void> markAllNotificationsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<void> clearNotifications(String userId);
  Future<void> deactivateStore(String storeId, {String reason = ''});
  Future<void> reactivateStore(String storeId);
}
