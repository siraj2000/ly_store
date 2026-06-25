import 'dart:async';

import 'package:flutter/material.dart';

import '../core/utils/date_formatter.dart';
import '../models/localized_text_model.dart';
import '../models/payment_method_model.dart';
import '../models/product_model.dart';
import '../models/product_status.dart';
import '../models/store_model.dart';
import '../models/user_model.dart';
import '../repositories/marketplace_repository.dart';
import 'auth_controller.dart';
import 'seller_product_controller.dart';

class SellerStoreController extends ChangeNotifier {
  SellerStoreController({required MarketplaceRepository marketplaceRepository})
    : _marketplaceRepository = marketplaceRepository;

  final MarketplaceRepository _marketplaceRepository;

  AuthController? _authController;
  SellerProductController? _sellerProductController;
  StoreModel? _store;
  bool vacationMode = false;
  bool notificationsEnabled = true;
  LocalizedTextModel storeNameText = const LocalizedTextModel(
    en: 'Store',
    ar: 'Ø§Ù„Ù…ØªØ¬Ø±',
  );
  LocalizedTextModel storeDescriptionText = const LocalizedTextModel(
    en: 'Original daily-wear edits with easy silhouettes and polished basics.',
    ar: 'ØªØ´ÙƒÙŠÙ„Ø§Øª ÙŠÙˆÙ…ÙŠØ© Ø£ØµÙ„ÙŠØ© Ø¨Ù‚ØµÙ‘Ø§Øª Ø³Ù‡Ù„Ø© ÙˆØ£Ø³Ø§Ø³ÙŠÙ‘Ø§Øª Ø£Ù†ÙŠÙ‚Ø©.',
  );

  void bind({
    required AuthController authController,
    required SellerProductController sellerProductController,
  }) {
    _authController = authController;
    _sellerProductController = sellerProductController;
    vacationMode = authController.currentUser?.sellerVacationMode ?? false;
    notificationsEnabled =
        authController.currentUser?.sellerNotificationsEnabled ?? true;
    unawaited(_loadStore());
    notifyListeners();
  }

  UserModel? get user => _authController?.currentUser;
  String get sellerName => user?.name ?? 'Seller';
  String get sellerEmail => user?.email ?? '';
  String get sellerPhone => user?.phone ?? '';
  String get memberSince =>
      user == null ? 'Recently joined' : formatShortDate(user!.createdAt);
  String get storeName =>
      storeNameText.en.trim().isEmpty ? sellerName : storeNameText.en;
  String get storeDescription => storeDescriptionText.en;
  String get accountStatus => vacationMode ? 'Vacation mode' : 'Store live';
  String get primaryAddress {
    final address = user?.addresses.isNotEmpty == true
        ? user!.addresses.first
        : null;
    if (address == null) {
      return 'No business address added yet';
    }
    return '${address.city}, ${address.region}';
  }

  PaymentMethodModel? get payoutMethod =>
      user?.paymentMethods.isNotEmpty == true
      ? user!.paymentMethods.first
      : null;

  String get payoutSummary {
    final method = payoutMethod;
    if (method == null) {
      return 'No payout method connected';
    }
    return '${method.brand} ${method.maskedNumber}';
  }

  List<ProductModel> get sellerProducts =>
      _sellerProductController?.catalogProducts ?? const [];

  int get totalProducts => sellerProducts.length;
  int get activeProducts => sellerProducts
      .where((product) => product.status == ProductStatus.active)
      .length;
  int get pendingProducts => sellerProducts
      .where((product) => product.status == ProductStatus.pendingApproval)
      .length;
  int get lowStockProducts =>
      sellerProducts.where((product) => product.stock <= 5).length;
  int get totalViews =>
      sellerProducts.fold(0, (sum, product) => sum + product.views);
  int get totalSold =>
      sellerProducts.fold(0, (sum, product) => sum + product.soldCount);
  int get returnableProducts =>
      sellerProducts.where((product) => product.isReturnable).length;
  double get storeRating {
    if (_store != null && _store!.reviewCount > 0) {
      return _store!.rating;
    }
    return 0;
  }

