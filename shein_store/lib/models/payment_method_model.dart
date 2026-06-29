class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.maskedNumber,
    required this.token,
    this.isDefault = false,
  });

  final String id;
  final String brand;
  final String maskedNumber;
  final String token;
  final bool isDefault;

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? maskedNumber,
    String? token,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      token: token ?? this.token,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      maskedNumber: json['maskedNumber'] as String? ?? '',
      token: json['token'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'maskedNumber': maskedNumber,
    'token': token,
    'isDefault': isDefault,
  };
}
