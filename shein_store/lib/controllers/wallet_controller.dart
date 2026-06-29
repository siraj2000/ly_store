import 'package:flutter/material.dart';

import '../models/wallet_transaction_model.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class WalletController extends ChangeNotifier {
  WalletController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  AuthController? _authController;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  double get balance => _authController?.currentUser?.walletBalance ?? 0;

  List<WalletTransactionModel> get transactions =>
      _authController?.currentUser?.walletTransactions ??
      _mockDataService.walletTransactions;

  int get redeemedGiftCardCount {
    final userId = _authController?.currentUser?.id ?? '';
    if (userId.isEmpty) {
      return 0;
    }
    return _mockDataService.redeemedGiftCardCount(userId);
  }

  GiftCardRedeemResult redeemGiftCard(String code) {
    final userId = _authController?.currentUser?.id ?? '';
    final result = _mockDataService.redeemGiftCard(
      customerId: userId,
      code: code,
    );
    if (result.user != null) {
      _authController?.replaceUser(result.user!);
    }
    notifyListeners();
    return result;
  }
}
