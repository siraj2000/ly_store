import '../models/order_model.dart';
import '../models/seller_order_model.dart';
import 'mock_data_service.dart';

class OrderService {
  OrderService(this._mockDataService);

  final MockDataService _mockDataService;

  List<OrderModel> demoOrders() => _mockDataService.demoOrders;

  List<OrderModel> ordersForCustomer(String customerId) {
    return _mockDataService.ordersForCustomer(customerId);
  }

  List<OrderModel> ordersForSeller(String sellerId) {
    return _mockDataService.ordersForSeller(sellerId);
  }

  List<SellerOrderModel> sellerOrdersForSeller(String sellerId) {
    return _mockDataService.sellerOrdersForSeller(sellerId);
  }

  List<OrderModel> allOrders() => _mockDataService.platformOrders;

  List<SellerOrderModel> allSellerOrders() => _mockDataService.sellerOrders;

  void createOrder(OrderModel order, {List<SellerOrderModel>? sellerOrders}) {
    _mockDataService.createOrder(order, sellerOrders: sellerOrders);
  }

  void updateOrder(OrderModel order) {
    _mockDataService.updateOrder(order);
  }

  Future<void> updateSellerOrder(SellerOrderModel order) async {
    await _mockDataService.updateSellerOrder(order);
  }

  void recomputeMasterOrderStatus(String masterOrderId) {
    _mockDataService.recomputeMasterOrderStatus(masterOrderId);
  }

  void notifyCustomerSellerOrderStatusChanged(SellerOrderModel order) {
    _mockDataService.createSellerOrderStatusNotification(order);
  }
}
