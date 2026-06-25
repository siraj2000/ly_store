import 'package:flutter/widgets.dart';

import 'localized_text_model.dart';

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.departmentId,
    required this.nameText,
    this.parentCategoryId,
    this.descriptionText = const LocalizedTextModel(en: '', ar: ''),
    this.imageUrl,
    this.localImagePath,
    this.iconName,
    this.subcategories = const [],
    this.bannerTitle = '',
    this.displayOrder = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _SeedDate.value,
       updatedAt = updatedAt ?? createdAt ?? _SeedDate.value;

  final String id;
  final String departmentId;
  final String? parentCategoryId;
  final LocalizedTextModel nameText;
  final LocalizedTextModel descriptionText;
  final String? imageUrl;
  final String? localImagePath;
  final String? iconName;
  final List<String> subcategories;
  final String bannerTitle;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get name => nameText.en;
  String get department => departmentId;

  String localizedName(Locale locale) => nameText.valueFor(locale);

  CategoryModel copyWith({
    String? id,
    String? departmentId,
    String? parentCategoryId,
    bool clearParentCategoryId = false,
    LocalizedTextModel? nameText,
    LocalizedTextModel? descriptionText,
    String? imageUrl,
    bool clearImageUrl = false,
    String? localImagePath,
    bool clearLocalImagePath = false,
    String? iconName,
    bool clearIconName = false,
    List<String>? subcategories,
    String? bannerTitle,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      parentCategoryId: clearParentCategoryId
          ? null
          : (parentCategoryId ?? this.parentCategoryId),
      nameText: nameText ?? this.nameText,
      descriptionText: descriptionText ?? this.descriptionText,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      localImagePath: clearLocalImagePath
          ? null
          : (localImagePath ?? this.localImagePath),
      iconName: clearIconName ? null : (iconName ?? this.iconName),
      subcategories: subcategories ?? this.subcategories,
      bannerTitle: bannerTitle ?? this.bannerTitle,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawNameText = json['nameText'];
    final rawDescriptionText = json['descriptionText'];
    final legacyName = json['name'] as String? ?? '';
    final legacyDepartment = json['department'] as String? ?? '';

    return CategoryModel(
      id: json['id'] as String? ?? '',
      departmentId:
          json['departmentId'] as String? ??
          legacyDepartment.ifEmpty(legacyName.toLowerCase()),
      parentCategoryId: json['parentCategoryId'] as String?,
      nameText: rawNameText is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(rawNameText)
          : LocalizedTextModel(en: legacyName, ar: legacyName),
      descriptionText: rawDescriptionText is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(rawDescriptionText)
          : LocalizedTextModel(
              en: json['description'] as String? ?? '',
              ar: json['descriptionAr'] as String? ?? '',
            ),
      imageUrl: json['imageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      iconName: json['iconName'] as String?,
      subcategories: (json['subcategories'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      bannerTitle: json['bannerTitle'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          _SeedDate.value,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          _SeedDate.value,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'departmentId': departmentId,
    'department': departmentId,
    'parentCategoryId': parentCategoryId,
    'name': name,
    'nameText': nameText.toJson(),
    'descriptionText': descriptionText.toJson(),
    'imageUrl': imageUrl,
    'localImagePath': localImagePath,
    'iconName': iconName,
    'subcategories': subcategories,
    'bannerTitle': bannerTitle,
    'displayOrder': displayOrder,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

class _SeedDate {
  static final DateTime value = DateTime(2025, 1, 1);
}
