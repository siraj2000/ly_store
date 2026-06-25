class PlatformSettingModel {
  const PlatformSettingModel({
    required this.platformName,
    required this.defaultLanguageCode,
    required this.defaultCurrencyCode,
    required this.requiresProductApproval,
    required this.defaultCommissionRate,
    required this.minimumPayoutAmount,
    required this.refundMakerCheckerThreshold,
  });

  final String platformName;
  final String defaultLanguageCode;
  final String defaultCurrencyCode;
  final bool requiresProductApproval;
  final double defaultCommissionRate;
  final double minimumPayoutAmount;
  final double refundMakerCheckerThreshold;

  PlatformSettingModel copyWith({
    String? platformName,
    String? defaultLanguageCode,
    String? defaultCurrencyCode,
    bool? requiresProductApproval,
    double? defaultCommissionRate,
    double? minimumPayoutAmount,
    double? refundMakerCheckerThreshold,
  }) {
    return PlatformSettingModel(
      platformName: platformName ?? this.platformName,
      defaultLanguageCode: defaultLanguageCode ?? this.defaultLanguageCode,
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      requiresProductApproval:
          requiresProductApproval ?? this.requiresProductApproval,
      defaultCommissionRate:
          defaultCommissionRate ?? this.defaultCommissionRate,
      minimumPayoutAmount: minimumPayoutAmount ?? this.minimumPayoutAmount,
      refundMakerCheckerThreshold:
          refundMakerCheckerThreshold ?? this.refundMakerCheckerThreshold,
    );
  }

  factory PlatformSettingModel.fromJson(Map<String, dynamic> json) {
    return PlatformSettingModel(
      platformName: json['platformName'] as String? ?? 'StyleHub',
      defaultLanguageCode: json['defaultLanguageCode'] as String? ?? 'en',
      defaultCurrencyCode: json['defaultCurrencyCode'] as String? ?? 'USD',
      requiresProductApproval:
          json['requiresProductApproval'] as bool? ?? false,
      defaultCommissionRate:
          (json['defaultCommissionRate'] as num?)?.toDouble() ?? 0.12,
      minimumPayoutAmount:
          (json['minimumPayoutAmount'] as num?)?.toDouble() ?? 50,
      refundMakerCheckerThreshold:
          (json['refundMakerCheckerThreshold'] as num?)?.toDouble() ?? 150,
    );
  }

  Map<String, dynamic> toJson() => {
    'platformName': platformName,
    'defaultLanguageCode': defaultLanguageCode,
    'defaultCurrencyCode': defaultCurrencyCode,
    'requiresProductApproval': requiresProductApproval,
    'defaultCommissionRate': defaultCommissionRate,
    'minimumPayoutAmount': minimumPayoutAmount,
    'refundMakerCheckerThreshold': refundMakerCheckerThreshold,
  };
}
