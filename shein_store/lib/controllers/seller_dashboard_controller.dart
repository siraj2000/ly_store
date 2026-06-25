import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/product_status.dart';
import '../models/seller_order_model.dart';
import '../models/store_model.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class SellerDashboardController extends ChangeNotifier {
  SellerDashboardController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  AuthController? _authController;

  void bind({required AuthController authController}) {
    _authController = authController;
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

  double get totalSales =>
      sellerOrders.fold(0, (sum, order) => sum + order.sellerNetAmount);

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

  int get lowStockProducts =>
      sellerProducts.where((product) => product.stock <= 5).length;

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

  List<ProductModel> get bestSellingProducts {
    final items = [...sellerProducts];
    items.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return items.take(5).toList();
  }
}
