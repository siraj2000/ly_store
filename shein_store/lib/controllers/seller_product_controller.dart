import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin/platform_setting_model.dart';
import '../models/category_model.dart';
import '../models/localized_text_model.dart';
import '../models/product_model.dart';
import '../models/product_status.dart';
import '../models/product_variant_model.dart';
import '../models/store_model.dart';
import '../models/user_role.dart';
import '../repositories/admin_repository.dart';
import '../repositories/marketplace_repository.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class SellerProductController extends ChangeNotifier {
  SellerProductController({
    required MockDataService mockDataService,
    required AdminRepository adminRepository,
    required MarketplaceRepository marketplaceRepository,
  }) : _mockDataService = mockDataService,
       _adminRepository = adminRepository,
       _marketplaceRepository = marketplaceRepository;

  final MockDataService _mockDataService;
  final AdminRepository _adminRepository;
  final MarketplaceRepository _marketplaceRepository;
  final ImagePicker _imagePicker = ImagePicker();
  AuthController? _authController;
  PlatformSettingModel? _platformSettings;
  StoreModel? _store;
  List<CategoryModel> _categories = const [];
  String _storeId = '';

  String statusFilter = 'All';
  String query = '';

  String selectedDepartment = '';
  String selectedCategory = '';
  String selectedSubcategory = '';
  List<String> selectedColors = [];
  List<String> selectedSizes = [];
  List<String> selectedImages = [];
  bool isReturnable = true;
  bool saveAsDraft = false;
  bool isSubmitting = false;
  Map<String, String> validationErrors = {};

  static const List<String> availableColors = [
    'Black',
    'White',
    'Ivory',
    'Beige',
    'Brown',
    'Grey',
    'Red',
    'Pink',
    'Blue',
    'Navy',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Gold',
    'Silver',
  ];

  static const List<String> availableSizes = [
    'One Size',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '3XL',
    '4XL',
    '5XL',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
  ];

  void bind({required AuthController authController}) {
    _authController = authController;
    unawaited(_loadSellerContext());
    notifyListeners();
  }

  String get sellerId => _authController?.currentUser?.id ?? '';
  String get sellerName => _authController?.currentUser?.name ?? 'Seller';
  bool get _isSeller => _authController?.currentRole == UserRole.seller;
  bool get requiresProductApproval =>
      _platformSettings?.requiresProductApproval ?? false;

  List<CategoryModel> get allowedCategories {
    final active = _categories.where((category) => category.isActive).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final allowedIds = _store?.allowedCategoryIds ?? const <String>[];
    if (allowedIds.isEmpty) {
      return active;
    }
    final allowed = allowedIds.toSet();
    return active.where((category) => allowed.contains(category.id)).toList();
  }

  List<String> get departments {
    final ids = <String>{};
    for (final category in allowedCategories) {
      ids.add(category.departmentId);
    }
    return ids.toList()..sort();
  }

  List<String> get categoriesForSelectedDepartment => allowedCategories
      .where((category) => category.departmentId == selectedDepartment)
      .map((category) => category.id)
      .toList();

  List<String> get subcategoriesForSelectedCategory =>
      _categoryById(selectedCategory)?.subcategories ?? const [];

  CategoryModel? _categoryById(String id) {
    final matches = _categories.where((category) => category.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  String labelForCategoryId(String categoryId, Locale locale) {
    return _categoryById(categoryId)?.localizedName(locale) ?? categoryId;
  }

  String labelForDepartmentId(String departmentId, Locale locale) {
    final direct = _categoryById(departmentId);
    if (direct != null) {
      return direct.localizedName(locale);
    }
    final matches = _categories.where(
      (category) => category.departmentId == departmentId,
    );
    return matches.isEmpty ? departmentId : matches.first.localizedName(locale);
  }

  List<ProductModel> get catalogProducts {
    if (!_isSeller) return [];
    return _mockDataService.productsForSeller(sellerId);
  }

  List<ProductModel> get products {
    if (!_isSeller) return [];
    var items = catalogProducts;
    if (statusFilter != 'All') {
      items = items
          .where((product) => _matchesStatusFilter(product.status))
          .toList();
    }
    if (query.trim().isNotEmpty) {
      final lower = query.toLowerCase();
      items = items
          .where(
            (product) =>
                product.title.toLowerCase().contains(lower) ||
                product.titleText.en.toLowerCase().contains(lower) ||
                product.titleText.ar.toLowerCase().contains(lower) ||
                product.sku.toLowerCase().contains(lower),
          )
          .toList();
    }
    return items;
  }

  bool _matchesStatusFilter(ProductStatus status) {
    switch (statusFilter) {
      case 'Active':
        return status == ProductStatus.active;
      case 'Pending Approval':
        return status == ProductStatus.pendingApproval;
      case 'Rejected':
        return status == ProductStatus.rejected;
      case 'Out of Stock':
        return status == ProductStatus.outOfStock;
      case 'Draft':
        return status == ProductStatus.draft;
      case 'Inactive':
        return status == ProductStatus.inactive;
      default:
        return true;
    }
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  void initializeForm({ProductModel? product}) {
    final category = product == null
        ? null
        : _resolveCategoryForProduct(product);
    selectedDepartment = category?.departmentId ?? product?.department ?? '';
    selectedCategory = category?.id ?? product?.categoryId ?? '';
    selectedSubcategory = product?.subcategoryId.isNotEmpty == true
        ? product!.subcategoryId
        : product?.subcategoryName ?? '';
    selectedColors = List<String>.from(product?.colors ?? const []);
    selectedSizes = List<String>.from(product?.sizes ?? const []);
    selectedImages = List<String>.from(
      product?.localImagePaths.isNotEmpty == true
          ? product!.localImagePaths
          : product?.imageUrls ?? const [],
    );
    isReturnable = product?.isReturnable ?? true;
    saveAsDraft = product?.status == ProductStatus.draft;
    validationErrors = {};
    notifyListeners();
  }

  void setDepartment(String value) {
    if (selectedDepartment == value) {
      return;
    }
    selectedDepartment = value;
    selectedCategory = '';
    selectedSubcategory = '';
    validationErrors.remove('department');
    validationErrors.remove('category');
    validationErrors.remove('subcategory');
    notifyListeners();
  }

  void setCategory(String value) {
    if (selectedCategory == value) {
      return;
    }
    selectedCategory = value;
    selectedSubcategory = '';
    validationErrors.remove('category');
    validationErrors.remove('subcategory');
    notifyListeners();
  }

  void setSubcategory(String value) {
    selectedSubcategory = value;
    validationErrors.remove('subcategory');
    notifyListeners();
  }

  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
    validationErrors.remove('colors');
    notifyListeners();
  }

  void removeColor(String color) {
    selectedColors.remove(color);
    notifyListeners();
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
    validationErrors.remove('sizes');
    notifyListeners();
  }

  void removeSize(String size) {
    selectedSizes.remove(size);
    notifyListeners();
  }

  void setReturnable(bool value) {
    isReturnable = value;
    notifyListeners();
  }

  void setSaveAsDraft(bool value) {
    saveAsDraft = value;
    notifyListeners();
  }

  Future<String?> pickProductImages() async {
    final remainingSlots = 9 - selectedImages.length;
    if (remainingSlots <= 0) {
      return 'You can upload up to 9 images only.';
    }
    try {
      final files = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (files.isNotEmpty) {
        return _storePickedImages(
          files.map((file) => file.path).toList(),
          remainingSlots,
        );
      }
      final singleFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (singleFile == null) {
        return null;
      }
      return _storePickedImages([singleFile.path], remainingSlots);
    } on MissingPluginException {
      return 'Restart the app once to enable gallery access.';
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();
      final message = (error.message ?? '').toLowerCase();
      if (code.contains('permission') || message.contains('permission')) {
        return 'Photo library permission is required to add product images.';
      }
      return 'Unable to open the gallery right now.';
    } catch (_) {
      return 'Unable to open the gallery right now.';
    }
  }

  void removeProductImage(int index) {
    if (index < 0 || index >= selectedImages.length) {
      return;
    }
    selectedImages.removeAt(index);
    notifyListeners();
  }

  String? _storePickedImages(List<String> imagePaths, int remainingSlots) {
    if (imagePaths.isEmpty) {
      return null;
    }
    final acceptedImages = imagePaths.take(remainingSlots).toList();
    String message;
    if (imagePaths.length > remainingSlots) {
      message = 'You can upload up to 9 images only.';
    } else if (acceptedImages.length == 1) {
      message = 'Image added from gallery.';
    } else {
      message = '${acceptedImages.length} images added from gallery.';
    }
    selectedImages = [...selectedImages, ...acceptedImages];
    validationErrors.remove('images');
    notifyListeners();
    return message;
  }

  bool validateAddProductForm({
    required GlobalKey<FormState> formKey,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String price,
    required String oldPrice,
    required String stock,
    required String sku,
    required String materialEn,
    required String materialAr,
  }) {
    return validateProductInput(
      formKey: formKey,
      saveAsDraft: saveAsDraft,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      price: price,
      oldPrice: oldPrice,
      stock: stock,
      sku: sku,
      materialEn: materialEn,
      materialAr: materialAr,
    );
  }

  bool validateProductInput({
    GlobalKey<FormState>? formKey,
    required bool saveAsDraft,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String price,
    required String oldPrice,
    required String stock,
    required String sku,
    required String materialEn,
    required String materialAr,
  }) {
    final errors = <String, String>{};
    final category = _categoryById(selectedCategory);

    if (saveAsDraft) {
      final hasMeaningfulField =
          titleEn.trim().isNotEmpty ||
          titleAr.trim().isNotEmpty ||
          sku.trim().isNotEmpty ||
          selectedCategory.isNotEmpty ||
          selectedImages.isNotEmpty;
      if (!hasMeaningfulField) {
        errors['draft'] = 'Add at least a title, SKU, image, or category.';
      }
    }

    if (!saveAsDraft && selectedDepartment.isEmpty) {
      errors['department'] = 'Please select a department';
    }
    if (!saveAsDraft && selectedCategory.isEmpty) {
      errors['category'] = 'Please select a category';
    }
    if (selectedCategory.isNotEmpty && !_isCategoryAllowed(selectedCategory)) {
      errors['category'] = 'This category is not allowed for your store.';
    }
    if (!saveAsDraft && category == null) {
      errors['category'] = 'Please select a valid category';
    }
    if (!saveAsDraft && selectedSubcategory.isEmpty) {
      errors['subcategory'] = 'Please select a subcategory';
    }
    if (!saveAsDraft && selectedImages.isEmpty) {
      errors['images'] = 'Add at least one product image';
    }
    if (selectedImages.length > 9) {
      errors['images'] = 'You can upload up to 9 images only.';
    }

    final parsedPrice = double.tryParse(price.trim());
    final parsedOldPrice = oldPrice.trim().isEmpty
        ? null
        : double.tryParse(oldPrice.trim());
    final parsedStock = int.tryParse(stock.trim());

    if (!saveAsDraft && titleEn.trim().isEmpty) {
      errors['titleEn'] = 'Product title is required';
    }
    if (!saveAsDraft && titleAr.trim().isEmpty) {
      errors['titleAr'] = 'Arabic title is required';
    }
    if (!saveAsDraft && descriptionEn.trim().isEmpty) {
      errors['descriptionEn'] = 'Description is required';
    }
    if (!saveAsDraft && descriptionAr.trim().isEmpty) {
      errors['descriptionAr'] = 'Arabic description is required';
    }
    if (!saveAsDraft && (parsedPrice == null || parsedPrice <= 0)) {
      errors['price'] = 'Enter a valid price greater than 0';
    }
    if (parsedOldPrice != null &&
        parsedPrice != null &&
        parsedOldPrice < parsedPrice) {
      errors['oldPrice'] = 'Old price must be greater than or equal to price';
    }
    if (!saveAsDraft && (parsedStock == null || parsedStock < 0)) {
      errors['stock'] = 'Enter a valid stock quantity';
    }
    if (!saveAsDraft && sku.trim().isEmpty) {
      errors['sku'] = 'SKU is required';
    }
    if (!saveAsDraft &&
        materialEn.trim().isEmpty &&
        materialAr.trim().isEmpty) {
      errors['material'] = 'Material is required';
    }

    validationErrors = errors;
    notifyListeners();
    final isFieldsValid = formKey?.currentState?.validate() ?? true;
    return isFieldsValid && errors.isEmpty;
  }

  Future<ProductModel?> submitProductForApproval({
    required GlobalKey<FormState> formKey,
    ProductModel? existingProduct,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String price,
    required String oldPrice,
    required String stock,
    required String sku,
    required String materialEn,
    required String materialAr,
    required String compositionEn,
    required String compositionAr,
    required String careInstructionsEn,
    required String careInstructionsAr,
  }) async {
    return _submit(
      formKey: formKey,
      existingProduct: existingProduct,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      price: price,
      oldPrice: oldPrice,
      stock: stock,
      sku: sku,
      materialEn: materialEn,
      materialAr: materialAr,
      compositionEn: compositionEn,
      compositionAr: compositionAr,
      careInstructionsEn: careInstructionsEn,
      careInstructionsAr: careInstructionsAr,
      saveAsDraftOverride: false,
    );
  }

  Future<ProductModel?> saveProductAsDraft({
    required GlobalKey<FormState> formKey,
    ProductModel? existingProduct,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String price,
    required String oldPrice,
    required String stock,
    required String sku,
    required String materialEn,
    required String materialAr,
    required String compositionEn,
    required String compositionAr,
    required String careInstructionsEn,
    required String careInstructionsAr,
  }) async {
    return _submit(
      formKey: formKey,
      existingProduct: existingProduct,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      price: price,
      oldPrice: oldPrice,
      stock: stock,
      sku: sku,
      materialEn: materialEn,
      materialAr: materialAr,
      compositionEn: compositionEn,
      compositionAr: compositionAr,
      careInstructionsEn: careInstructionsEn,
      careInstructionsAr: careInstructionsAr,
      saveAsDraftOverride: true,
    );
  }

  Future<ProductModel?> _submit({
    required GlobalKey<FormState> formKey,
    required ProductModel? existingProduct,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String price,
    required String oldPrice,
    required String stock,
    required String sku,
    required String materialEn,
    required String materialAr,
    required String compositionEn,
    required String compositionAr,
    required String careInstructionsEn,
    required String careInstructionsAr,
    required bool saveAsDraftOverride,
  }) async {
    if (!_isSeller || isSubmitting) {
      return null;
    }

    final isValid = validateProductInput(
      formKey: formKey,
      saveAsDraft: saveAsDraftOverride,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      price: price,
      oldPrice: oldPrice,
      stock: stock,
      sku: sku,
      materialEn: materialEn,
      materialAr: materialAr,
    );
    if (!isValid) {
      return null;
    }

    isSubmitting = true;
    notifyListeners();

    final product = buildProduct(
      id: existingProduct?.id,
      titleEn: titleEn.trim(),
      titleAr: titleAr.trim(),
      descriptionEn: descriptionEn.trim(),
      descriptionAr: descriptionAr.trim(),
      categoryId: _resolvedSelectedCategoryId,
      categoryName: _resolvedSelectedCategoryName,
      subcategoryId: selectedSubcategory,
      subcategoryName: selectedSubcategory,
      department: selectedDepartment,
      price: double.tryParse(price.trim()) ?? 0,
      oldPrice: oldPrice.trim().isEmpty
          ? (double.tryParse(price.trim()) ?? 0)
          : (double.tryParse(oldPrice.trim()) ?? 0),
      stock: int.tryParse(stock.trim()) ?? 0,
      sku: sku.trim(),
      colors: List<String>.from(selectedColors),
      sizes: List<String>.from(selectedSizes),
      materialEn: materialEn.trim(),
      materialAr: materialAr.trim(),
      compositionEn: compositionEn.trim(),
      compositionAr: compositionAr.trim(),
      careInstructionsEn: careInstructionsEn.trim(),
      careInstructionsAr: careInstructionsAr.trim(),
      saveAsDraft: saveAsDraftOverride,
      isReturnable: isReturnable,
      selectedImagePaths: List<String>.from(selectedImages),
      existingProduct: existingProduct,
    );
    try {
      await saveProduct(product);
      return product;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> saveProduct(ProductModel product) async {
    if (!_isSeller) return;
    await _marketplaceRepository.saveProduct(product);
    notifyListeners();
  }

  ProductModel buildProduct({
    String? id,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required String categoryId,
    required String categoryName,
    required String subcategoryId,
    required String subcategoryName,
    required String department,
    required double price,
    required double oldPrice,
    required int stock,
    required String sku,
    required List<String> colors,
    required List<String> sizes,
    required String materialEn,
    required String materialAr,
    required String compositionEn,
    required String compositionAr,
    required String careInstructionsEn,
    required String careInstructionsAr,
    required bool saveAsDraft,
    required bool isReturnable,
    required List<String> selectedImagePaths,
    ProductModel? existingProduct,
  }) {
    final variants = _buildVariants(
      baseSku: sku,
      productStock: stock,
      colors: colors,
      sizes: sizes,
      existingProduct: existingProduct,
    );
    final stockForProduct = variants.isEmpty
        ? stock
        : variants
              .where((variant) => variant.isActive)
              .fold<int>(0, (sum, variant) => sum + variant.stock);
    final status = _resolveProductStatus(
      saveAsDraft: saveAsDraft,
      stock: stockForProduct,
      existingProduct: existingProduct,
    );
    final normalizedOldPrice = oldPrice < price ? price : oldPrice;
    final discount = normalizedOldPrice > price
        ? ((1 - (price / normalizedOldPrice)) * 100).round()
        : 0;
    final now = DateTime.now();
    return ProductModel(
      id: id ?? 'seller_product_${DateTime.now().millisecondsSinceEpoch}',
      sellerId: sellerId,
      sellerName: sellerName,
      storeId: existingProduct?.storeId.isNotEmpty == true
          ? existingProduct!.storeId
          : (_storeId.isNotEmpty ? _storeId : 'store_$sellerId'),
      title: titleEn,
      titleText: LocalizedTextModel(en: titleEn, ar: titleAr),
      categoryId: categoryId,
      categoryName: categoryName,
      department: department,
      departmentId: department,
      subcategoryId: subcategoryId,
      subcategoryName: subcategoryName,
      price: price,
      oldPrice: normalizedOldPrice,
      discount: discount,
      rating: existingProduct?.rating ?? 0,
      reviewCount: existingProduct?.reviewCount ?? 0,
      imageUrl: selectedImagePaths.isNotEmpty ? selectedImagePaths.first : null,
      imageUrls: selectedImagePaths,
      localImagePaths: selectedImagePaths,
      colors: colors,
      sizes: sizes,
      description: descriptionEn,
      descriptionText: LocalizedTextModel(en: descriptionEn, ar: descriptionAr),
      material: materialEn.isNotEmpty ? materialEn : materialAr,
      materialText: LocalizedTextModel(en: materialEn, ar: materialAr),
      composition: compositionEn.isNotEmpty ? compositionEn : compositionAr,
      compositionText: LocalizedTextModel(en: compositionEn, ar: compositionAr),
      careInstructions: careInstructionsEn.isNotEmpty
          ? careInstructionsEn
          : careInstructionsAr,
      careInstructionsText: LocalizedTextModel(
        en: careInstructionsEn,
        ar: careInstructionsAr,
      ),
      sku: sku,
      stock: stockForProduct,
      tags: const ['Seller Listing'],
      isNew: existingProduct?.isNew ?? true,
      isHot: existingProduct?.isHot ?? false,
      isFlashSale: existingProduct?.isFlashSale ?? false,
      soldCount: existingProduct?.soldCount ?? 0,
      status: status,
      isActive: status == ProductStatus.active,
      isReturnable: isReturnable,
      views: existingProduct?.views ?? 0,
      createdAt: existingProduct?.createdAt ?? now,
      updatedAt: now,
      publishedAt: _isPublishedStatus(status)
          ? (existingProduct?.publishedAt ?? now)
          : existingProduct?.publishedAt,
      variants: variants,
      weight: existingProduct?.weight ?? 0,
      dimensions: existingProduct?.dimensions ?? const {},
      countryOfOrigin: existingProduct?.countryOfOrigin ?? 'United States',
      lowStockThreshold: existingProduct?.lowStockThreshold ?? 5,
      complaintCount: existingProduct?.complaintCount ?? 0,
      returnRate: existingProduct?.returnRate ?? 0,
    );
  }

  Future<ProductModel?> deleteProduct(String productId) async {
    if (!_isSeller) return null;
    final matches = catalogProducts.where((item) => item.id == productId);
    final product = matches.isEmpty ? null : matches.first;
    if (product == null) return null;
    final nextProduct = product.copyWith(
      status: ProductStatus.deleted,
      isActive: false,
      deletedAt: DateTime.now(),
    );
    await saveProduct(nextProduct);
    return nextProduct;
  }

  Future<ProductModel?> duplicateProduct(ProductModel product) async {
    if (!_isSeller) return null;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nextProduct = product.copyWith(
      id: 'seller_product_$timestamp',
      sku: '${product.sku}-COPY-$timestamp',
      status: ProductStatus.draft,
      isActive: false,
      clearPublishedAt: true,
    );
    await saveProduct(nextProduct);
    return nextProduct;
  }

  Future<ProductModel?> changeStock(String productId, int stock) async {
    if (!_isSeller) return null;
    final matches = products.where((item) => item.id == productId);
    final product = matches.isEmpty ? null : matches.first;
    if (product == null) return null;
    if (stock < 0) return product;
    final wasOutOfStock = product.status == ProductStatus.outOfStock;
    final nextStatus = stock == 0
        ? ProductStatus.outOfStock
        : (wasOutOfStock
              ? (requiresProductApproval
                    ? ProductStatus.pendingApproval
                    : ProductStatus.active)
              : product.status);
    final nextProduct = product.copyWith(
      stock: stock,
      status: nextStatus,
      isActive: nextStatus == ProductStatus.active,
      clearPublishedAt: nextStatus == ProductStatus.pendingApproval,
    );
    await saveProduct(nextProduct);
    return nextProduct;
  }

  Future<ProductModel?> changePrice(String productId, double price) async {
    if (!_isSeller) return null;
    final matches = products.where((item) => item.id == productId);
    final product = matches.isEmpty ? null : matches.first;
    if (product == null) return null;
    if (price <= 0) return product;
    final nextStatus =
        requiresProductApproval && product.status == ProductStatus.active
        ? ProductStatus.pendingApproval
        : product.status;
    final nextOldPrice = product.oldPrice < price ? price : product.oldPrice;
    final discount = nextOldPrice > price
        ? ((1 - (price / nextOldPrice)) * 100).round()
        : 0;
    final nextProduct = product.copyWith(
      price: price,
      oldPrice: nextOldPrice,
      discount: discount,
      status: nextStatus,
      isActive: nextStatus == ProductStatus.active,
      clearPublishedAt: nextStatus == ProductStatus.pendingApproval,
    );
    await saveProduct(nextProduct);
    return nextProduct;
  }

  Future<ProductModel?> toggleActive(String productId) async {
    if (!_isSeller) return null;
    final matches = products.where((item) => item.id == productId);
    final product = matches.isEmpty ? null : matches.first;
    if (product == null) return null;
    final nextActive = !product.isActive;
    final nextStatus = !nextActive
        ? ProductStatus.inactive
        : (requiresProductApproval
              ? ProductStatus.pendingApproval
              : ProductStatus.active);
    final nextProduct = product.copyWith(
      isActive: nextStatus == ProductStatus.active,
      status: nextStatus,
      publishedAt: nextStatus == ProductStatus.active
          ? (product.publishedAt ?? DateTime.now())
          : product.publishedAt,
      clearPublishedAt: nextStatus == ProductStatus.pendingApproval,
    );
    await saveProduct(nextProduct);
    return nextProduct;
  }

  bool isPublicListing(ProductModel product) {
    return _mockDataService.isProductPublic(product);
  }

  Future<void> _loadSellerContext() async {
    if (!_isSeller || sellerId.isEmpty) {
      return;
    }
    final settings = await _adminRepository.getPlatformSettings();
    final categories = await _marketplaceRepository.getCategories();
    final store = await _marketplaceRepository.getStoreBySellerId(sellerId);
    _platformSettings = settings;
    _categories = categories;
    _store = store;
    _storeId = store?.id ?? 'store_$sellerId';
    notifyListeners();
  }

  ProductStatus _resolveProductStatus({
    required bool saveAsDraft,
    required int stock,
    ProductModel? existingProduct,
  }) {
    if (saveAsDraft) {
      return ProductStatus.draft;
    }
    if (stock == 0) {
      return ProductStatus.outOfStock;
    }
    if (existingProduct != null &&
        existingProduct.status == ProductStatus.rejected) {
      return requiresProductApproval
          ? ProductStatus.pendingApproval
          : ProductStatus.active;
    }
    return requiresProductApproval
        ? ProductStatus.pendingApproval
        : ProductStatus.active;
  }

  bool _isPublishedStatus(ProductStatus status) {
    return status == ProductStatus.active || status == ProductStatus.outOfStock;
  }

  CategoryModel? _resolveCategoryForProduct(ProductModel product) {
    final byId = _categoryById(product.categoryId);
    if (byId != null) {
      return byId;
    }
    final normalizedName = product.categoryName.trim().toLowerCase();
    final byName = _categories.where(
      (category) =>
          category.nameText.en.trim().toLowerCase() == normalizedName ||
          category.nameText.ar.trim().toLowerCase() == normalizedName,
    );
    return byName.isEmpty ? null : byName.first;
  }

  bool _isCategoryAllowed(String categoryId) {
    final allowedIds = _store?.allowedCategoryIds ?? const <String>[];
    if (allowedIds.isEmpty) {
      return _categoryById(categoryId)?.isActive ?? false;
    }
    return allowedIds.contains(categoryId);
  }

  String get _resolvedSelectedCategoryId {
    final category = _categoryById(selectedCategory);
    return category?.id ?? selectedCategory;
  }

  String get _resolvedSelectedCategoryName {
    final category = _categoryById(selectedCategory);
    return category?.nameText.en ?? selectedCategory;
  }

  List<ProductVariantModel> _buildVariants({
    required String baseSku,
    required int productStock,
    required List<String> colors,
    required List<String> sizes,
    ProductModel? existingProduct,
  }) {
    if (colors.isEmpty && sizes.isEmpty) {
      return const [];
    }
    final existingByKey = {
      for (final variant
          in existingProduct?.variants ?? const <ProductVariantModel>[])
        '${variant.color}::${variant.size}': variant,
    };
    final colorOptions = colors.isEmpty ? const [''] : colors;
    final sizeOptions = sizes.isEmpty ? const [''] : sizes;
    final total = colorOptions.length * sizeOptions.length;
    final baseStock = total == 0 ? 0 : productStock ~/ total;
    var remainder = total == 0 ? 0 : productStock % total;
    final variants = <ProductVariantModel>[];
    for (final color in colorOptions) {
      for (final size in sizeOptions) {
        final key = '$color::$size';
        final existing = existingByKey[key];
        final stock = existing?.stock ?? (baseStock + (remainder > 0 ? 1 : 0));
        if (remainder > 0 && existing == null) {
          remainder -= 1;
        }
        variants.add(
          ProductVariantModel(
            id: existing?.id ?? 'variant_${baseSku}_${variants.length + 1}',
            color: color,
            size: size,
            sku:
                existing?.sku ??
                [
                      baseSku,
                      if (color.isNotEmpty) color,
                      if (size.isNotEmpty) size,
                    ]
                    .join('_')
                    .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
                    .toUpperCase(),
            stock: stock,
            priceAdjustment: existing?.priceAdjustment ?? 0,
            isActive: existing?.isActive ?? true,
          ),
        );
      }
    }
    return variants;
  }
}
