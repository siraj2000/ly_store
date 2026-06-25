import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../models/admin/audit_log_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../models/localized_text_model.dart';
import '../repositories/admin_repository.dart';
import '../repositories/marketplace_repository.dart';
import 'auth_controller.dart';

enum SellerAccountStatus { active, pending, suspended }

extension SellerAccountStatusX on SellerAccountStatus {
  String get id {
    return switch (this) {
      SellerAccountStatus.active => 'active',
      SellerAccountStatus.pending => 'pending',
      SellerAccountStatus.suspended => 'suspended',
    };
  }

  static SellerAccountStatus fromId(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return SellerAccountStatus.pending;
      case 'suspended':
        return SellerAccountStatus.suspended;
      default:
        return SellerAccountStatus.active;
    }
  }
}

class AdminSellerFormData {
  const AdminSellerFormData({
    required this.sellerName,
    required this.email,
    required this.sellerPhone,
    required this.password,
    required this.confirmPassword,
    required this.accountStatus,
    required this.storeNameAr,
    required this.storeNameEn,
    required this.storePhone,
    required this.storeAddressAr,
    required this.storeAddressEn,
    required this.city,
    required this.countryCode,
    required this.businessActivityType,
    required this.storeDescriptionAr,
    required this.storeDescriptionEn,
    required this.storeActive,
    required this.verifiedStore,
    required this.featuredStore,
    required this.vacationMode,
    required this.commissionPercentage,
    required this.allowedCategoryIds,
    this.suspensionReason = '',
  });

  final String sellerName;
  final String email;
  final String sellerPhone;
  final String password;
  final String confirmPassword;
  final SellerAccountStatus accountStatus;
  final String storeNameAr;
  final String storeNameEn;
  final String storePhone;
  final String storeAddressAr;
  final String storeAddressEn;
  final String city;
  final String countryCode;
  final String businessActivityType;
  final String storeDescriptionAr;
  final String storeDescriptionEn;
  final bool storeActive;
  final bool verifiedStore;
  final bool featuredStore;
  final bool vacationMode;
  final double commissionPercentage;
  final List<String> allowedCategoryIds;
  final String suspensionReason;
}

class AdminSellerSummary {
  const AdminSellerSummary({
    required this.user,
    required this.store,
    required this.productCount,
    required this.orderCount,
    required this.totalSales,
  });

  final UserModel user;
  final StoreModel? store;
  final int productCount;
  final int orderCount;
  final double totalSales;
}

class AdminSellerCredentialsResult {
  const AdminSellerCredentialsResult({
    required this.user,
    required this.store,
    required this.password,
  });

  final UserModel user;
  final StoreModel store;
  final String password;
}

class AdminSellerController extends ChangeNotifier {
  AdminSellerController({
    required AdminRepository adminRepository,
    required MarketplaceRepository marketplaceRepository,
  }) : _adminRepository = adminRepository,
       _marketplaceRepository = marketplaceRepository;

  final AdminRepository _adminRepository;
  final MarketplaceRepository _marketplaceRepository;
  final Random _random = Random();

  AuthController? _authController;

  bool isLoading = false;
  String searchQuery = '';
  String? errorMessage;
  String? successMessage;
  Map<String, String> validationErrors = const {};

  List<UserModel> _allUsers = const [];
  List<UserModel> _sellerUsers = const [];
  List<StoreModel> _stores = const [];
  List<ProductModel> _products = const [];
  List<OrderModel> _orders = const [];
  List<CategoryModel> _categories = const [];

  void bind({required AuthController authController}) {
    _authController = authController;
  }

  List<CategoryModel> get categories => _categories;

  List<UserModel> get rawSellerUsers => _sellerUsers;

  List<StoreModel> get stores => _stores;

