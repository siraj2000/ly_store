import '../../models/product_model.dart';
import '../../models/product_status.dart';
import '../../models/product_variant_model.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';

enum CartItemAvailabilityReason {
  available,
  productNotFound,
  productInactive,
  productPendingApproval,
  productRejected,
  productArchived,
  productOutOfStock,
  variantOutOfStock,
  quantityGreaterThanStock,
  variantNotFound,
  selectedVariantInactive,
  selectedVariantOutOfStock,
  variantSelectionRequired,
  storeNotFound,
  storeInactive,
  storeSuspended,
  storeVacationMode,
  sellerNotFound,
  sellerInactive,
  sellerSuspended,
  productNotOrderable,
}

class CartItemAvailabilityResult {
  const CartItemAvailabilityResult({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.isAvailable,
    required this.reasonCode,
    required this.requestedQuantity,
    this.availableStock,
    this.canAutoFix = false,
  });

  factory CartItemAvailabilityResult.available({
    required String cartItemId,
    required ProductModel product,
    required int requestedQuantity,
    required int availableStock,
  }) {
    return CartItemAvailabilityResult(
      cartItemId: cartItemId,
      productId: product.id,
      productName: product.title,
      isAvailable: true,
      reasonCode: CartItemAvailabilityReason.available,
      availableStock: availableStock,
      requestedQuantity: requestedQuantity,
      canAutoFix: false,
    );
  }

  factory CartItemAvailabilityResult.unavailable({
    required String cartItemId,
    required String productId,
    required String productName,
    required CartItemAvailabilityReason reasonCode,
    required int requestedQuantity,
    int? availableStock,
    bool canAutoFix = false,
  }) {
    return CartItemAvailabilityResult(
      cartItemId: cartItemId,
      productId: productId,
      productName: productName,
      isAvailable: false,
      reasonCode: reasonCode,
      availableStock: availableStock,
      requestedQuantity: requestedQuantity,
      canAutoFix: canAutoFix,
    );
  }

  final String cartItemId;
  final String productId;
  final String productName;
  final bool isAvailable;
  final CartItemAvailabilityReason reasonCode;
  final int? availableStock;
  final int requestedQuantity;
  final bool canAutoFix;

  String get englishMessage {
    final name = productName.isEmpty ? 'This product' : productName;
    return switch (reasonCode) {
      CartItemAvailabilityReason.available => '$name is available.',
      CartItemAvailabilityReason.productNotFound =>
        '$name is no longer available.',
      CartItemAvailabilityReason.productInactive =>
        '$name is currently unavailable.',
      CartItemAvailabilityReason.productPendingApproval =>
        '$name is waiting for approval.',
      CartItemAvailabilityReason.productRejected =>
        '$name is not approved for sale.',
      CartItemAvailabilityReason.productArchived =>
        '$name is no longer available.',
      CartItemAvailabilityReason.productOutOfStock => '$name is out of stock.',
      CartItemAvailabilityReason.variantOutOfStock =>
        'Selected color or size is out of stock for $name.',
      CartItemAvailabilityReason.quantityGreaterThanStock =>
        '$name only has ${availableStock ?? 0} available.',
      CartItemAvailabilityReason.variantNotFound =>
        'Please reselect color and size for $name.',
      CartItemAvailabilityReason.selectedVariantInactive =>
        'Selected color or size is no longer available for $name.',
      CartItemAvailabilityReason.selectedVariantOutOfStock =>
        'Selected color or size is out of stock for $name.',
      CartItemAvailabilityReason.variantSelectionRequired =>
        'Please reselect color and size for $name.',
      CartItemAvailabilityReason.storeNotFound =>
        'The store for $name is no longer available.',
      CartItemAvailabilityReason.storeInactive =>
        'The store for $name is currently inactive.',
      CartItemAvailabilityReason.storeSuspended =>
        'The store for $name is currently suspended.',
      CartItemAvailabilityReason.storeVacationMode =>
        'The store is currently on vacation.',
      CartItemAvailabilityReason.sellerNotFound =>
        'The seller for $name is no longer available.',
      CartItemAvailabilityReason.sellerInactive =>
        'The seller for $name is currently inactive.',
      CartItemAvailabilityReason.sellerSuspended =>
        'The seller for $name is currently suspended.',
      CartItemAvailabilityReason.productNotOrderable =>
        '$name is not available for purchase.',
    };
  }

