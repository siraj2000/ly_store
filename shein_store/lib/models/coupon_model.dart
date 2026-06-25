class CouponModel {
  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.amount,
    required this.minimumSpend,
    this.isPercentage = false,
    this.status = 'available',
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final double amount;
  final double minimumSpend;
  final bool isPercentage;
  final String status;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      minimumSpend: (json['minimumSpend'] as num?)?.toDouble() ?? 0,
      isPercentage: json['isPercentage'] as bool? ?? false,
      status: json['status'] as String? ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'description': description,
    'amount': amount,
    'minimumSpend': minimumSpend,
    'isPercentage': isPercentage,
    'status': status,
  };
}
