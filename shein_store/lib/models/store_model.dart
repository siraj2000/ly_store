import 'package:flutter/widgets.dart';

import 'localized_text_model.dart';

class StoreModel {
  const StoreModel({
    required this.id,
    required this.sellerId,
    required this.nameText,
    required this.descriptionText,
    required this.policiesText,
    this.addressText = const LocalizedTextModel(en: '', ar: ''),
    this.storePhone = '',
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
    this.commissionPercentage = 12,
    this.allowedCategoryIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.suspendedAt,
    this.suspensionReason = '',
  });

  final String id;
  final String sellerId;
  final LocalizedTextModel nameText;
  final LocalizedTextModel descriptionText;
  final LocalizedTextModel policiesText;
  final LocalizedTextModel addressText;
  final String storePhone;
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
  final double commissionPercentage;
  final List<String> allowedCategoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? suspendedAt;
  final String suspensionReason;

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
    LocalizedTextModel? addressText,
    String? storePhone,
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
    double? commissionPercentage,
    List<String>? allowedCategoryIds,
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
      addressText: addressText ?? this.addressText,
      storePhone: storePhone ?? this.storePhone,
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
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      allowedCategoryIds: allowedCategoryIds ?? this.allowedCategoryIds,
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
      commissionPercentage:
          (json['commissionPercentage'] as num?)?.toDouble() ?? 12,
      allowedCategoryIds: (json['allowedCategoryIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
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
    'addressText': addressText.toJson(),
    'storePhone': storePhone,
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
    'commissionPercentage': commissionPercentage,
    'allowedCategoryIds': allowedCategoryIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'suspendedAt': suspendedAt?.toIso8601String(),
    'suspensionReason': suspensionReason,
  };
}
