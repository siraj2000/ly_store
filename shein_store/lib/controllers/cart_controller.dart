import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/coupon_model.dart';
import '../models/product_model.dart';
import '../models/user_role.dart';
import '../core/helpers/product_orderability_helper.dart';
import '../services/cart_service.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

class CartController extends ChangeNotifier {
  CartController({required CartService cartService})
    : _cartService = cartService;

  final CartService _cartService;
  AuthController? _authController;
  ProductController? _productController;
  final List<CartItemModel> _items = [];
  String? _boundUserId;
  CouponModel? appliedCoupon;
  bool usePoints = false;
  bool useWallet = false;
  CartActionResult? lastActionResult;

  List<CartItemModel> get items => List.unmodifiable(_items);

  void bind({
    required AuthController authController,
    required ProductController productController,
  }) {
    _authController = authController;
    _productController = productController;
    final nextUserId = authController.currentUser?.id;
    if (_boundUserId != nextUserId) {
      _boundUserId = nextUserId;
      _items
        ..clear()
        ..addAll(authController.currentUser?.cart ?? const []);
      appliedCoupon = null;
      usePoints = false;
      useWallet = false;
    }
    notifyListeners();
  }

  CartActionResult addToCart(
    ProductModel product,
    String selectedColor,
    String selectedSize,
    int quantity,
  ) {
    if (_authController?.currentRole != UserRole.customer) {
      return _setResult(CartActionResult.failure('customer_required'));
    }
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );
    final existingQuantity = existingIndex >= 0
        ? _items[existingIndex].quantity
        : 0;
    final validation = _validateCartRequest(
      product: product,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
      requestedQuantity: existingQuantity + quantity,
    );
    if (!validation.isSuccess) {
      notifyListeners();
      return _setResult(validation);
    }
    final canonicalProduct = validation.product ?? product;
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        product: canonicalProduct,
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(
        CartItemModel(
          id: '${canonicalProduct.id}_${DateTime.now().millisecondsSinceEpoch}',
          product: canonicalProduct,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
          quantity: quantity,
        ),
      );
    }
    _persistCart();
    notifyListeners();
    return _setResult(CartActionResult.success(product: canonicalProduct));
  }

  void removeFromCart(String cartItemId) {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    _items.removeWhere((item) => item.id == cartItemId);
    _persistCart();
    notifyListeners();
  }

  CartActionResult updateQuantity(String cartItemId, int quantity) {
    if (_authController?.currentRole != UserRole.customer) {
      return _setResult(CartActionResult.failure('customer_required'));
    }
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return _setResult(CartActionResult.failure('cart_item_not_found'));
    }
    if (quantity <= 0) {
      removeFromCart(cartItemId);
      return _setResult(CartActionResult.success());
    }
    final item = _items[index];
    final validation = _validateCartRequest(
      product: item.product,
      selectedColor: item.selectedColor,
      selectedSize: item.selectedSize,
      requestedQuantity: quantity,
    );
    if (!validation.isSuccess) {
      notifyListeners();
      return _setResult(validation);
    }
    _items[index] = item.copyWith(
      product: validation.product ?? item.product,
      quantity: quantity,
    );
    _persistCart();
    notifyListeners();
    return _setResult(CartActionResult.success(product: _items[index].product));
  }

  void selectItem(String cartItemId, bool selected) {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isSelected: selected);
    _persistCart();
    notifyListeners();
  }

  void selectAll(bool selected) {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(isSelected: selected);
    }
    _persistCart();
    notifyListeners();
  }

  bool applyCoupon(CouponModel coupon) {
    if (_authController?.currentRole != UserRole.customer) {
      return false;
    }
    if (calculateSubtotal() < coupon.minimumSpend) {
      return false;
    }
    appliedCoupon = coupon;
    notifyListeners();
    return true;
  }

  double calculateSubtotal() {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.product.price * item.quantity);
  }

  double calculateDiscount() {
    final subtotal = calculateSubtotal();
    var discount = 0.0;
    if (appliedCoupon != null) {
      discount += appliedCoupon!.isPercentage
          ? subtotal * (appliedCoupon!.amount / 100)
          : appliedCoupon!.amount;
    }
    return discount > subtotal ? subtotal : discount;
  }

  double calculateShipping() {
    return _cartService.shippingFor(calculateSubtotal());
  }

  double calculateTotal() {
    final subtotal = calculateSubtotal();
    final total = subtotal - calculateDiscount() + calculateShipping();
    return total < 0 ? 0 : total;
  }

  void setUsePoints(bool enabled) {
    usePoints = enabled;
    notifyListeners();
  }

  void setUseWallet(bool enabled) {
    useWallet = enabled;
    notifyListeners();
  }

  void clearPurchasedItems() {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    _items.removeWhere((item) => item.isSelected);
    appliedCoupon = null;
    usePoints = false;
    useWallet = false;
    _persistCart();
    notifyListeners();
  }

  List<CartItemModel> get selectedItems =>
      _items.where((item) => item.isSelected).toList();

  List<CartItemAvailabilityResult> get availabilityResults =>
      _items.map(availabilityForItem).toList();

  List<CartItemAvailabilityResult> get selectedAvailabilityIssues =>
      selectedItems
          .map(availabilityForItem)
          .where((result) => !result.isAvailable)
          .toList();

  bool get hasUnavailableSelectedItems => selectedAvailabilityIssues.isNotEmpty;

  CartItemAvailabilityResult availabilityForItem(CartItemModel item) {
    final productController = _productController;
    final canonicalProduct = productController == null
        ? item.product
        : productController.productById(item.product.id);
    final seller = canonicalProduct == null
        ? null
        : productController?.sellerForProduct(canonicalProduct);
    final store = canonicalProduct == null
        ? null
        : productController?.storeForProduct(canonicalProduct);
    return ProductOrderabilityHelper.validate(
      cartItemId: item.id,
      product: canonicalProduct,
      seller: seller,
      store: store,
      selectedColor: item.selectedColor,
      selectedSize: item.selectedSize,
      requestedQuantity: item.quantity,
    );
  }

  void removeUnavailableItems() {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    _items.removeWhere((item) => !availabilityForItem(item).isAvailable);
    _persistCart();
    notifyListeners();
  }

  CartActionResult reduceQuantityToAvailableStock(String cartItemId) {
    if (_authController?.currentRole != UserRole.customer) {
      return _setResult(CartActionResult.failure('customer_required'));
    }
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return _setResult(CartActionResult.failure('cart_item_not_found'));
    }
    final item = _items[index];
    final availability = availabilityForItem(item);
    final availableStock = availability.availableStock ?? 0;
    if (!availability.canAutoFix || availableStock < 1) {
      return _setResult(
        CartActionResult.failure(
          availability.reasonCode.name,
          availableStock: availability.availableStock,
          product: item.product,
        ),
      );
    }
    return updateQuantity(cartItemId, availableStock);
  }

  String freeShippingMessage() {
    return _cartService.freeShippingMessage(calculateSubtotal());
  }

  void _persistCart() {
    final currentUser = _authController?.currentUser;
    if (currentUser == null || currentUser.role != UserRole.customer) {
      return;
    }
    _authController?.replaceUser(
      currentUser.copyWith(cart: List<CartItemModel>.from(_items)),
    );
  }

  CartActionResult _validateCartRequest({
    required ProductModel product,
    required String selectedColor,
    required String selectedSize,
    required int requestedQuantity,
  }) {
    final productController = _productController;
    final canonicalProduct = productController?.productById(product.id);
    final seller = canonicalProduct == null
        ? null
        : productController?.sellerForProduct(canonicalProduct);
    final store = canonicalProduct == null
        ? null
        : productController?.storeForProduct(canonicalProduct);
    final availability = ProductOrderabilityHelper.validate(
      cartItemId: '',
      product: canonicalProduct,
      seller: seller,
      store: store,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
      requestedQuantity: requestedQuantity,
    );
    if (!availability.isAvailable) {
      return CartActionResult.failure(
        availability.reasonCode.name,
        availableStock: availability.availableStock,
        product: canonicalProduct,
      );
    }
    return CartActionResult.success(
      availableStock: availability.availableStock,
      product: canonicalProduct,
    );
  }

  CartActionResult _setResult(CartActionResult result) {
    lastActionResult = result;
    return result;
  }
}

class CartActionResult {
  const CartActionResult._({
    required this.isSuccess,
    this.errorCode,
    this.availableStock,
    this.product,
  });

  factory CartActionResult.success({
    int? availableStock,
    ProductModel? product,
  }) {
    return CartActionResult._(
      isSuccess: true,
      availableStock: availableStock,
      product: product,
    );
  }

  factory CartActionResult.failure(
    String errorCode, {
    int? availableStock,
    ProductModel? product,
  }) {
    return CartActionResult._(
      isSuccess: false,
      errorCode: errorCode,
      availableStock: availableStock,
      product: product,
    );
  }

  final bool isSuccess;
  final String? errorCode;
  final int? availableStock;
  final ProductModel? product;
}
