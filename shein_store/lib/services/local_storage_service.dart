import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  LocalStorageService._(this._preferences);

  static const String _sessionUserKey = 'current_user_session';
  static const String _usersKey = 'registered_users';
  static const String _cartKey = 'current_cart';
  static const String _wishlistKey = 'current_wishlist';
  static const String _ordersKey = 'current_orders';
  static const String _themeModeKey = 'theme_mode';
  static const String _preferencesKey = 'app_preferences';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService._(preferences);
  }

  String userKey(String baseKey, String userId) => '${baseKey}_$userId';

  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? getString(String key) => _preferences.getString(key);

  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool? getBool(String key) => _preferences.getBool(key);

  Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  int? getInt(String key) => _preferences.getInt(key);

  Future<void> saveDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  double? getDouble(String key) => _preferences.getDouble(key);

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _preferences.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await _preferences.setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clearAll() async {
    await _preferences.clear();
  }

  Future<void> saveUser(UserModel user) async {
    await saveJson(_sessionUserKey, user.toJson());
  }

  Future<UserModel?> getUser() async {
    final json = getJson(_sessionUserKey);
    if (json == null) {
      return null;
    }
    return UserModel.fromJson(json);
  }

  Future<void> saveUsers(List<UserModel> users) async {
    await saveJsonList(_usersKey, users.map((user) => user.toJson()).toList());
  }

  Future<List<UserModel>> getUsers() async {
    return getJsonList(_usersKey).map(UserModel.fromJson).toList();
  }

  Future<void> saveCart(List<CartItemModel> cart) async {
    await saveJsonList(_cartKey, cart.map((item) => item.toJson()).toList());
  }

  Future<List<CartItemModel>> getCart() async {
    return getJsonList(_cartKey).map(CartItemModel.fromJson).toList();
  }

  Future<void> saveWishlist(List<ProductModel> wishlist) async {
    await saveJsonList(
      _wishlistKey,
      wishlist.map((product) => product.toJson()).toList(),
    );
  }

  Future<List<ProductModel>> getWishlist() async {
    return getJsonList(_wishlistKey).map(ProductModel.fromJson).toList();
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    await saveJsonList(
      _ordersKey,
      orders.map((order) => order.toJson()).toList(),
    );
  }

  Future<List<OrderModel>> getOrders() async {
    return getJsonList(_ordersKey).map(OrderModel.fromJson).toList();
  }

  Future<void> saveThemeMode(String mode) async {
    await saveString(_themeModeKey, mode);
  }

  Future<String?> getThemeMode() async {
    return getString(_themeModeKey);
  }

  Future<void> saveAppPreferences(AppPreferencesModel preferences) async {
    await saveJson(_preferencesKey, preferences.toJson());
  }

  Future<AppPreferencesModel?> getAppPreferences() async {
    final json = getJson(_preferencesKey);
    if (json == null) {
      return null;
    }
    return AppPreferencesModel.fromJson(json);
  }

  Future<void> logout() async {
    await clearUserSession();
  }

  Future<void> clearUserSession() async {
    await remove(_sessionUserKey);
  }
}
