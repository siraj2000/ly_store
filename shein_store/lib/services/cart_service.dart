import '../models/cart_item_model.dart';
import 'mock_data_service.dart';

class CartService {
  CartService(MockDataService mockDataService);

  List<CartItemModel> initialCart() {
    return [];
  }

  double shippingFor(double subtotal) {
    if (subtotal == 0) return 0;
    return subtotal >= 49 ? 0 : 6.99;
  }

  String freeShippingMessage(double subtotal) {
    if (subtotal >= 49) return 'You unlocked free shipping';
    final remaining = 49 - subtotal;
    return 'Spend \$${remaining.toStringAsFixed(2)} more for free shipping';
  }
}
