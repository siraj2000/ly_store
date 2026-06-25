class StoreReviewModel {
  const StoreReviewModel({
    required this.id,
    required this.storeId,
    required this.sellerId,
    required this.customerId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.verifiedPurchase,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String sellerId;
  final String customerId;
  final String orderId;
  final int rating;
  final String comment;
  final bool verifiedPurchase;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreReviewModel copyWith({
    String? id,
    String? storeId,
    String? sellerId,
    String? customerId,
    String? orderId,
    int? rating,
    String? comment,
    bool? verifiedPurchase,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreReviewModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sellerId: sellerId ?? this.sellerId,
      customerId: customerId ?? this.customerId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      verifiedPurchase: verifiedPurchase ?? this.verifiedPurchase,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: json['id'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      rating: ((json['rating'] as num?)?.toInt() ?? 1).clamp(1, 5),
      comment: json['comment'] as String? ?? '',
      verifiedPurchase: json['verifiedPurchase'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeId': storeId,
    'sellerId': sellerId,
    'customerId': customerId,
    'orderId': orderId,
    'rating': rating,
    'comment': comment,
    'verifiedPurchase': verifiedPurchase,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
