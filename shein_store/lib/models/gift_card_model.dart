class GiftCardModel {
  const GiftCardModel({
    required this.id,
    required this.code,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.isActive = true,
    this.isRedeemed = false,
    this.redeemedBy = '',
    this.redeemedAt,
    this.expiresAt,
    this.status = 'active',
  });

  final String id;
  final String code;
  final double amount;
  final String currency;
  final bool isActive;
  final bool isRedeemed;
  final String redeemedBy;
  final DateTime? redeemedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String status;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  GiftCardModel copyWith({
    bool? isActive,
    bool? isRedeemed,
    String? redeemedBy,
    DateTime? redeemedAt,
    String? status,
  }) {
    return GiftCardModel(
      id: id,
      code: code,
      amount: amount,
      currency: currency,
      isActive: isActive ?? this.isActive,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      redeemedBy: redeemedBy ?? this.redeemedBy,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  factory GiftCardModel.fromJson(Map<String, dynamic> json) {
    return GiftCardModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'LYD',
      isActive: json['isActive'] as bool? ?? true,
      isRedeemed: json['isRedeemed'] as bool? ?? false,
      redeemedBy: json['redeemedBy'] as String? ?? '',
      redeemedAt: json['redeemedAt'] == null
          ? null
          : DateTime.tryParse(json['redeemedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'] as String),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'amount': amount,
    'currency': currency,
    'isActive': isActive,
    'isRedeemed': isRedeemed,
    'redeemedBy': redeemedBy,
    'redeemedAt': redeemedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
}
