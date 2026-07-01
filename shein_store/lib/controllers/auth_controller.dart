import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/widgets/app_bottom_sheet.dart';
import '../models/pending_registration_session.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool isCreatingPassword = false;
  bool isLoggedIn = false;
  bool isGuest = true;
  bool get isFirstLaunch => !_authService.hasSeenOnboarding;
  UserModel? currentUser;
  PendingRegistrationSession? pendingRegistrationSession;
  String? errorMessage;
  UserRole get currentRole => currentUser?.role ?? UserRole.guest;
  bool get isCustomer => currentRole == UserRole.customer;
  bool get isSeller => currentRole == UserRole.seller;
  bool get isAdmin => currentRole == UserRole.admin;
  bool get isAdminActive =>
      currentRole != UserRole.admin || (currentUser?.adminIsActive ?? false);
  String get landingRoute {
    switch (currentRole) {
      case UserRole.seller:
        return AppRoutes.sellerMain;
      case UserRole.admin:
        return AppRoutes.login;
      case UserRole.customer:
      case UserRole.guest:
        return AppRoutes.main;
    }
  }

  Future<void> initializeSession() async {
    isLoading = true;
    notifyListeners();
    await _authService.initialize();
    currentUser = _authService.currentUser;
    isLoggedIn = currentUser != null;
    isGuest = !isLoggedIn;
    isLoading = false;
    notifyListeners();
  }

  void continueAsGuest() {
    unawaited(_authService.continueAsGuest());
    currentUser = null;
    isLoggedIn = false;
    isGuest = true;
    notifyListeners();
  }

  void completeOnboarding() {
    _authService.completeOnboarding();
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await _authService.login(email, password);
      isLoggedIn = true;
      isGuest = false;
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithPhonePassword(String phone, String password) async {
    isLoading = true;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await _authService.loginWithPhonePassword(phone, password);
      isLoggedIn = true;
      isGuest = false;
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await _authService.register(email, password);
      isLoggedIn = true;
      isGuest = false;
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startCustomerRegistration(String fullName, String phone) async {
    isLoading = true;
    isSendingOtp = true;
    errorMessage = null;
    notifyListeners();
    try {
      pendingRegistrationSession = await _authService.startCustomerRegistration(
        fullName: fullName,
        phone: phone,
      );
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String code) async {
    isLoading = true;
    isVerifyingOtp = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.verifyRegistrationOtp(code);
      pendingRegistrationSession = _authService.pendingRegistrationSession;
      return true;
    } catch (error) {
      pendingRegistrationSession = _authService.pendingRegistrationSession;
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      isVerifyingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> resendOtp() async {
    isLoading = true;
    isSendingOtp = true;
    errorMessage = null;
    notifyListeners();
    try {
      pendingRegistrationSession = await _authService.resendRegistrationOtp();
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<bool> createPasswordAndCompleteRegistration(
    String password,
    String confirmPassword,
  ) async {
    isLoading = true;
    isCreatingPassword = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentUser = await _authService.completeCustomerRegistration(
        password: password,
        confirmPassword: confirmPassword,
      );
      pendingRegistrationSession = null;
      isLoggedIn = true;
      isGuest = false;
      return true;
    } catch (error) {
      pendingRegistrationSession = _authService.pendingRegistrationSession;
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      isCreatingPassword = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword(String emailOrPhone) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.forgotPassword(emailOrPhone);
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String emailOrPhone,
    required String code,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.resetPassword(
        emailOrPhone: emailOrPhone,
        code: code,
        password: password,
      );
      return true;
    } catch (error) {
      errorMessage = _errorKey(error);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void replaceUser(UserModel user) {
    currentUser = user;
    isLoggedIn = user.role != UserRole.guest;
    isGuest = user.role == UserRole.guest;
    unawaited(_authService.setCurrentUser(user));
    notifyListeners();
  }

  void logout() {
    unawaited(_authService.logout());
    currentUser = null;
    isLoggedIn = false;
    isGuest = true;
    notifyListeners();
  }

  UserModel? getCurrentUser() => currentUser;

  Future<void> requireAuth(
    BuildContext context,
    FutureOr<void> Function() onAuthenticatedAction,
  ) async {
    if (isLoggedIn) {
      await onAuthenticatedAction();
      return;
    }
    await AppBottomSheet.showAuthRequired(context);
  }

  bool hasRole(UserRole role) => currentRole == role;

  bool hasAnyRole(Set<UserRole> roles) => roles.contains(currentRole);

  bool hasPermission(String permission) {
    return false;
  }

  bool canAccessSellerArea() =>
      currentRole == UserRole.seller &&
      (currentUser?.isSellerAccountActive ?? false);

  bool canAccessAdminArea() => false;

  bool canUseCustomerRestrictedFeatures() => currentRole == UserRole.customer;

  Future<bool> requireRoles(
    BuildContext context, {
    required Set<UserRole> roles,
    String? message,
  }) async {
    if (hasAnyRole(roles)) {
      return true;
    }
    if (roles.contains(UserRole.customer) && currentRole == UserRole.guest) {
      await AppBottomSheet.showAuthRequired(context);
      return false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? 'You do not have permission to access this area.',
          ),
        ),
      );
    }
    return false;
  }

  String _errorKey(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
