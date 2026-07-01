import 'address_model.dart';
import 'order_item_model.dart';
import 'order_model.dart';
import 'payment_method_model.dart';

class SellerOrderModel {
  const SellerOrderModel({
    required this.id,
    required this.masterOrderId,
    required this.sellerId,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.platformCommission,
    required this.sellerNetAmount,
    required this.status,
    required this.paymentStatus,
    required this.shippingStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    required this.paymentMethod,
    required this.estimatedDelivery,
    this.carrierName = '',
    this.trackingNumber = '',
    this.shippedAt,
    this.deliveredAt,
    this.trackingUrl = '',
    this.shippingNotes = '',
    this.cancellationReason = '',
    this.cancelledAt,
  });

  final String id;
  final String masterOrderId;
  final String sellerId;
  final String storeId;
  final String customerId;
  final String customerName;
  final List<OrderItemModel> items;
  final double subtotal;
  final double platformCommission;
  final double sellerNetAmount;
  final String status;
  final String paymentStatus;
  final String shippingStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AddressModel address;
  final PaymentMethodModel paymentMethod;
  final DateTime estimatedDelivery;
  final String carrierName;
  final String trackingNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String trackingUrl;
  final String shippingNotes;
  final String cancellationReason;
  final DateTime? cancelledAt;

  SellerOrderModel copyWith({
    String? id,
    String? masterOrderId,
    String? sellerId,
    String? storeId,
    String? customerId,
    String? customerName,
    List<OrderItemModel>? items,
    double? subtotal,
    double? platformCommission,
    double? sellerNetAmount,
    String? status,
    String? paymentStatus,
    String? shippingStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    AddressModel? address,
    PaymentMethodModel? paymentMethod,
    DateTime? estimatedDelivery,
    String? carrierName,
    String? trackingNumber,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? trackingUrl,
    String? shippingNotes,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return SellerOrderModel(
      id: id ?? this.id,
      masterOrderId: masterOrderId ?? this.masterOrderId,
      sellerId: sellerId ?? this.sellerId,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      platformCommission: platformCommission ?? this.platformCommission,
      sellerNetAmount: sellerNetAmount ?? this.sellerNetAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingStatus: shippingStatus ?? this.shippingStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      carrierName: carrierName ?? this.carrierName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      shippingNotes: shippingNotes ?? this.shippingNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  OrderModel toOrderModel() {
    return OrderModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      items: items,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      total: subtotal,
      address: address,
      paymentMethod: paymentMethod,
      estimatedDelivery: estimatedDelivery,
      paymentStatus: paymentStatus,
      shippingStatus: shippingStatus,
      platformCommission: platformCommission,
      sellerOrderIds: [id],
    );
  }

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderModel(
      id: json['id'] as String? ?? '',
      masterOrderId: json['masterOrderId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      platformCommission: (json['platformCommission'] as num?)?.toDouble() ?? 0,
      sellerNetAmount: (json['sellerNetAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      shippingStatus: json['shippingStatus'] as String? ?? 'Preparing',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      address: AddressModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? const {},
      ),
      paymentMethod: PaymentMethodModel.fromJson(
        json['paymentMethod'] as Map<String, dynamic>? ?? const {},
      ),
      estimatedDelivery:
          DateTime.tryParse(json['estimatedDelivery'] as String? ?? '') ??
          DateTime.now(),
      carrierName: json['carrierName'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      shippedAt: DateTime.tryParse(json['shippedAt'] as String? ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt'] as String? ?? ''),
      trackingUrl: json['trackingUrl'] as String? ?? '',
      shippingNotes: json['shippingNotes'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String? ?? '',
      cancelledAt: DateTime.tryParse(json['cancelledAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'masterOrderId': masterOrderId,
    'sellerId': sellerId,
    'storeId': storeId,
    'customerId': customerId,
    'customerName': customerName,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'platformCommission': platformCommission,
    'sellerNetAmount': sellerNetAmount,
    'status': status,
    'paymentStatus': paymentStatus,
    'shippingStatus': shippingStatus,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'address': address.toJson(),
    'paymentMethod': paymentMethod.toJson(),
    'estimatedDelivery': estimatedDelivery.toIso8601String(),
    'carrierName': carrierName,
    'trackingNumber': trackingNumber,
    'shippedAt': shippedAt?.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'trackingUrl': trackingUrl,
    'shippingNotes': shippingNotes,
    'cancellationReason': cancellationReason,
    'cancelledAt': cancelledAt?.toIso8601String(),
  };
}
