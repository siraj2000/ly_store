import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/product_status.dart';
import '../models/notification_model.dart';
import '../models/seller_order_model.dart';
import '../models/store_model.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class SellerDashboardController extends ChangeNotifier {
  SellerDashboardController({required MockDataService mockDataService})
    : _mockDataService = mockDataService {
    _mockDataService.addListener(_handleDataChanged);
  }

  final MockDataService _mockDataService;
  AuthController? _authController;
  String searchQuery = '';
  bool isLoading = false;
  bool isRefreshing = false;
  bool isSearching = false;
  bool isSubmitting = false;
  String? errorMessage;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  Future<void> refresh() async {
    isRefreshing = true;
    errorMessage = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    isRefreshing = false;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    isSearching = value.trim().isNotEmpty;
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    isSearching = false;
    notifyListeners();
  }

  String get sellerId => _authController?.currentUser?.id ?? '';
  StoreModel? get currentStore {
    final currentUser = _authController?.currentUser;
    if (currentUser == null) {
      return null;
    }
    return _mockDataService.storeById(currentUser.linkedStoreId) ??
        _mockDataService.storeBySellerId(currentUser.id);
  }

  String get sellerName =>
      currentStore?.nameText.en ??
      _authController?.currentUser?.name ??
      'Seller';
  String get storePhone =>
      currentStore?.storePhone ?? _authController?.currentUser?.phone ?? '';
  String get storeAddress => currentStore?.addressText.en ?? '';
  String get businessActivityType => currentStore?.businessActivityType ?? '';
  String get sellerStatus => _authController?.currentUser?.sellerStatus ?? '';
  bool get storeVacationMode =>
      currentStore?.vacationMode ??
      (_authController?.currentUser?.sellerVacationMode ?? false);
  bool get storeIsSuspended =>
      sellerStatus == 'suspended' || currentStore?.suspendedAt != null;
  bool get storeIsActive =>
      !storeIsSuspended &&
      !storeVacationMode &&
      (currentStore?.isActive ??
          (_authController?.currentUser?.isSellerAccountActive ?? false));
  String get storeStatusId {
    if (storeIsSuspended) return 'suspended';
    if (storeVacationMode) return 'vacation';
    return storeIsActive ? 'active' : 'inactive';
  }

  List<ProductModel> get sellerProducts =>
      _mockDataService.productsForSeller(sellerId);

  List<SellerOrderModel> get sellerOrders =>
      _mockDataService.sellerOrdersForSeller(sellerId);

  List<NotificationModel> get sellerNotifications =>
      _mockDataService.notificationsForUser(sellerId);

  List<ProductModel> get filteredProducts {
    final query = _normalizedSearchQuery;
    final items = [...sellerProducts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (query.isEmpty) {
      return items;
    }
    return items.where((product) {
      final haystack = [
        product.title,
        product.titleText.en,
        product.titleText.ar,
        product.sku,
        product.categoryName,
        product.department,
        product.subcategoryName,
      ].join(' ');
      return _normalize(haystack).contains(query);
    }).toList();
  }

  List<SellerOrderModel> get filteredOrders {
    final query = _normalizedSearchQuery;
    final items = [...sellerOrders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (query.isEmpty) {
      return items;
    }
    return items.where((order) {
      final haystack = [
        order.id,
        order.masterOrderId,
        order.customerName,
        order.status,
        order.paymentStatus,
        order.shippingStatus,
        order.trackingNumber,
        ...order.items.map((item) => item.product.title),
      ].join(' ');
      return _normalize(haystack).contains(query);
    }).toList();
  }

  List<NotificationModel> get filteredNotifications {
    final query = _normalizedSearchQuery;
    final items = [...sellerNotifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (query.isEmpty) {
      return items;
    }
    return items.where((notification) {
      final haystack = [
        notification.legacyTitle ?? '',
        notification.legacyMessage ?? '',
        notification.entityType,
        notification.entityId,
        notification.type.id,
        notification.data.values.join(' '),
      ].join(' ');
      return _normalize(haystack).contains(query);
    }).toList();
  }

  double get totalSales =>
      sellerOrders.fold(0, (sum, order) => sum + order.sellerNetAmount);

  double get pendingEarnings => sellerOrders
      .where((order) => order.paymentStatus.toLowerCase() != 'paid')
      .fold(0, (sum, order) => sum + order.sellerNetAmount);

  double get earningsThisMonth {
    final now = DateTime.now();
    return sellerOrders
        .where(
          (order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month,
        )
        .fold(0, (sum, order) => sum + order.sellerNetAmount);
  }

  double? get earningsLastWeekChangePercent {
    final now = DateTime.now();
    final currentStart = now.subtract(const Duration(days: 7));
    final previousStart = now.subtract(const Duration(days: 14));
    final current = sellerOrders
        .where((order) => order.createdAt.isAfter(currentStart))
        .fold(0.0, (sum, order) => sum + order.sellerNetAmount);
    final previous = sellerOrders
        .where(
          (order) =>
              order.createdAt.isAfter(previousStart) &&
              !order.createdAt.isAfter(currentStart),
        )
        .fold(0.0, (sum, order) => sum + order.sellerNetAmount);
    if (previous <= 0) {
      return current > 0 ? null : 0;
    }
    return ((current - previous) / previous) * 100;
  }

  double get averageOrderValue =>
      sellerOrders.isEmpty ? 0 : totalSales / sellerOrders.length;

  double get todaySales {
    final now = DateTime.now();
    return sellerOrders
        .where(
          (order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month &&
              order.createdAt.day == now.day,
        )
        .fold(0, (sum, order) => sum + order.sellerNetAmount);
  }

  double get sales7Days => _salesSince(const Duration(days: 7));
  double get sales30Days => _salesSince(const Duration(days: 30));

  List<double> get revenueChartPoints {
    final now = DateTime.now();
    return List<double>.generate(30, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 29 - index));
      return sellerOrders
          .where(
            (order) =>
                order.createdAt.year == day.year &&
                order.createdAt.month == day.month &&
                order.createdAt.day == day.day,
          )
          .fold(0, (sum, order) => sum + order.sellerNetAmount);
    });
  }

  int countByStatus(String status) =>
      sellerOrders.where((order) => order.status == status).length;

  int countByAnyStatus(Set<String> statuses) =>
      sellerOrders.where((order) => statuses.contains(order.status)).length;

  int get newOrders => countByAnyStatus({'Pending', 'Unpaid', 'New'});
  int get processingOrders => countByStatus('Processing');
  int get readyToShipOrders => countByStatus('Ready to Ship');
  int get shippedOrders => countByStatus('Shipped');
  int get deliveredOrders => countByStatus('Delivered');
  int get returnOrRefundOrders => countByAnyStatus({'Returned', 'Refunded'});

  List<SellerOrderModel> get openOrders => sellerOrders
      .where(
        (order) => {
          'Pending',
          'Unpaid',
          'New',
          'Processing',
          'Ready to Ship',
        }.contains(order.status),
      )
      .toList();

  int get lowStockProducts =>
      sellerProducts.where((product) => product.stock <= 5).length;

  List<ProductModel> get lowStockProductItems => sellerProducts
      .where((product) => product.stock <= product.lowStockThreshold)
      .toList();

  int get totalProductViews =>
      sellerProducts.fold(0, (sum, product) => sum + product.views);

  double? get conversionRate {
    if (totalProductViews <= 0) {
      return null;
    }
    return sellerOrders.length / totalProductViews;
  }

  int get activeProducts =>
      sellerProducts.where((product) => product.isActive).length;

  int get pendingApprovalProducts => sellerProducts
      .where((product) => product.status == ProductStatus.pendingApproval)
      .length;

  int get draftProducts => sellerProducts
      .where((product) => product.status == ProductStatus.draft)
      .length;

  int get rejectedProducts => sellerProducts
      .where((product) => product.status == ProductStatus.rejected)
      .length;

  int get outOfStockProducts =>
      sellerProducts.where((product) => product.stock <= 0).length;

  int get unreadNotifications => _mockDataService
      .notificationsForUser(sellerId)
      .where((item) => !item.isRead)
      .length;

  List<NotificationModel> get latestNotifications =>
      filteredNotifications.take(3).toList();

  List<ProductModel> get bestSellingProducts {
    final items = [...sellerProducts];
    items.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return items.take(5).toList();
  }

  List<ProductModel> get dashboardProducts => filteredProducts.take(4).toList();

  String get _normalizedSearchQuery => _normalize(searchQuery);

  double _salesSince(Duration duration) {
    final start = DateTime.now().subtract(duration);
    return sellerOrders
        .where((order) => order.createdAt.isAfter(start))
        .fold(0, (sum, order) => sum + order.sellerNetAmount);
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .trim();

  void _handleDataChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _mockDataService.removeListener(_handleDataChanged);
    super.dispose();
  }
}
