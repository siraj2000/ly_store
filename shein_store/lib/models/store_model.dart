import 'package:flutter/widgets.dart';

import 'localized_text_model.dart';

class StoreStatusIds {
  const StoreStatusIds._();

  static const active = 'active';
  static const inactive = 'inactive';
  static const suspended = 'suspended';
  static const closed = 'closed';
  static const vacation = 'vacation';
}

class StoreApprovalStatusIds {
  const StoreApprovalStatusIds._();

  static const draft = 'draft';
  static const pendingApproval = 'pending_approval';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const changesRequested = 'changes_requested';
}

class StoreModel {
  const StoreModel({
    required this.id,
    required this.sellerId,
    required this.nameText,
    required this.descriptionText,
    required this.policiesText,
    this.storeSlug = '',
    this.addressText = const LocalizedTextModel(en: '', ar: ''),
    this.storePhone = '',
    this.email = '',
    this.city = '',
    this.countryCode = '',
    this.businessActivityType = 'mixed',
    this.logoUrl,
    this.localLogoPath,
    this.bannerUrl,
    this.localBannerPath,
    this.rating = 0,
    this.reviewCount = 0,
    this.followersCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isVerified = false,
    this.vacationMode = false,
    this.vacationMessage = '',
    this.commissionPercentage = 12,
    this.allowedCategoryIds = const [],
    String? status,
    String? approvalStatus,
    this.productsCount = 0,
    this.completedOrdersCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.suspendedAt,
    this.suspensionReason = '',
  }) : status =
           status ??
           (suspendedAt != null
               ? StoreStatusIds.suspended
               : vacationMode
               ? StoreStatusIds.vacation
               : isActive
               ? StoreStatusIds.active
               : StoreStatusIds.inactive),
       approvalStatus = approvalStatus ?? StoreApprovalStatusIds.approved;

  final String id;
  final String sellerId;
  final LocalizedTextModel nameText;
  final LocalizedTextModel descriptionText;
  final LocalizedTextModel policiesText;
  final String storeSlug;
  final LocalizedTextModel addressText;
  final String storePhone;
  final String email;
  final String city;
  final String countryCode;
  final String businessActivityType;
  final String? logoUrl;
  final String? localLogoPath;
  final String? bannerUrl;
  final String? localBannerPath;
  final double rating;
  final int reviewCount;
  final int followersCount;
  final bool isActive;
  final bool isFeatured;
  final bool isVerified;
  final bool vacationMode;
  final String vacationMessage;
  final double commissionPercentage;
  final List<String> allowedCategoryIds;
  final String status;
  final String approvalStatus;
  final int productsCount;
  final int completedOrdersCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? suspendedAt;
  final String suspensionReason;

  String get storeName => nameText.en;
  String get description => descriptionText.en;
  String get phone => storePhone;
  String get address => addressText.en;
  String get country => countryCode;
  String get businessTypeId => businessActivityType;
  String? get coverUrl => bannerUrl;
  double get ratingAverage => rating;
  int get ratingCount => reviewCount;
  bool get canSell =>
      status == StoreStatusIds.active &&
      approvalStatus == StoreApprovalStatusIds.approved &&
      isActive &&
      suspendedAt == null &&
      !vacationMode;

  String resolvedName(Locale locale) => nameText.valueFor(locale);
  String localizedName(Locale locale) => resolvedName(locale);

  String resolvedDescription(Locale locale) => descriptionText.valueFor(locale);
  String localizedDescription(Locale locale) => resolvedDescription(locale);

  String resolvedPolicies(Locale locale) => policiesText.valueFor(locale);

  String resolvedAddress(Locale locale) => addressText.valueFor(locale);
  String localizedAddress(Locale locale) => resolvedAddress(locale);

