import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/seller_order_model.dart';
import '../models/user_role.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class SellerOrderController extends ChangeNotifier {
  SellerOrderController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;
  AuthController? _authController;

  static const List<String> statusSections = [
    'All',
    'New',
    'Processing',
    'Ready to Ship',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Returned',
  ];

  String selectedStatus = 'All';
  String query = '';

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  String get sellerId => _authController?.currentUser?.id ?? '';
  bool get _isSeller => _authController?.currentRole == UserRole.seller;

  List<OrderModel> get orders {
    if (!_isSeller) return [];
    final sellerOrders = _orderService.ordersForSeller(sellerId);
    sellerOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sellerOrders;
  }

  List<OrderModel> get filteredOrders {
    var items = orders;
    if (selectedStatus != 'All') {
      items = ordersByStatus(selectedStatus);
    }
    if (query.trim().isEmpty) {
      return items;
    }
    final lower = query.toLowerCase().trim();
    return items.where((order) {
      final firstItem = order.items.isEmpty ? null : order.items.first;
      final productTitle = firstItem?.product.title.toLowerCase() ?? '';
      final productSku = firstItem?.product.sku.toLowerCase() ?? '';
      return order.id.toLowerCase().contains(lower) ||
          order.customerName.toLowerCase().contains(lower) ||
          productTitle.contains(lower) ||
          productSku.contains(lower);
    }).toList();
  }

  List<OrderModel> ordersByStatus(String status) {
    return orders.where((order) => displayStatus(order) == status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String displayStatus(OrderModel order) {
    switch (order.status) {
      case 'Unpaid':
      case 'Pending':
        return 'New';
      case 'Processing':
        return 'Processing';
      case 'Ready to Ship':
        return 'Ready to Ship';
      case 'Shipped':
        return 'Shipped';
      case 'Delivered':
        return 'Delivered';
      case 'Cancelled':
        return 'Cancelled';
      case 'Returned':
      case 'Review':
        return 'Returned';
      default:
        return 'Processing';
    }
  }

  int countForStatus(String status) {
    if (status == 'All') {
      return orders.length;
    }
    return ordersByStatus(status).length;
  }

  SellerOrderModel? sellerOrderById(String orderId) {
    if (!_isSeller) return null;
    final matches = _orderService
        .sellerOrdersForSeller(sellerId)
        .where((order) => order.id == orderId);
    return matches.isEmpty ? null : matches.first;
  }

  String? nextStatusFor(OrderModel order) {
    switch (displayStatus(order)) {
      case 'New':
        return 'Processing';
      case 'Processing':
        return 'Ready to Ship';
      case 'Ready to Ship':
        return 'Shipped';
      case 'Shipped':
        return 'Delivered';
      default:
        return null;
    }
  }

  String? primaryActionLabel(OrderModel order) {
    switch (displayStatus(order)) {
      case 'New':
        return 'Accept Order';
      case 'Processing':
        return 'Prepare Order';
      case 'Ready to Ship':
        return 'Mark Shipped';
      case 'Shipped':
        return 'Mark Delivered';
      default:
        return null;
    }
  }

  void setStatusFilter(String value) {
    selectedStatus = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    if (!_isSeller) return false;
    final existing = sellerOrderById(orderId);
    if (existing == null) return false;
    final now = DateTime.now();
    final updated = existing.copyWith(
      status: status,
      shippingStatus: _shippingStatusFor(status),
      deliveredAt: status == 'Delivered' ? now : existing.deliveredAt,
      updatedAt: now,
    );
    await _orderService.updateSellerOrder(updated);
    _orderService.recomputeMasterOrderStatus(updated.masterOrderId);
    _orderService.notifyCustomerSellerOrderStatusChanged(updated);
    notifyListeners();
    return true;
  }

  Future<bool> markOrderShipped({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
    String trackingUrl = '',
    String shippingNotes = '',
  }) async {
    if (!_isSeller) return false;
    final existing = sellerOrderById(orderId);
    if (existing == null) return false;
    final cleanCarrier = carrierName.trim();
    final cleanTracking = trackingNumber.trim();
    if (cleanCarrier.isEmpty || cleanTracking.isEmpty) return false;
    final now = DateTime.now();
    final updated = existing.copyWith(
      status: 'Shipped',
      shippingStatus: 'Shipped',
      carrierName: cleanCarrier,
      trackingNumber: cleanTracking,
      trackingUrl: trackingUrl.trim(),
      shippingNotes: shippingNotes.trim(),
      shippedAt: now,
      updatedAt: now,
    );
    await _orderService.updateSellerOrder(updated);
    _orderService.recomputeMasterOrderStatus(updated.masterOrderId);
    _orderService.notifyCustomerSellerOrderStatusChanged(updated);
    notifyListeners();
    return true;
  }

  bool canCancel(OrderModel order) {
    return const {
      'New',
      'Processing',
      'Ready to Ship',
    }.contains(displayStatus(order));
  }

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    if (!_isSeller) return false;
    final existing = sellerOrderById(orderId);
    if (existing == null) return false;
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) return false;
    final now = DateTime.now();
    final updated = existing.copyWith(
      status: 'Cancelled',
      shippingStatus: 'Cancelled',
      cancellationReason: cleanReason,
      cancelledAt: now,
      updatedAt: now,
    );
    await _orderService.updateSellerOrder(updated);
    _orderService.recomputeMasterOrderStatus(updated.masterOrderId);
    _orderService.notifyCustomerSellerOrderStatusChanged(updated);
    notifyListeners();
    return true;
  }

  String _shippingStatusFor(String status) {
    switch (status) {
      case 'Processing':
        return 'Processing';
      case 'Ready to Ship':
        return 'Ready to Ship';
      case 'Shipped':
        return 'Shipped';
      case 'Delivered':
        return 'Delivered';
      case 'Cancelled':
        return 'Cancelled';
      case 'Returned':
        return 'Returned';
      default:
        return 'Pending';
    }
  }
}