  int get followers => _store?.followersCount ?? 0;
  bool get followersAvailable => (_store?.followersCount ?? 0) > 0;

  List<ProductModel> get featuredProducts {
    final products = [...sellerProducts];
    products.sort((a, b) {
      final soldComparison = b.soldCount.compareTo(a.soldCount);
      if (soldComparison != 0) {
        return soldComparison;
      }
      return b.views.compareTo(a.views);
    });
    return products.take(3).toList();
  }

  void toggleVacationMode(bool value) {
    vacationMode = value;
    _persistStoreSettings();
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    _persistStoreSettings();
    notifyListeners();
  }

  String localizedStoreName(Locale locale) => storeNameText.valueFor(locale);

  String localizedStoreDescription(Locale locale) =>
      storeDescriptionText.valueFor(locale);

  void updateDescription(String value) {
    updateSellerProfile(
      sellerName: sellerName,
      phone: sellerPhone,
      storeNameEn: storeNameText.en,
      storeNameAr: storeNameText.ar,
      descriptionEn: value,
      descriptionAr: storeDescriptionText.ar,
    );
  }

  void updateSellerProfile({
    required String sellerName,
    required String phone,
    required String storeNameEn,
    required String storeNameAr,
    required String descriptionEn,
    required String descriptionAr,
  }) {
    storeNameText = LocalizedTextModel(
      en: storeNameEn.trim(),
      ar: storeNameAr.trim(),
    );
    storeDescriptionText = LocalizedTextModel(
      en: descriptionEn.trim(),
      ar: descriptionAr.trim(),
    );
    _persistStoreSettings(sellerName: sellerName.trim(), phone: phone.trim());
    notifyListeners();
  }

  void _persistStoreSettings({String? sellerName, String? phone}) {
    final currentUser = _authController?.currentUser;
    if (currentUser == null) {
      return;
    }
    final now = DateTime.now();
    final store =
        (_store ??
                StoreModel(
                  id: 'store_${currentUser.id}',
                  sellerId: currentUser.id,
                  nameText: storeNameText,
                  descriptionText: storeDescriptionText,
                  policiesText: currentUser.storePoliciesText,
                  rating: _store?.rating ?? 0,
                  reviewCount: 0,
                  followersCount: _store?.followersCount ?? 0,
                  isActive: true,
                  vacationMode: vacationMode,
                  createdAt: currentUser.createdAt,
                  updatedAt: now,
                ))
            .copyWith(
              nameText: storeNameText,
              descriptionText: storeDescriptionText,
              followersCount: _store?.followersCount ?? 0,
              vacationMode: vacationMode,
              updatedAt: now,
            );
    _store = store;
    unawaited(_marketplaceRepository.saveStore(store));
    _authController?.replaceUser(
      currentUser.copyWith(
        sellerVacationMode: vacationMode,
        sellerNotificationsEnabled: notificationsEnabled,
        name: sellerName?.isEmpty == false ? sellerName : currentUser.name,
        phone: phone ?? currentUser.phone,
        storeDescription: storeDescriptionText.en.trim(),
        storeNameText: storeNameText,
        storeDescriptionText: storeDescriptionText,
      ),
    );
  }

  Future<void> _loadStore() async {
    final currentUser = _authController?.currentUser;
    if (currentUser == null) {
      return;
    }
    final store = await _marketplaceRepository.getStoreBySellerId(
      currentUser.id,
    );
    _store = store;
    storeNameText = store?.nameText ?? currentUser.storeNameText;
    storeDescriptionText =
        store?.descriptionText ?? currentUser.storeDescriptionText;
    vacationMode = store?.vacationMode ?? currentUser.sellerVacationMode;
    notifyListeners();
  }
}
