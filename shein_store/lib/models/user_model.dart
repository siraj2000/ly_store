import 'address_model.dart';
import 'cart_item_model.dart';
import 'coupon_model.dart';
import 'customer_points_transaction_model.dart';
import 'localized_text_model.dart';
import 'notification_model.dart';
import 'order_model.dart';
import 'payment_method_model.dart';
import 'user_role.dart';
import 'wallet_transaction_model.dart';
import 'wishlist_model.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatar,
    required this.isActive,
    required this.createdAt,
    DateTime? updatedAt,
    required this.points,
    required this.walletBalance,
    required this.coupons,
    required this.orders,
    required this.addresses,
    required this.paymentMethods,
    required this.wishlistProductIds,
    required this.walletTransactions,
    this.pointsTransactions = const [],
    this.cart = const [],
    this.wishlistBoards = const [],
    this.notifications = const [],
    this.recentSearches = const [],
    this.recentlyViewedProductIds = const [],
    this.measurements = const {},
    this.mockPassword = '',
    this.adminRoleName = '',
    this.adminPermissionIds = const [],
    this.adminIsActive = true,
    this.linkedStoreId = '',
    this.sellerStatus = 'active',
    this.sellerStatusReason = '',
    this.sellerVacationMode = false,
    this.sellerNotificationsEnabled = true,
    this.storeDescription = '',
    LocalizedTextModel? storeNameText,
    LocalizedTextModel? storeDescriptionText,
    LocalizedTextModel? storePoliciesText,
  }) : updatedAt = updatedAt ?? createdAt,
       storeNameText = storeNameText ?? LocalizedTextModel(en: name, ar: name),
       storeDescriptionText =
           storeDescriptionText ??
           LocalizedTextModel(en: storeDescription, ar: storeDescription),
       storePoliciesText =
           storePoliciesText ?? const LocalizedTextModel(en: '', ar: '');

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String avatar;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int points;
  final double walletBalance;
  final List<CouponModel> coupons;
  final List<OrderModel> orders;
  final List<AddressModel> addresses;
  final List<PaymentMethodModel> paymentMethods;
  final List<String> wishlistProductIds;
  final List<WalletTransactionModel> walletTransactions;
  final List<CustomerPointsTransactionModel> pointsTransactions;
  final List<CartItemModel> cart;
  final List<WishlistBoardModel> wishlistBoards;
  final List<NotificationModel> notifications;
  final List<String> recentSearches;
  final List<String> recentlyViewedProductIds;
  final Map<String, String> measurements;
  // Mock password storage for demo only. Replace with secure backend authentication later.
  final String mockPassword;
  final String adminRoleName;
  final List<String> adminPermissionIds;
  final bool adminIsActive;
  final String linkedStoreId;
  final String sellerStatus;
  final String sellerStatusReason;
  final bool sellerVacationMode;
  final bool sellerNotificationsEnabled;
  final String storeDescription;
  final LocalizedTextModel storeNameText;
  final LocalizedTextModel storeDescriptionText;
  final LocalizedTextModel storePoliciesText;

  bool get isSellerAccountActive =>
      role != UserRole.seller || (isActive && sellerStatus == 'active');

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatar,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? points,
    double? walletBalance,
    List<CouponModel>? coupons,
    List<OrderModel>? orders,
    List<AddressModel>? addresses,
    List<PaymentMethodModel>? paymentMethods,
    List<String>? wishlistProductIds,
    List<WalletTransactionModel>? walletTransactions,
    List<CustomerPointsTransactionModel>? pointsTransactions,
    List<CartItemModel>? cart,
    List<WishlistBoardModel>? wishlistBoards,
    List<NotificationModel>? notifications,
    List<String>? recentSearches,
    List<String>? recentlyViewedProductIds,
    Map<String, String>? measurements,
    String? mockPassword,
    String? adminRoleName,
    List<String>? adminPermissionIds,
    bool? adminIsActive,
    String? linkedStoreId,
    String? sellerStatus,
    String? sellerStatusReason,
    bool? sellerVacationMode,
    bool? sellerNotificationsEnabled,
    String? storeDescription,
    LocalizedTextModel? storeNameText,
    LocalizedTextModel? storeDescriptionText,
    LocalizedTextModel? storePoliciesText,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      points: points ?? this.points,
      walletBalance: walletBalance ?? this.walletBalance,
      coupons: coupons ?? this.coupons,
      orders: orders ?? this.orders,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      wishlistProductIds: wishlistProductIds ?? this.wishlistProductIds,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      pointsTransactions: pointsTransactions ?? this.pointsTransactions,
      cart: cart ?? this.cart,
      wishlistBoards: wishlistBoards ?? this.wishlistBoards,
      notifications: notifications ?? this.notifications,
      recentSearches: recentSearches ?? this.recentSearches,
      recentlyViewedProductIds:
          recentlyViewedProductIds ?? this.recentlyViewedProductIds,
      measurements: measurements ?? this.measurements,
      mockPassword: mockPassword ?? this.mockPassword,
      adminRoleName: adminRoleName ?? this.adminRoleName,
      adminPermissionIds: adminPermissionIds ?? this.adminPermissionIds,
      adminIsActive: adminIsActive ?? this.adminIsActive,
      linkedStoreId: linkedStoreId ?? this.linkedStoreId,
      sellerStatus: sellerStatus ?? this.sellerStatus,
      sellerStatusReason: sellerStatusReason ?? this.sellerStatusReason,
      sellerVacationMode: sellerVacationMode ?? this.sellerVacationMode,
      sellerNotificationsEnabled:
          sellerNotificationsEnabled ?? this.sellerNotificationsEnabled,
      storeDescription: storeDescription ?? this.storeDescription,
      storeNameText: storeNameText ?? this.storeNameText,
      storeDescriptionText: storeDescriptionText ?? this.storeDescriptionText,
      storePoliciesText: storePoliciesText ?? this.storePoliciesText,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final legacyName = json['name'] as String? ?? '';
    final legacyStoreDescription = json['storeDescription'] as String? ?? '';
    return UserModel(
      id: json['id'] as String? ?? '',
      name: legacyName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRoleJson.fromJsonValue(json['role'] as String?),
      avatar: json['avatar'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      points: json['points'] as int? ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      coupons: (json['coupons'] as List<dynamic>? ?? [])
          .map((item) => CouponModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      paymentMethods: (json['paymentMethods'] as List<dynamic>? ?? [])
          .map(
            (item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      wishlistProductIds: (json['wishlistProductIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      walletTransactions: (json['walletTransactions'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                WalletTransactionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pointsTransactions: (json['pointsTransactions'] as List<dynamic>? ?? [])
          .map(
            (item) => CustomerPointsTransactionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      cart: (json['cart'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      wishlistBoards: (json['wishlistBoards'] as List<dynamic>? ?? [])
          .map(
            (item) => WishlistBoardModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      recentSearches: (json['recentSearches'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      recentlyViewedProductIds:
          (json['recentlyViewedProductIds'] as List<dynamic>? ?? [])
              .map((item) => item as String)
              .toList(),
      measurements: Map<String, String>.from(
        json['measurements'] as Map<String, dynamic>? ?? const {},
      ),
      mockPassword: json['mockPassword'] as String? ?? '',
      adminRoleName: json['adminRoleName'] as String? ?? '',
      adminPermissionIds: (json['adminPermissionIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      adminIsActive: json['adminIsActive'] as bool? ?? true,
      linkedStoreId: json['linkedStoreId'] as String? ?? '',
      sellerStatus: json['sellerStatus'] as String? ?? 'active',
      sellerStatusReason: json['sellerStatusReason'] as String? ?? '',
      sellerVacationMode: json['sellerVacationMode'] as bool? ?? false,
      sellerNotificationsEnabled:
          json['sellerNotificationsEnabled'] as bool? ?? true,
      storeDescription: legacyStoreDescription,
      storeNameText: json['storeNameText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['storeNameText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(en: legacyName, ar: legacyName),
      storeDescriptionText: json['storeDescriptionText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['storeDescriptionText'] as Map<String, dynamic>,
            )
          : LocalizedTextModel(
              en: legacyStoreDescription,
              ar: legacyStoreDescription,
            ),
      storePoliciesText: json['storePoliciesText'] is Map<String, dynamic>
          ? LocalizedTextModel.fromJson(
              json['storePoliciesText'] as Map<String, dynamic>,
            )
          : const LocalizedTextModel(en: '', ar: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role.toJsonValue(),
    'avatar': avatar,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'points': points,
    'walletBalance': walletBalance,
    'coupons': coupons.map((item) => item.toJson()).toList(),
    'orders': orders.map((item) => item.toJson()).toList(),
    'addresses': addresses.map((item) => item.toJson()).toList(),
    'paymentMethods': paymentMethods.map((item) => item.toJson()).toList(),
    'wishlistProductIds': wishlistProductIds,
    'walletTransactions': walletTransactions
        .map((item) => item.toJson())
        .toList(),
    'pointsTransactions': pointsTransactions
        .map((item) => item.toJson())
        .toList(),
    'cart': cart.map((item) => item.toJson()).toList(),
    'wishlistBoards': wishlistBoards.map((item) => item.toJson()).toList(),
    'notifications': notifications.map((item) => item.toJson()).toList(),
    'recentSearches': recentSearches,
    'recentlyViewedProductIds': recentlyViewedProductIds,
    'measurements': measurements,
    'mockPassword': mockPassword,
    'adminRoleName': adminRoleName,
    'adminPermissionIds': adminPermissionIds,
    'adminIsActive': adminIsActive,
    'linkedStoreId': linkedStoreId,
    'sellerStatus': sellerStatus,
    'sellerStatusReason': sellerStatusReason,
    'sellerVacationMode': sellerVacationMode,
    'sellerNotificationsEnabled': sellerNotificationsEnabled,
    'storeDescription': storeDescription,
    'storeNameText': storeNameText.toJson(),
    'storeDescriptionText': storeDescriptionText.toJson(),
    'storePoliciesText': storePoliciesText.toJson(),
  };
}
