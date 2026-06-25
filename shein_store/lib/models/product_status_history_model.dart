import 'product_status.dart';

class ProductStatusHistoryModel {
  const ProductStatusHistoryModel({
    required this.id,
    required this.productId,
    required this.previousStatus,
    required this.newStatus,
    required this.changedByUserId,
    required this.changedByName,
    required this.reason,
    required this.timestamp,
  });

  final String id;
  final String productId;
  final ProductStatus previousStatus;
  final ProductStatus newStatus;
  final String changedByUserId;
  final String changedByName;
  final String reason;
  final DateTime timestamp;

  ProductStatusHistoryModel copyWith({
    String? id,
    String? productId,
    ProductStatus? previousStatus,
    ProductStatus? newStatus,
    String? changedByUserId,
    String? changedByName,
    String? reason,
    DateTime? timestamp,
  }) {
    return ProductStatusHistoryModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      changedByUserId: changedByUserId ?? this.changedByUserId,
      changedByName: changedByName ?? this.changedByName,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ProductStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return ProductStatusHistoryModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      previousStatus: ProductStatus.fromStorage(
        json['previousStatus'] as String?,
      ),
      newStatus: ProductStatus.fromStorage(json['newStatus'] as String?),
      changedByUserId: json['changedByUserId'] as String? ?? '',
      changedByName: json['changedByName'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'previousStatus': previousStatus.id,
    'newStatus': newStatus.id,
    'changedByUserId': changedByUserId,
    'changedByName': changedByName,
    'reason': reason,
    'timestamp': timestamp.toIso8601String(),
  };
}