  StoreModel copyWith({
    String? id,
    String? sellerId,
    LocalizedTextModel? nameText,
    LocalizedTextModel? descriptionText,
    LocalizedTextModel? policiesText,
    String? storeSlug,
    LocalizedTextModel? addressText,
    String? storePhone,
    String? email,
    String? city,
    String? countryCode,
    String? businessActivityType,
    String? logoUrl,
    String? localLogoPath,
    String? bannerUrl,
    String? localBannerPath,
    double? rating,
    int? reviewCount,
    int? followersCount,
    bool? isActive,
    bool? isFeatured,
    bool? isVerified,
    bool? vacationMode,
    String? vacationMessage,
    double? commissionPercentage,
    List<String>? allowedCategoryIds,
    String? status,
    String? approvalStatus,
    int? productsCount,
    int? completedOrdersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? suspendedAt,
    bool clearSuspendedAt = false,
    String? suspensionReason,
  }) {
    return StoreModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      nameText: nameText ?? this.nameText,
      descriptionText: descriptionText ?? this.descriptionText,
      policiesText: policiesText ?? this.policiesText,
      storeSlug: storeSlug ?? this.storeSlug,
      addressText: addressText ?? this.addressText,
      storePhone: storePhone ?? this.storePhone,
      email: email ?? this.email,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      businessActivityType: businessActivityType ?? this.businessActivityType,
      logoUrl: logoUrl ?? this.logoUrl,
      localLogoPath: localLogoPath ?? this.localLogoPath,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      localBannerPath: localBannerPath ?? this.localBannerPath,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      followersCount: followersCount ?? this.followersCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      vacationMode: vacationMode ?? this.vacationMode,
      vacationMessage: vacationMessage ?? this.vacationMessage,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      allowedCategoryIds: allowedCategoryIds ?? this.allowedCategoryIds,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      productsCount: productsCount ?? this.productsCount,
      completedOrdersCount: completedOrdersCount ?? this.completedOrdersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      suspendedAt: clearSuspendedAt ? null : (suspendedAt ?? this.suspendedAt),
      suspensionReason: suspensionReason ?? this.suspensionReason,
    );
  }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      nameText: json['nameText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['nameText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(
              en: json['name'] as String? ?? '',
              ar: json['name'] as String? ?? '',
            ),
      descriptionText: json['descriptionText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['descriptionText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(
              en: json['description'] as String? ?? '',
              ar: json['description'] as String? ?? '',
            ),
      policiesText: json['policiesText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['policiesText'] as Map<String, dynamic>,
            )
          : const LocalizedTextModel(en: '', ar: ''),
      storeSlug: json['storeSlug'] as String? ?? json['slug'] as String? ?? '',
      addressText: json['addressText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['addressText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(
              en: json['address'] as String? ?? '',
              ar: json['address'] as String? ?? '',
            ),
      storePhone:
          json['storePhone'] as String? ?? json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      countryCode:
          json['countryCode'] as String? ?? json['country'] as String? ?? '',
      businessActivityType: json['businessActivityType'] as String? ?? 'mixed',
      logoUrl: json['logoUrl'] as String?,
      localLogoPath: json['localLogoPath'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      localBannerPath: json['localBannerPath'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      followersCount: json['followersCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      vacationMode: json['vacationMode'] as bool? ?? false,
      vacationMessage: json['vacationMessage'] as String? ?? '',
      commissionPercentage:
          (json['commissionPercentage'] as num?)?.toDouble() ?? 12,
      allowedCategoryIds: (json['allowedCategoryIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      status: json['status'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
      completedOrdersCount:
          (json['completedOrdersCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      suspendedAt: json['suspendedAt'] == null
          ? null
          : DateTime.tryParse(json['suspendedAt'] as String),
      suspensionReason: json['suspensionReason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerId': sellerId,
    'nameText': nameText.toJson(),
    'descriptionText': descriptionText.toJson(),
    'policiesText': policiesText.toJson(),
    'storeSlug': storeSlug,
    'addressText': addressText.toJson(),
    'storePhone': storePhone,
    'email': email,
    'city': city,
    'countryCode': countryCode,
    'businessActivityType': businessActivityType,
    'logoUrl': logoUrl,
    'localLogoPath': localLogoPath,
    'bannerUrl': bannerUrl,
    'localBannerPath': localBannerPath,
    'rating': rating,
    'reviewCount': reviewCount,
    'followersCount': followersCount,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'isVerified': isVerified,
    'vacationMode': vacationMode,
    'vacationMessage': vacationMessage,
    'commissionPercentage': commissionPercentage,
    'allowedCategoryIds': allowedCategoryIds,
    'status': status,
    'approvalStatus': approvalStatus,
    'productsCount': productsCount,
    'completedOrdersCount': completedOrdersCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'suspendedAt': suspendedAt?.toIso8601String(),
    'suspensionReason': suspensionReason,
  };
}
