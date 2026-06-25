import 'user_role.dart';

enum NotificationType {
  orderPlacedCustomer,
  newOrderSeller,
  orderConfirmed,
  orderProcessing,
  orderShipped,
  orderDelivered,
  orderCancelled,
  returnRequested,
  refundCompleted,
  storeReviewed,
  productApproved,
  productRejected,
  lowStock,
  genericPromotion,
  generic,
}

extension NotificationTypeX on NotificationType {
  String get id => switch (this) {
    NotificationType.orderPlacedCustomer => 'orderPlacedCustomer',
    NotificationType.newOrderSeller => 'newOrderSeller',
    NotificationType.orderConfirmed => 'orderConfirmed',
    NotificationType.orderProcessing => 'orderProcessing',
    NotificationType.orderShipped => 'orderShipped',
    NotificationType.orderDelivered => 'orderDelivered',
    NotificationType.orderCancelled => 'orderCancelled',
    NotificationType.returnRequested => 'returnRequested',
    NotificationType.refundCompleted => 'refundCompleted',
    NotificationType.storeReviewed => 'storeReviewed',
    NotificationType.productApproved => 'productApproved',
    NotificationType.productRejected => 'productRejected',
    NotificationType.lowStock => 'lowStock',
    NotificationType.genericPromotion => 'genericPromotion',
    NotificationType.generic => 'generic',
  };
}

NotificationType notificationTypeFromJsonValue(String? value) {
  switch ((value ?? '').trim()) {
    case 'orderPlacedCustomer':
      return NotificationType.orderPlacedCustomer;
    case 'newOrderSeller':
      return NotificationType.newOrderSeller;
    case 'orderConfirmed':
      return NotificationType.orderConfirmed;
    case 'orderProcessing':
      return NotificationType.orderProcessing;
    case 'orderShipped':
      return NotificationType.orderShipped;
    case 'orderDelivered':
      return NotificationType.orderDelivered;
    case 'orderCancelled':
      return NotificationType.orderCancelled;
    case 'returnRequested':
      return NotificationType.returnRequested;
    case 'refundCompleted':
      return NotificationType.refundCompleted;
    case 'storeReviewed':
      return NotificationType.storeReviewed;
    case 'productApproved':
      return NotificationType.productApproved;
    case 'productRejected':
      return NotificationType.productRejected;
    case 'lowStock':
      return NotificationType.lowStock;
    case 'genericPromotion':
      return NotificationType.genericPromotion;
    default:
      return NotificationType.generic;
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUserId,
    required this.recipientRole,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.route,
    this.isRead = false,
    this.readAt,
    this.legacyTitle,
    this.legacyMessage,
  });

  final String id;
  final String recipientUserId;
  final UserRole recipientRole;
  final NotificationType type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final String? route;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? legacyTitle;
  final String? legacyMessage;

  NotificationModel copyWith({
    String? id,
    String? recipientUserId,
    UserRole? recipientRole,
    NotificationType? type,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    String? route,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    bool clearReadAt = false,
    String? legacyTitle,
    String? legacyMessage,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      recipientRole: recipientRole ?? this.recipientRole,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      legacyTitle: legacyTitle ?? this.legacyTitle,
      legacyMessage: legacyMessage ?? this.legacyMessage,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final legacyTitle = json['title'] as String?;
    final legacyMessage = json['message'] as String?;
    return NotificationModel(
      id: json['id'] as String? ?? '',
      recipientUserId: json['recipientUserId'] as String? ?? '',
      recipientRole: UserRoleJson.fromJsonValue(
        json['recipientRole'] as String?,
      ),
      type: notificationTypeFromJsonValue(json['type'] as String?),
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      data: Map<String, dynamic>.from(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
      route: json['route'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'] as String),
      legacyTitle: legacyTitle,
      legacyMessage: legacyMessage,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientUserId': recipientUserId,
    'recipientRole': recipientRole.toJsonValue(),
    'type': type.id,
    'entityType': entityType,
    'entityId': entityId,
    'data': data,
    'route': route,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'readAt': readAt?.toIso8601String(),
    if (legacyTitle != null) 'title': legacyTitle,
    if (legacyMessage != null) 'message': legacyMessage,
  };
}