  String get arabicMessage {
    final name = productName.isEmpty ? 'هذا المنتج' : productName;
    return switch (reasonCode) {
      CartItemAvailabilityReason.available => '$name متاح.',
      CartItemAvailabilityReason.productNotFound => 'هذا المنتج لم يعد متاحاً.',
      CartItemAvailabilityReason.productInactive => '$name غير متاح حالياً.',
      CartItemAvailabilityReason.productPendingApproval =>
        'هذا المنتج في انتظار الموافقة.',
      CartItemAvailabilityReason.productRejected =>
        'هذا المنتج غير معتمد للبيع.',
      CartItemAvailabilityReason.productArchived => 'هذا المنتج لم يعد متاحاً.',
      CartItemAvailabilityReason.productOutOfStock =>
        'المنتج غير متوفر في المخزون.',
      CartItemAvailabilityReason.variantOutOfStock =>
        'اللون أو المقاس المحدد غير متوفر في المخزون.',
      CartItemAvailabilityReason.quantityGreaterThanStock =>
        'الكمية المطلوبة أكبر من المتاح.',
      CartItemAvailabilityReason.variantNotFound =>
        'يرجى إعادة اختيار اللون والمقاس.',
      CartItemAvailabilityReason.selectedVariantInactive =>
        'اللون أو المقاس المحدد لم يعد متاحاً.',
      CartItemAvailabilityReason.selectedVariantOutOfStock =>
        'اللون أو المقاس المحدد غير متوفر في المخزون.',
      CartItemAvailabilityReason.variantSelectionRequired =>
        'يرجى إعادة اختيار اللون والمقاس.',
      CartItemAvailabilityReason.storeNotFound => 'متجر $name لم يعد متاحاً.',
      CartItemAvailabilityReason.storeInactive => 'متجر $name غير نشط حالياً.',
      CartItemAvailabilityReason.storeSuspended => 'متجر $name موقوف حالياً.',
      CartItemAvailabilityReason.storeVacationMode =>
        'المتجر حالياً في وضع الإجازة.',
      CartItemAvailabilityReason.sellerNotFound => 'بائع $name لم يعد متاحاً.',
      CartItemAvailabilityReason.sellerInactive => 'بائع $name غير نشط حالياً.',
      CartItemAvailabilityReason.sellerSuspended => 'بائع $name موقوف حالياً.',
      CartItemAvailabilityReason.productNotOrderable =>
        '$name غير متاح للشراء.',
    };
  }
}

class ProductOrderabilityHelper {
  const ProductOrderabilityHelper._();

  static bool isProductVisibleForPurchase({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
  }) {
    final baseResult = validate(
      cartItemId: '',
      product: product,
      seller: seller,
      store: store,
      selectedColor: '',
      selectedSize: '',
      requestedQuantity: 1,
      requireVariantSelection: false,
    );
    return baseResult.isAvailable;
  }

