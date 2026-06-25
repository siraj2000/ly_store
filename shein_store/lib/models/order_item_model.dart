import 'product_model.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
    required this.price,
  });

  final String id;
  final ProductModel product;
  final String selectedColor;
  final String selectedSize;
  final int quantity;
  final double price;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      product: ProductModel.fromJson(
        json['product'] as Map<String, dynamic>? ?? const {},
      ),
      selectedColor: json['selectedColor'] as String? ?? '',
      selectedSize: json['selectedSize'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'selectedColor': selectedColor,
    'selectedSize': selectedSize,
    'quantity': quantity,
    'price': price,
  };
}