  List<AdminSellerSummary> get sellers {
    final lowerQuery = searchQuery.trim().toLowerCase();
    final items = _sellerUsers.map(_buildSummary).where((summary) {
      if (lowerQuery.isEmpty) {
        return true;
      }
      final store = summary.store;
      return summary.user.name.toLowerCase().contains(lowerQuery) ||
          summary.user.email.toLowerCase().contains(lowerQuery) ||
          summary.user.phone.toLowerCase().contains(lowerQuery) ||
          (store?.nameText.en.toLowerCase().contains(lowerQuery) ?? false) ||
          (store?.storePhone.toLowerCase().contains(lowerQuery) ?? false) ||
          (store?.city.toLowerCase().contains(lowerQuery) ?? false) ||
          (store?.businessActivityType.toLowerCase().contains(lowerQuery) ??
              false);
    }).toList();
    items.sort((left, right) {
      final leftRank = _statusRank(left.user.sellerStatus);
      final rightRank = _statusRank(right.user.sellerStatus);
      if (leftRank != rightRank) {
        return leftRank.compareTo(rightRank);
      }
      return left.user.name.toLowerCase().compareTo(
        right.user.name.toLowerCase(),
      );
    });
    return items;
  }

  Future<void> loadSellers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _marketplaceRepository.getUsers(),
        _marketplaceRepository.getStores(),
        _marketplaceRepository.getProducts(),
        _marketplaceRepository.getOrders(),
        _marketplaceRepository.getCategories(),
      ]);
      _allUsers = results[0] as List<UserModel>;
      _sellerUsers = _allUsers
          .where((user) => user.role == UserRole.seller)
          .toList();
      _stores = results[1] as List<StoreModel>;
      _products = results[2] as List<ProductModel>;
      _orders = results[3] as List<OrderModel>;
      _categories = results[4] as List<CategoryModel>;
    } catch (_) {
      errorMessage = 'adminUnableToLoadSellers';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    validationErrors = const {};
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  AdminSellerSummary? getSellerDetails(String sellerId) {
    final matches = _sellerUsers.where((item) => item.id == sellerId);
    if (matches.isEmpty) {
      return null;
    }
    return _buildSummary(matches.first);
  }

  StoreModel? getStoreBySellerId(String sellerId) {
    final linkedStore = _stores.where((store) => store.sellerId == sellerId);
    return linkedStore.isEmpty ? null : linkedStore.first;
  }

  bool emailExists(String email, {String? excludeSellerId}) {
    final normalized = email.trim().toLowerCase();
    for (final user in _allUsers) {
      if (user.id == excludeSellerId) {
        continue;
      }
      if (user.email.toLowerCase() == normalized) {
        return true;
      }
    }
    return false;
  }

  String generatePassword() {
    const charset = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    return List<String>.generate(
      10,
      (_) => charset[_random.nextInt(charset.length)],
    ).join();
  }

  Map<String, String> validateSellerForm(
    AdminSellerFormData data, {
    String? excludeSellerId,
    bool requirePassword = true,
  }) {
    final errors = <String, String>{};
    final sellerName = data.sellerName.trim();
    final email = data.email.trim().toLowerCase();
    final sellerPhoneDigits = _digitsOnly(data.sellerPhone);
    final storePhoneDigits = _digitsOnly(data.storePhone);

    if (sellerName.isEmpty) {
      errors['sellerName'] = 'validationSellerNameRequired';
    } else if (sellerName.length < 3) {
      errors['sellerName'] = 'validationSellerNameMin';
    }

    if (email.isEmpty) {
      errors['email'] = 'validationSellerEmailRequired';
    } else if (!_isEmailValid(email)) {
      errors['email'] = 'validationSellerEmailInvalid';
    } else if (emailExists(email, excludeSellerId: excludeSellerId)) {
      errors['email'] = 'validationEmailAlreadyExists';
    }

    if (sellerPhoneDigits.length < 7) {
      errors['sellerPhone'] = 'validationSellerPhoneRequired';
    }

    if (requirePassword || data.password.trim().isNotEmpty) {
      if (data.password.trim().length < 6) {
        errors['password'] = 'validationSellerPasswordMin';
      }
      if (data.confirmPassword.trim().isEmpty) {
        errors['confirmPassword'] = 'validationSellerConfirmPasswordRequired';
      } else if (data.password.trim() != data.confirmPassword.trim()) {
        errors['confirmPassword'] = 'validationPasswordsDoNotMatch';
      }
    }

    if (data.storeNameAr.trim().isEmpty) {
      errors['storeNameAr'] = 'validationStoreNameArRequired';
    }
    if (data.storeNameEn.trim().isEmpty) {
      errors['storeNameEn'] = 'validationStoreNameEnRequired';
    }
    if (storePhoneDigits.length < 7) {
      errors['storePhone'] = 'validationStorePhoneRequired';
    }
    if (data.storeAddressAr.trim().isEmpty) {
      errors['storeAddressAr'] = 'validationStoreAddressArRequired';
    }
    if (data.storeAddressEn.trim().isEmpty) {
      errors['storeAddressEn'] = 'validationStoreAddressEnRequired';
    }
    if (data.city.trim().isEmpty) {
      errors['city'] = 'validationCityRequired';
    }
    if (data.countryCode.trim().isEmpty) {
      errors['countryCode'] = 'validationCountryRequired';
    }
    if (data.businessActivityType.trim().isEmpty) {
      errors['businessActivityType'] = 'validationSelectBusinessActivity';
    }
    if (data.commissionPercentage < 0 || data.commissionPercentage > 100) {
      errors['commissionPercentage'] = 'validationInvalidCommission';
    }

    validationErrors = errors;
    return errors;
  }

  Future<AdminSellerCredentialsResult?> createSellerWithStore(
    AdminSellerFormData data,
  ) async {
    if (!_can('sellers.create') || !_can('stores.create')) {
      errorMessage = 'adminSellerPermissionDenied';
      notifyListeners();
      return null;
    }

    validationErrors = validateSellerForm(data);
    if (validationErrors.isNotEmpty) {
      errorMessage = 'adminSellerValidationFailed';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final sellerId = 'seller_${now.microsecondsSinceEpoch}';
    final storeId = 'store_$sellerId';
    final seller = _buildSellerUser(
      sellerId: sellerId,
      storeId: storeId,
      now: now,
      data: data,
    );
    final store = _buildStore(
      storeId: storeId,
      sellerId: sellerId,
      createdAt: now,
      existingStore: null,
      data: data,
    );

    try {
      await _marketplaceRepository.saveUser(seller);
      await _marketplaceRepository.saveStore(store);
      await _appendAudit(
        action: 'seller.created',
        entityType: 'seller',
        entityId: seller.id,
        newValue: seller.toJson(),
      );
      await _appendAudit(
        action: 'store.created',
        entityType: 'store',
        entityId: store.id,
        newValue: store.toJson(),
      );
      successMessage = 'adminSellerCreatedSuccessfully';
      unawaited(loadSellers());
      return AdminSellerCredentialsResult(
        user: seller,
        store: store,
        password: data.password.trim(),
      );
    } catch (_) {
      errorMessage = 'adminSellerCreateFailed';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSeller(String sellerId, AdminSellerFormData data) async {
    if (!_can('sellers.edit') || !_can('stores.edit')) {
      errorMessage = 'adminSellerPermissionDenied';
      notifyListeners();
      return false;
    }

    final existing = _sellerUsers.where((user) => user.id == sellerId);
    if (existing.isEmpty) {
      errorMessage = 'adminSellerNotFound';
      notifyListeners();
      return false;
    }
    final existingUser = existing.first;
    final store = getStoreBySellerId(sellerId);

    validationErrors = validateSellerForm(
      data,
      excludeSellerId: sellerId,
      requirePassword:
          data.password.trim().isNotEmpty ||
          data.confirmPassword.trim().isNotEmpty,
    );
    if (validationErrors.isNotEmpty) {
      errorMessage = 'adminSellerValidationFailed';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final updatedUser = _buildSellerUser(
      sellerId: existingUser.id,
      storeId: existingUser.linkedStoreId.isNotEmpty
          ? existingUser.linkedStoreId
          : (store?.id ?? 'store_${existingUser.id}'),
      now: now,
      data: data,
      existingUser: existingUser,
    );
    final updatedStore = _buildStore(
      storeId: store?.id ?? updatedUser.linkedStoreId,
      sellerId: existingUser.id,
      createdAt: store?.createdAt ?? existingUser.createdAt,
      existingStore: store,
      data: data,
    );

    try {
      await _marketplaceRepository.saveUser(updatedUser);
      await _marketplaceRepository.saveStore(updatedStore);
      await _appendAudit(
        action: 'seller.updated',
        entityType: 'seller',
        entityId: updatedUser.id,
        previousValue: existingUser.toJson(),
        newValue: updatedUser.toJson(),
      );
      await _appendAudit(
        action: 'store.updated',
        entityType: 'store',
        entityId: updatedStore.id,
        previousValue: store?.toJson(),
        newValue: updatedStore.toJson(),
      );
      if (_authController?.currentUser?.id == updatedUser.id) {
        _authController?.replaceUser(updatedUser);
      }
      successMessage = 'adminSellerUpdatedSuccessfully';
      unawaited(loadSellers());
      return true;
    } catch (_) {
      errorMessage = 'adminSellerUpdateFailed';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> activateSeller(String sellerId) async {
    if (!_can('sellers.activate')) {
      errorMessage = 'adminSellerPermissionDenied';
      notifyListeners();
      return false;
    }
    final summary = getSellerDetails(sellerId);
    if (summary == null) {
      errorMessage = 'adminSellerNotFound';
      notifyListeners();
      return false;
    }
    final user = summary.user.copyWith(
      isActive: true,
      sellerStatus: SellerAccountStatus.active.id,
      sellerStatusReason: '',
      updatedAt: DateTime.now(),
    );
    final store =
        (summary.store ??
                _buildStore(
                  storeId: user.linkedStoreId.isNotEmpty
                      ? user.linkedStoreId
                      : 'store_${user.id}',
                  sellerId: user.id,
                  createdAt: user.createdAt,
                  existingStore: null,
                  data: AdminSellerFormData(
                    sellerName: user.name,
                    email: user.email,
                    sellerPhone: user.phone,
                    password: user.mockPassword,
                    confirmPassword: user.mockPassword,
                    accountStatus: SellerAccountStatus.active,
                    storeNameAr: user.storeNameText.ar,
                    storeNameEn: user.storeNameText.en,
                    storePhone: summary.store?.storePhone ?? user.phone,
                    storeAddressAr: summary.store?.addressText.ar ?? '',
                    storeAddressEn: summary.store?.addressText.en ?? '',
                    city: summary.store?.city ?? '',
                    countryCode: summary.store?.countryCode ?? '',
                    businessActivityType:
                        summary.store?.businessActivityType ?? 'mixed',
                    storeDescriptionAr: user.storeDescriptionText.ar,
                    storeDescriptionEn: user.storeDescriptionText.en,
                    storeActive: true,
                    verifiedStore: summary.store?.isVerified ?? false,
                    featuredStore: summary.store?.isFeatured ?? false,
                    vacationMode: summary.store?.vacationMode ?? false,
                    commissionPercentage:
                        summary.store?.commissionPercentage ?? 12,
                    allowedCategoryIds:
                        summary.store?.allowedCategoryIds ?? const [],
                  ),
                ))
            .copyWith(
              isActive: true,
              clearSuspendedAt: true,
              suspensionReason: '',
              updatedAt: DateTime.now(),
            );
    return _persistStatusChange(
      updatedUser: user,
      updatedStore: store,
      sellerAction: 'seller.activated',
      storeAction: 'store.activated',
      successKey: 'adminSellerActivated',
    );
  }

  Future<bool> suspendSeller(String sellerId, String reason) async {
    if (!_can('sellers.suspend')) {
      errorMessage = 'adminSellerPermissionDenied';
      notifyListeners();
      return false;
    }
    final summary = getSellerDetails(sellerId);
    if (summary == null) {
      errorMessage = 'adminSellerNotFound';
      notifyListeners();
      return false;
    }
    final note = reason.trim();
    final user = summary.user.copyWith(
      isActive: false,
      sellerStatus: SellerAccountStatus.suspended.id,
      sellerStatusReason: note,
      updatedAt: DateTime.now(),
    );
    final store = summary.store?.copyWith(
      isActive: false,
      suspendedAt: DateTime.now(),
      suspensionReason: note,
      updatedAt: DateTime.now(),
    );
    return _persistStatusChange(
      updatedUser: user,
      updatedStore: store,
      sellerAction: 'seller.suspended',
      storeAction: 'store.suspended',
      successKey: 'adminSellerSuspended',
      reason: note,
    );
  }

  Future<String?> resetSellerPassword(
    String sellerId, {
    String? password,
  }) async {
    if (!_can('sellers.resetPassword')) {
      errorMessage = 'adminSellerPermissionDenied';
      notifyListeners();
      return null;
    }
    final summary = getSellerDetails(sellerId);
    if (summary == null) {
      errorMessage = 'adminSellerNotFound';
      notifyListeners();
      return null;
    }
    final nextPassword = password?.trim().isNotEmpty == true
        ? password!.trim()
        : generatePassword();
    if (nextPassword.length < 6) {
      errorMessage = 'validationSellerPasswordMin';
      notifyListeners();
      return null;
    }
    final updatedUser = summary.user.copyWith(
      mockPassword: nextPassword,
      updatedAt: DateTime.now(),
    );
    try {
      await _marketplaceRepository.saveUser(updatedUser);
      await _appendAudit(
        action: 'seller.passwordReset',
        entityType: 'seller',
        entityId: updatedUser.id,
        previousValue: summary.user.toJson(),
        newValue: updatedUser.toJson(),
      );
      if (_authController?.currentUser?.id == updatedUser.id) {
        _authController?.replaceUser(updatedUser);
      }
      successMessage = 'adminSellerPasswordResetSuccess';
      unawaited(loadSellers());
      notifyListeners();
      return nextPassword;
    } catch (_) {
      errorMessage = 'adminSellerPasswordResetFailed';
      notifyListeners();
      return null;
    }
  }

  Future<bool> _persistStatusChange({
    required UserModel updatedUser,
    required StoreModel? updatedStore,
    required String sellerAction,
    required String storeAction,
    required String successKey,
    String reason = '',
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      await _marketplaceRepository.saveUser(updatedUser);
      if (updatedStore != null) {
        await _marketplaceRepository.saveStore(updatedStore);
      }
      await _appendAudit(
        action: sellerAction,
        entityType: 'seller',
        entityId: updatedUser.id,
        newValue: updatedUser.toJson(),
        reason: reason,
      );
      if (updatedStore != null) {
        await _appendAudit(
          action: storeAction,
          entityType: 'store',
          entityId: updatedStore.id,
          newValue: updatedStore.toJson(),
          reason: reason,
        );
      }
      if (_authController?.currentUser?.id == updatedUser.id) {
        _authController?.replaceUser(updatedUser);
      }
      successMessage = successKey;
      unawaited(loadSellers());
      return true;
    } catch (_) {
      errorMessage = 'adminSellerStatusChangeFailed';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  AdminSellerSummary _buildSummary(UserModel user) {
    final store = getStoreBySellerId(user.id);
    final sellerProducts = _products
        .where(
          (product) =>
              product.sellerId == user.id ||
              (store != null && product.storeId == store.id),
        )
        .where((product) => !product.isDeleted)
        .toList();
    final sellerOrders = _orders
        .where(
          (order) => order.items.any(
            (item) =>
                item.product.sellerId == user.id ||
                (store != null && item.product.storeId == store.id),
          ),
        )
        .toList();
    final totalSales = sellerOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );
    return AdminSellerSummary(
      user: user,
      store: store,
      productCount: sellerProducts.length,
      orderCount: sellerOrders.length,
      totalSales: totalSales,
    );
  }

  UserModel _buildSellerUser({
    required String sellerId,
    required String storeId,
    required DateTime now,
    required AdminSellerFormData data,
    UserModel? existingUser,
  }) {
    final isActive = data.accountStatus == SellerAccountStatus.active;
    final phone = data.sellerPhone.trim();
    final normalizedEmail = data.email.trim().toLowerCase();
    return UserModel(
      id: sellerId,
      name: data.sellerName.trim(),
      email: normalizedEmail,
      phone: phone,
      role: UserRole.seller,
      avatar: existingUser?.avatar ?? '',
      isActive: isActive,
      createdAt: existingUser?.createdAt ?? now,
      updatedAt: now,
      points: existingUser?.points ?? 0,
      walletBalance: existingUser?.walletBalance ?? 0,
      coupons: existingUser?.coupons ?? const [],
      orders: existingUser?.orders ?? const [],
      addresses: [
        AddressModel(
          id: 'address_$sellerId',
          fullName: data.sellerName.trim(),
          phone: data.storePhone.trim(),
          country: data.countryCode.trim().toUpperCase(),
          city: data.city.trim(),
          region: data.city.trim(),
          streetAddress: data.storeAddressEn.trim(),
          postalCode: '',
          isDefault: true,
        ),
      ],
      paymentMethods: existingUser?.paymentMethods ?? const [],
      wishlistProductIds: existingUser?.wishlistProductIds ?? const [],
      walletTransactions: existingUser?.walletTransactions ?? const [],
      cart: existingUser?.cart ?? const [],
      wishlistBoards: existingUser?.wishlistBoards ?? const [],
      notifications: existingUser?.notifications ?? const [],
      recentSearches: existingUser?.recentSearches ?? const [],
      recentlyViewedProductIds:
          existingUser?.recentlyViewedProductIds ?? const [],
      measurements: existingUser?.measurements ?? const {},
      mockPassword: data.password.trim().isNotEmpty
          ? data.password.trim()
          : (existingUser?.mockPassword ?? ''),
      linkedStoreId: storeId,
      sellerStatus: data.accountStatus.id,
      sellerStatusReason: data.suspensionReason.trim(),
      sellerVacationMode: data.vacationMode,
      sellerNotificationsEnabled:
          existingUser?.sellerNotificationsEnabled ?? true,
      storeDescription: data.storeDescriptionEn.trim(),
      storeNameText: LocalizedTextModel(
        en: data.storeNameEn.trim(),
        ar: data.storeNameAr.trim(),
      ),
      storeDescriptionText: LocalizedTextModel(
        en: data.storeDescriptionEn.trim(),
        ar: data.storeDescriptionAr.trim(),
      ),
      storePoliciesText:
          existingUser?.storePoliciesText ??
          const LocalizedTextModel(en: '', ar: ''),
      adminRoleName: existingUser?.adminRoleName ?? '',
      adminPermissionIds: existingUser?.adminPermissionIds ?? const [],
      adminIsActive: existingUser?.adminIsActive ?? true,
    );
  }

  StoreModel _buildStore({
    required String storeId,
    required String sellerId,
    required DateTime createdAt,
    required StoreModel? existingStore,
    required AdminSellerFormData data,
  }) {
    final sellerIsActive = data.accountStatus == SellerAccountStatus.active;
    return StoreModel(
      id: storeId,
      sellerId: sellerId,
      nameText: LocalizedTextModel(
        en: data.storeNameEn.trim(),
        ar: data.storeNameAr.trim(),
      ),
      descriptionText: LocalizedTextModel(
        en: data.storeDescriptionEn.trim(),
        ar: data.storeDescriptionAr.trim(),
      ),
      policiesText:
          existingStore?.policiesText ??
          const LocalizedTextModel(en: '', ar: ''),
      addressText: LocalizedTextModel(
        en: data.storeAddressEn.trim(),
        ar: data.storeAddressAr.trim(),
      ),
      storePhone: data.storePhone.trim(),
      city: data.city.trim(),
      countryCode: data.countryCode.trim().toUpperCase(),
      businessActivityType: data.businessActivityType.trim(),
      logoUrl: existingStore?.logoUrl,
      localLogoPath: existingStore?.localLogoPath,
      bannerUrl: existingStore?.bannerUrl,
      localBannerPath: existingStore?.localBannerPath,
      rating: existingStore?.rating ?? 0,
      reviewCount: existingStore?.reviewCount ?? 0,
      followersCount: existingStore?.followersCount ?? 0,
      isActive: sellerIsActive && data.storeActive,
      isFeatured: data.featuredStore,
      isVerified: data.verifiedStore,
      vacationMode: data.vacationMode,
      commissionPercentage: data.commissionPercentage,
      allowedCategoryIds: data.allowedCategoryIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      suspendedAt: data.accountStatus == SellerAccountStatus.suspended
          ? DateTime.now()
          : null,
      suspensionReason: data.suspensionReason.trim(),
    );
  }

  Future<void> _appendAudit({
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    String reason = '',
  }) async {
    final currentAdmin = _authController?.currentUser;
    await _adminRepository.appendAuditLog(
      AuditLogModel(
        id: 'audit_${DateTime.now().microsecondsSinceEpoch}',
        adminUserId: currentAdmin?.id ?? 'system',
        adminName: currentAdmin?.name ?? 'System',
        action: action,
        entityType: entityType,
        entityId: entityId,
        timestamp: DateTime.now(),
        result: 'success',
        reason: reason,
        previousValueJson: previousValue == null
            ? ''
            : jsonEncode(previousValue),
        newValueJson: newValue == null ? '' : jsonEncode(newValue),
      ),
    );
  }

  bool _can(String permission) {
    return _authController?.hasPermission(permission) ?? false;
  }

  int _statusRank(String status) {
    switch (status) {
      case 'active':
        return 0;
      case 'pending':
        return 1;
      case 'suspended':
        return 2;
      default:
        return 3;
    }
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool _isEmailValid(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
