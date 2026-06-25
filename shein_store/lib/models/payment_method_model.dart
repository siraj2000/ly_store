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

  PaymentMethodModel copyWith({bool? isDefault}) {
    return PaymentMethodModel(
      id: id,
      brand: brand,
      maskedNumber: maskedNumber,
      token: token,
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
