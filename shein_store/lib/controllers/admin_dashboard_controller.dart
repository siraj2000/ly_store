import 'package:flutter/material.dart';

import '../services/mock_data_service.dart';
import '../services/order_service.dart';

class AdminDashboardController extends ChangeNotifier {
  AdminDashboardController({
    required MockDataService mockDataService,
    required OrderService orderService,
  }) : _mockDataService = mockDataService,
       _orderService = orderService;

  final MockDataService _mockDataService;
  final OrderService _orderService;

  int get totalUsers => _mockDataService.allUsers.length;
  int get totalCustomers => _mockDataService.customers.length;
  int get totalSellers => _mockDataService.sellers.length;
  int get totalProducts => _mockDataService.allProducts.length;
  int get pendingProductApprovals => _mockDataService.pendingProducts().length;
  int get totalOrders => _orderService.allOrders().length;
  int get pendingRefunds => _orderService
      .allOrders()
      .where((order) => order.status == 'Returned')
      .length;
  int get openComplaints => _mockDataService.allProducts
      .where((product) => product.complaintCount > 0 && !product.isDeleted)
      .length;
  double get todayRevenue => _orderService
      .allOrders()
      .where((order) {
        final now = DateTime.now();
        return order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day;
      })
      .fold(0, (sum, order) => sum + order.total);
}
