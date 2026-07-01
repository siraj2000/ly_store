import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';
import '../config/catalog_config.dart';
import '../helpers/product_orderability_helper.dart';

class ProductAvailabilityResult {
  const ProductAvailabilityResult({
    required this.isVisible,
    required this.isOrderable,
    required this.isOutOfStock,
    required this.reasonCode,
    required this.messageKey,
    required this.availableStock,
    required this.requestedQuantity,
    required this.englishMessage,
    required this.arabicMessage,
  });

  final bool isVisible;
  final bool isOrderable;
  final bool isOutOfStock;
  final CartItemAvailabilityReason reasonCode;
  final String messageKey;
  final int? availableStock;
  final int requestedQuantity;
  final String englishMessage;
  final String arabicMessage;
}

class ProductAvailabilityPolicy {
  const ProductAvailabilityPolicy._();

  static bool shouldShowUnavailableProducts() {
    return CatalogConfig.showUnavailableProducts;
  }

  static bool shouldHideUnavailableProducts() {
    return CatalogConfig.hideUnavailableProducts;
  }

  static bool shouldShowUnavailableBadge() {
    return CatalogConfig.showUnavailableBadge;
  }

  static bool requiresColor(ProductModel product) {
    return product.colors.where((item) => item.trim().isNotEmpty).isNotEmpty;
  }

  static bool requiresSize(ProductModel product) {
    return product.sizes.where((item) => item.trim().isNotEmpty).isNotEmpty;
  }

  static bool isProductVisibleInCatalog({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
  }) {
    return getAvailability(
      product: product,
      seller: seller,
      store: store,
      quantity: 1,
    ).isVisible;
  }

  static bool isProductOrderable({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
    ProductVariantModel? selectedVariant,
    int quantity = 1,
  }) {
    return getAvailability(
      product: product,
      seller: seller,
      store: store,
      selectedVariant: selectedVariant,
      quantity: quantity,
    ).isOrderable;
  }

  static ProductAvailabilityResult getAvailability({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
    ProductVariantModel? selectedVariant,
    int quantity = 1,
  }) {
    final result = ProductOrderabilityHelper.validate(
      cartItemId: '',
      product: product,
      seller: seller,
      store: store,
      selectedColor: selectedVariant?.color ?? '',
      selectedSize: selectedVariant?.size ?? '',
      requestedQuantity: quantity,
      requireVariantSelection: selectedVariant != null,
    );
    final canShowUnavailable =
        !shouldHideUnavailableProducts() && shouldShowUnavailableBadge();
    final visibleUnavailableReasons = {
      CartItemAvailabilityReason.productOutOfStock,
      CartItemAvailabilityReason.variantOutOfStock,
      CartItemAvailabilityReason.selectedVariantOutOfStock,
      CartItemAvailabilityReason.quantityGreaterThanStock,
    };
    final hiddenReasons = {
      CartItemAvailabilityReason.productNotFound,
      CartItemAvailabilityReason.productInactive,
      CartItemAvailabilityReason.productPendingApproval,
      CartItemAvailabilityReason.productRejected,
      CartItemAvailabilityReason.productArchived,
      CartItemAvailabilityReason.productNotOrderable,
      CartItemAvailabilityReason.sellerNotFound,
      CartItemAvailabilityReason.sellerInactive,
      CartItemAvailabilityReason.sellerSuspended,
      CartItemAvailabilityReason.storeNotFound,
      CartItemAvailabilityReason.storeInactive,
      CartItemAvailabilityReason.storeSuspended,
      CartItemAvailabilityReason.storeVacationMode,
      CartItemAvailabilityReason.variantNotFound,
      CartItemAvailabilityReason.variantSelectionRequired,
      CartItemAvailabilityReason.selectedVariantInactive,
    };
    final isVisible =
        result.isAvailable ||
        (canShowUnavailable &&
            visibleUnavailableReasons.contains(result.reasonCode) &&
            !hiddenReasons.contains(result.reasonCode));
    final isOutOfStock = {
      CartItemAvailabilityReason.productOutOfStock,
      CartItemAvailabilityReason.selectedVariantOutOfStock,
      CartItemAvailabilityReason.variantOutOfStock,
      CartItemAvailabilityReason.quantityGreaterThanStock,
    }.contains(result.reasonCode);

    return ProductAvailabilityResult(
      isVisible: isVisible,
      isOrderable: result.isAvailable,
      isOutOfStock: isOutOfStock,
      reasonCode: result.reasonCode,
      messageKey: _messageKeyFor(result.reasonCode),
      availableStock: result.availableStock,
      requestedQuantity: quantity,
      englishMessage: result.englishMessage,
      arabicMessage: result.arabicMessage,
    );
  }

  static String _messageKeyFor(CartItemAvailabilityReason reason) {
    return switch (reason) {
      CartItemAvailabilityReason.available => 'available',
      CartItemAvailabilityReason.productOutOfStock ||
      CartItemAvailabilityReason.selectedVariantOutOfStock ||
      CartItemAvailabilityReason.variantOutOfStock => 'outOfStock',
      CartItemAvailabilityReason.storeVacationMode => 'storeOnVacation',
      CartItemAvailabilityReason.productPendingApproval =>
        'productPendingApproval',
      CartItemAvailabilityReason.quantityGreaterThanStock =>
        'quantityGreaterThanStock',
      _ => 'productUnavailable',
    };
  }
}