  static CartItemAvailabilityResult validate({
    required String cartItemId,
    required ProductModel? product,
    required UserModel? seller,
    required StoreModel? store,
    required String selectedColor,
    required String selectedSize,
    required int requestedQuantity,
    bool requireVariantSelection = true,
  }) {
    final productId = product?.id ?? '';
    final productName = product?.title ?? '';

    CartItemAvailabilityResult unavailable(
      CartItemAvailabilityReason reason, {
      int? availableStock,
      bool canAutoFix = false,
    }) {
      return CartItemAvailabilityResult.unavailable(
        cartItemId: cartItemId,
        productId: productId,
        productName: productName,
        reasonCode: reason,
        requestedQuantity: requestedQuantity,
        availableStock: availableStock,
        canAutoFix: canAutoFix,
      );
    }

    if (product == null) {
      return unavailable(CartItemAvailabilityReason.productNotFound);
    }
    if (product.id.trim().isEmpty ||
        product.sellerId.trim().isEmpty ||
        product.storeId.trim().isEmpty) {
      return unavailable(CartItemAvailabilityReason.productNotFound);
    }
    if (seller == null) {
      return unavailable(CartItemAvailabilityReason.sellerNotFound);
    }
    if (seller.id != product.sellerId) {
      return unavailable(CartItemAvailabilityReason.sellerNotFound);
    }
    if (!seller.isActive) {
      return unavailable(CartItemAvailabilityReason.sellerInactive);
    }
    if (seller.sellerStatus == 'suspended') {
      return unavailable(CartItemAvailabilityReason.sellerSuspended);
    }
    if (!seller.isSellerAccountActive) {
      return unavailable(CartItemAvailabilityReason.sellerInactive);
    }
    if (store == null) {
      return unavailable(CartItemAvailabilityReason.storeNotFound);
    }
    if (store.id != product.storeId || store.sellerId != product.sellerId) {
      return unavailable(CartItemAvailabilityReason.storeNotFound);
    }
    if (store.suspendedAt != null || store.status == StoreStatusIds.suspended) {
      return unavailable(CartItemAvailabilityReason.storeSuspended);
    }
    if (store.approvalStatus != StoreApprovalStatusIds.approved) {
      return unavailable(CartItemAvailabilityReason.storeInactive);
    }
    if (!store.isActive ||
        store.status == StoreStatusIds.inactive ||
        store.status == StoreStatusIds.closed) {
      return unavailable(CartItemAvailabilityReason.storeInactive);
    }
    if (store.vacationMode || store.status == StoreStatusIds.vacation) {
      return unavailable(CartItemAvailabilityReason.storeVacationMode);
    }
    if (product.isDeleted || product.status == ProductStatus.deleted) {
      return unavailable(CartItemAvailabilityReason.productNotFound);
    }
    if (product.status == ProductStatus.pendingApproval) {
      return unavailable(CartItemAvailabilityReason.productPendingApproval);
    }
    if (product.status == ProductStatus.rejected) {
      return unavailable(CartItemAvailabilityReason.productRejected);
    }
    if (product.status == ProductStatus.archived) {
      return unavailable(CartItemAvailabilityReason.productArchived);
    }
    if (product.status == ProductStatus.outOfStock) {
      return unavailable(
        CartItemAvailabilityReason.productOutOfStock,
        availableStock: 0,
      );
    }
    if (!product.isActive) {
      return unavailable(CartItemAvailabilityReason.productInactive);
    }
    if (product.status != ProductStatus.active) {
      return unavailable(CartItemAvailabilityReason.productNotOrderable);
    }
    if (requestedQuantity < 1) {
      return unavailable(CartItemAvailabilityReason.quantityGreaterThanStock);
    }

    final availableStock = product.variants.isEmpty
        ? product.stock
        : product.variants
              .where((variant) => variant.isActive)
              .fold<int>(0, (sum, variant) => sum + variant.stock);

    if (requireVariantSelection) {
      final requiresColor = product.colors.any(
        (item) => item.trim().isNotEmpty,
      );
      final requiresSize = product.sizes.any((item) => item.trim().isNotEmpty);
      if (requiresColor && selectedColor.trim().isEmpty) {
        return unavailable(CartItemAvailabilityReason.variantSelectionRequired);
      }
      if (requiresSize && selectedSize.trim().isEmpty) {
        return unavailable(CartItemAvailabilityReason.variantSelectionRequired);
      }
    }

    if (product.variants.isEmpty) {
      if (availableStock < 1) {
        return unavailable(
          CartItemAvailabilityReason.productOutOfStock,
          availableStock: availableStock,
        );
      }
      if (requestedQuantity > availableStock) {
        return unavailable(
          CartItemAvailabilityReason.quantityGreaterThanStock,
          availableStock: availableStock,
          canAutoFix: availableStock > 0,
        );
      }
      return CartItemAvailabilityResult.available(
        cartItemId: cartItemId,
        product: product,
        requestedQuantity: requestedQuantity,
        availableStock: availableStock,
      );
    }

    if (!requireVariantSelection) {
      if (availableStock < 1) {
        return unavailable(
          CartItemAvailabilityReason.productOutOfStock,
          availableStock: availableStock,
        );
      }
      return CartItemAvailabilityResult.available(
        cartItemId: cartItemId,
        product: product,
        requestedQuantity: requestedQuantity,
        availableStock: availableStock,
      );
    }

    final variant = _resolveVariant(
      variants: product.variants,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );
    if (variant == null) {
      return unavailable(CartItemAvailabilityReason.variantNotFound);
    }
    if (!variant.isActive) {
      return unavailable(CartItemAvailabilityReason.selectedVariantInactive);
    }
    if (variant.stock < 1) {
      return unavailable(
        CartItemAvailabilityReason.variantOutOfStock,
        availableStock: 0,
      );
    }
    if (requestedQuantity > variant.stock) {
      return unavailable(
        CartItemAvailabilityReason.quantityGreaterThanStock,
        availableStock: variant.stock,
        canAutoFix: variant.stock > 0,
      );
    }
    return CartItemAvailabilityResult.available(
      cartItemId: cartItemId,
      product: product,
      requestedQuantity: requestedQuantity,
      availableStock: variant.stock,
    );
  }

  static ProductVariantModel? resolveVariant({
    required ProductModel product,
    required String selectedColor,
    required String selectedSize,
  }) {
    return _resolveVariant(
      variants: product.variants,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );
  }

  static ProductVariantModel? _resolveVariant({
    required List<ProductVariantModel> variants,
    required String selectedColor,
    required String selectedSize,
  }) {
    for (final variant in variants) {
      final colorMatches =
          variant.color.isEmpty || variant.color == selectedColor;
      final sizeMatches = variant.size.isEmpty || variant.size == selectedSize;
      if (colorMatches && sizeMatches) {
        return variant;
      }
    }
    return null;
  }
}
