import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({MockDataService? mockDataService})
    : _mockDataService = mockDataService;

  AuthController? _authController;
  final MockDataService? _mockDataService;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  UserModel? get user => _authController?.currentUser;

  void updateName(String name) {
    if (user == null) return;
    _authController!.replaceUser(user!.copyWith(name: name));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String avatar,
    String? password,
  }) {
    if (user == null) {
      return;
    }
    final current = user!;
    final nextUser = current.copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatar: avatar.trim(),
      mockPassword: password == null || password.trim().isEmpty
          ? current.mockPassword
          : password.trim(),
      updatedAt: DateTime.now(),
    );
    _authController!.replaceUser(nextUser);
    _mockDataService?.updateUser(nextUser);
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    if (user == null) return;
    final addresses = [...user!.addresses, address];
    _authController!.replaceUser(user!.copyWith(addresses: addresses));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }

  void deleteAddress(String addressId) {
    if (user == null) return;
    final addresses = user!.addresses
        .where((item) => item.id != addressId)
        .toList();
    _authController!.replaceUser(user!.copyWith(addresses: addresses));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }

  void addPaymentMethod(PaymentMethodModel method) {
    if (user == null) return;
    final methods = [...user!.paymentMethods, method];
    _authController!.replaceUser(user!.copyWith(paymentMethods: methods));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }

  void deletePaymentMethod(String paymentMethodId) {
    if (user == null) return;
    final methods = user!.paymentMethods
        .where((item) => item.id != paymentMethodId)
        .toList();
    _authController!.replaceUser(user!.copyWith(paymentMethods: methods));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }

  void saveMeasurements(Map<String, String> measurements) {
    if (user == null) return;
    _authController!.replaceUser(user!.copyWith(measurements: measurements));
    _mockDataService?.updateUser(_authController!.currentUser!);
    notifyListeners();
  }
}
