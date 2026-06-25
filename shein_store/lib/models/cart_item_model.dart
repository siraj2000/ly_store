import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
    this.isSelected = true,
  });

  final String id;
  final ProductModel product;
  final String selectedColor;
  final String selectedSize;
  final int quantity;
  final bool isSelected;

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    String? selectedColor,
    String? selectedSize,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String? ?? '',
      product: ProductModel.fromJson(
        json['product'] as Map<String, dynamic>? ?? const {},
      ),
      selectedColor: json['selectedColor'] as String? ?? '',
      selectedSize: json['selectedSize'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      isSelected: json['isSelected'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'selectedColor': selectedColor,
    'selectedSize': selectedSize,
    'quantity': quantity,
    'isSelected': isSelected,
  };
}
