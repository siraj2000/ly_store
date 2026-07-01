import 'address_model.dart';
import 'order_item_model.dart';
import 'payment_method_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.status,
    required this.createdAt,
    DateTime? updatedAt,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.estimatedDelivery,
    this.paymentStatus = 'Pending',
    this.shippingStatus = 'Preparing',
    this.platformCommission = 0,
    this.sellerOrderIds = const [],
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsRedeemed = 0,
    this.loyaltyPointsDiscount = 0,
    this.walletAmountUsed = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  final String id;
  final String customerId;
  final String customerName;
  final List<OrderItemModel> items;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double total;
  final AddressModel address;
  final PaymentMethodModel paymentMethod;
  final DateTime estimatedDelivery;
  final String paymentStatus;
  final String shippingStatus;
  final double platformCommission;
  final List<String> sellerOrderIds;
  final int loyaltyPointsEarned;
  final int loyaltyPointsRedeemed;
  final double loyaltyPointsDiscount;
  final double walletAmountUsed;

  OrderModel copyWith({
    String? status,
    String? paymentStatus,
    String? shippingStatus,
    DateTime? updatedAt,
    List<String>? sellerOrderIds,
    int? loyaltyPointsEarned,
    int? loyaltyPointsRedeemed,
    double? loyaltyPointsDiscount,
    double? walletAmountUsed,
  }) {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
      estimatedDelivery: estimatedDelivery,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingStatus: shippingStatus ?? this.shippingStatus,
      platformCommission: platformCommission,
      sellerOrderIds: sellerOrderIds ?? this.sellerOrderIds,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsRedeemed:
          loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      loyaltyPointsDiscount:
          loyaltyPointsDiscount ?? this.loyaltyPointsDiscount,
      walletAmountUsed: walletAmountUsed ?? this.walletAmountUsed,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      address: AddressModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? const {},
      ),
      paymentMethod: PaymentMethodModel.fromJson(
        json['paymentMethod'] as Map<String, dynamic>? ?? const {},
      ),
      estimatedDelivery:
          DateTime.tryParse(json['estimatedDelivery'] as String? ?? '') ??
          DateTime.now(),
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      shippingStatus: json['shippingStatus'] as String? ?? 'Preparing',
      platformCommission: (json['platformCommission'] as num?)?.toDouble() ?? 0,
      sellerOrderIds: (json['sellerOrderIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num?)?.toInt() ?? 0,
      loyaltyPointsRedeemed:
          (json['loyaltyPointsRedeemed'] as num?)?.toInt() ?? 0,
      loyaltyPointsDiscount:
          (json['loyaltyPointsDiscount'] as num?)?.toDouble() ?? 0,
      walletAmountUsed: (json['walletAmountUsed'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'customerName': customerName,
    'items': items.map((item) => item.toJson()).toList(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'total': total,
    'address': address.toJson(),
    'paymentMethod': paymentMethod.toJson(),
    'estimatedDelivery': estimatedDelivery.toIso8601String(),
    'paymentStatus': paymentStatus,
    'shippingStatus': shippingStatus,
    'platformCommission': platformCommission,
    'sellerOrderIds': sellerOrderIds,
    'loyaltyPointsEarned': loyaltyPointsEarned,
    'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
    'loyaltyPointsDiscount': loyaltyPointsDiscount,
    'walletAmountUsed': walletAmountUsed,
  };
}
