class CustomerPointsTransactionModel {
  const CustomerPointsTransactionModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
    this.orderId = '',
    this.expiresAt,
    this.status = 'completed',
  });

  final String id;
  final String customerId;
  final String orderId;
  final String type;
  final int points;
  final String description;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status;

  factory CustomerPointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return CustomerPointsTransactionModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'] as String),
      status: json['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'orderId': orderId,
    'type': type,
    'points': points,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status,
  };
}
