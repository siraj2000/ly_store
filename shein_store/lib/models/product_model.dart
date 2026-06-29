import 'package:flutter/widgets.dart';

import 'localized_text_model.dart';
import 'product_status.dart';
import 'product_variant_model.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.storeId = '',
    required this.title,
    LocalizedTextModel? titleText,
    required this.categoryId,
    required this.categoryName,
    required this.department,
    this.departmentId = '',
    this.subcategoryId = '',
    this.subcategoryName = '',
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    String? imageUrl,
    this.imageUrls = const [],
    // Local image paths are used for demo only. Replace with uploaded API image URLs later.
    this.localImagePaths = const [],
    required this.colors,
    required this.sizes,
    required this.description,
    LocalizedTextModel? descriptionText,
    required this.material,
    LocalizedTextModel? materialText,
    required this.composition,
    LocalizedTextModel? compositionText,
    required this.careInstructions,
    LocalizedTextModel? careInstructionsText,
    required this.sku,
    required this.stock,
    required this.tags,
    required this.isNew,
    required this.isHot,
    required this.isFlashSale,
    required this.soldCount,
    this.status = ProductStatus.active,
    this.isActive = true,
    this.isReturnable = true,
    this.views = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.publishedAt,
    this.deletedAt,
    this.rejectionReason,
    this.suspensionReason,
    this.variants = const [],
    this.weight = 0,
    this.dimensions = const {},
    this.countryOfOrigin = '',
    this.lowStockThreshold = 5,
    this.complaintCount = 0,
    this.returnRate = 0,
  }) : imageUrl = imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null),
       titleText = titleText ?? LocalizedTextModel(en: title, ar: title),
       descriptionText =
           descriptionText ??
           LocalizedTextModel(en: description, ar: description),
       materialText =
           materialText ?? LocalizedTextModel(en: material, ar: material),
       compositionText =
           compositionText ??
           LocalizedTextModel(en: composition, ar: composition),
       careInstructionsText =
           careInstructionsText ??
           LocalizedTextModel(en: careInstructions, ar: careInstructions),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String sellerId;
  final String sellerName;
  final String storeId;
  final String title;
  final LocalizedTextModel titleText;
  final String categoryId;
  final String categoryName;
  final String department;
  final String departmentId;
  final String subcategoryId;
  final String subcategoryName;
  final double price;
  final double oldPrice;
  final int discount;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<String> localImagePaths;
  final List<String> colors;
  final List<String> sizes;
  final String description;
  final LocalizedTextModel descriptionText;
  final String material;
  final LocalizedTextModel materialText;
  final String composition;
  final LocalizedTextModel compositionText;
  final String careInstructions;
  final LocalizedTextModel careInstructionsText;
  final String sku;
  final int stock;
  final List<String> tags;
  final bool isNew;
  final bool isHot;
  final bool isFlashSale;
  final int soldCount;
  final ProductStatus status;
  final bool isActive;
  final bool isReturnable;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final DateTime? deletedAt;
  final String? rejectionReason;
  final String? suspensionReason;
  final List<ProductVariantModel> variants;
  final double weight;
  final Map<String, double> dimensions;
  final String countryOfOrigin;
  final int lowStockThreshold;
  final int complaintCount;
  final double returnRate;

  @Deprecated('Use imageUrl instead.')
  String? get primaryImage => imageUrl;

  @Deprecated('Use imageUrls instead.')
  List<String> get images => imageUrls;

  String get statusId => status.id;
  bool get isDeleted => status == ProductStatus.deleted || deletedAt != null;

  String resolvedTitle(Locale locale) => titleText.valueFor(locale);

  String resolvedDescription(Locale locale) => descriptionText.valueFor(locale);

  String resolvedMaterial(Locale locale) => materialText.valueFor(locale);

  String resolvedComposition(Locale locale) => compositionText.valueFor(locale);

  String resolvedCareInstructions(Locale locale) =>
      careInstructionsText.valueFor(locale);

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? storeId,
    String? title,
    LocalizedTextModel? titleText,
    String? categoryId,
    String? categoryName,
    String? department,
    String? departmentId,
    String? subcategoryId,
    String? subcategoryName,
    double? price,
    double? oldPrice,
    int? discount,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? localImagePaths,
    List<String>? colors,
    List<String>? sizes,
    String? description,
    LocalizedTextModel? descriptionText,
    String? material,
    LocalizedTextModel? materialText,
    String? composition,
    LocalizedTextModel? compositionText,
    String? careInstructions,
    LocalizedTextModel? careInstructionsText,
    String? sku,
    int? stock,
    List<String>? tags,
    bool? isNew,
    bool? isHot,
    bool? isFlashSale,
    int? soldCount,
    ProductStatus? status,
    bool? isActive,
    bool? isReturnable,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    bool clearPublishedAt = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? rejectionReason,
    String? suspensionReason,
    List<ProductVariantModel>? variants,
    double? weight,
    Map<String, double>? dimensions,
    String? countryOfOrigin,
    int? lowStockThreshold,
    int? complaintCount,
    double? returnRate,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      storeId: storeId ?? this.storeId,
      title: title ?? this.title,
      titleText: titleText ?? this.titleText,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      discount: discount ?? this.discount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      localImagePaths: localImagePaths ?? this.localImagePaths,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      description: description ?? this.description,
      descriptionText: descriptionText ?? this.descriptionText,
      material: material ?? this.material,
      materialText: materialText ?? this.materialText,
      composition: composition ?? this.composition,
      compositionText: compositionText ?? this.compositionText,
      careInstructions: careInstructions ?? this.careInstructions,
      careInstructionsText: careInstructionsText ?? this.careInstructionsText,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      isNew: isNew ?? this.isNew,
      isHot: isHot ?? this.isHot,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      soldCount: soldCount ?? this.soldCount,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isReturnable: isReturnable ?? this.isReturnable,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      rejectionReason: rejectionReason ?? this.rejectionReason,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      variants: variants ?? this.variants,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      complaintCount: complaintCount ?? this.complaintCount,
      returnRate: returnRate ?? this.returnRate,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final legacyTitle = json['title'] as String? ?? '';
    final legacyDescription = json['description'] as String? ?? '';
    final legacyMaterial = json['material'] as String? ?? '';
    final legacyComposition = json['composition'] as String? ?? '';
    final legacyCareInstructions = json['careInstructions'] as String? ?? '';

    return ProductModel(
      id: json['id'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      storeId:
          json['storeId'] as String? ??
          'store_${json['sellerId'] as String? ?? ''}',
      title: legacyTitle,
      titleText: json['titleText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['titleText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(en: legacyTitle, ar: legacyTitle),
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      departmentId:
          json['departmentId'] as String? ??
          json['department'] as String? ??
          '',
      subcategoryId:
          json['subcategoryId'] as String? ??
          json['subcategoryName'] as String? ??
          '',
      subcategoryName: json['subcategoryName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble() ?? 0,
      discount: json['discount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      localImagePaths: (json['localImagePaths'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      description: legacyDescription,
      descriptionText: json['descriptionText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['descriptionText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(en: legacyDescription, ar: legacyDescription),
      material: legacyMaterial,
      materialText: json['materialText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['materialText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(en: legacyMaterial, ar: legacyMaterial),
      composition: legacyComposition,
      compositionText: json['compositionText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['compositionText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(en: legacyComposition, ar: legacyComposition),
      careInstructions: legacyCareInstructions,
      careInstructionsText: json['careInstructionsText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['careInstructionsText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(
              en: legacyCareInstructions,
              ar: legacyCareInstructions,
            ),
      sku: json['sku'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      isNew: json['isNew'] as bool? ?? false,
      isHot: json['isHot'] as bool? ?? false,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      soldCount: json['soldCount'] as int? ?? 0,
      status: ProductStatus.fromStorage(json['status'] as String?),
      isActive: json['isActive'] as bool? ?? true,
      isReturnable: json['isReturnable'] as bool? ?? true,
      views: json['views'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      suspensionReason: json['suspensionReason'] as String?,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ProductVariantModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      dimensions: (json['dimensions'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      countryOfOrigin: json['countryOfOrigin'] as String? ?? '',
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      complaintCount: json['complaintCount'] as int? ?? 0,
      returnRate: (json['returnRate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'storeId': storeId,
    'title': title,
    'titleText': titleText.toJson(),
    'categoryId': categoryId,
    'categoryName': categoryName,
    'department': department,
    'departmentId': departmentId,
    'subcategoryId': subcategoryId,
    'subcategoryName': subcategoryName,
    'price': price,
    'oldPrice': oldPrice,
    'discount': discount,
    'rating': rating,
    'reviewCount': reviewCount,
    'imageUrl': imageUrl,
    'imageUrls': imageUrls,
    'localImagePaths': localImagePaths,
    'colors': colors,
    'sizes': sizes,
    'description': description,
    'descriptionText': descriptionText.toJson(),
    'material': material,
    'materialText': materialText.toJson(),
    'composition': composition,
    'compositionText': compositionText.toJson(),
    'careInstructions': careInstructions,
    'careInstructionsText': careInstructionsText.toJson(),
    'sku': sku,
    'stock': stock,
    'tags': tags,
    'isNew': isNew,
    'isHot': isHot,
    'isFlashSale': isFlashSale,
    'soldCount': soldCount,
    'status': status.id,
    'isActive': isActive,
    'isReturnable': isReturnable,
    'views': views,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'rejectionReason': rejectionReason,
    'suspensionReason': suspensionReason,
    'variants': variants.map((item) => item.toJson()).toList(),
    'weight': weight,
    'dimensions': dimensions,
    'countryOfOrigin': countryOfOrigin,
    'lowStockThreshold': lowStockThreshold,
    'complaintCount': complaintCount,
    'returnRate': returnRate,
  };
}
