import '../models/app_preferences_model.dart';
import '../models/pending_registration_session.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../core/helpers/phone_number_normalizer.dart';
import 'auth_otp_service.dart';
import 'mock_data_service.dart';

class AuthService {
  AuthService(this._mockDataService, {AuthOtpService? otpService})
    : _otpService = otpService ?? AuthOtpService();

  final MockDataService _mockDataService;
  final AuthOtpService _otpService;
  UserModel? _currentUser;
  PendingRegistrationSession? _pendingRegistrationSession;
  final Map<String, _PasswordResetSession> _passwordResetSessions = {};

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _currentUser = _mockDataService.currentSessionUser;
    if (_currentUser?.role == UserRole.admin) {
      _currentUser = null;
      await _mockDataService.clearCurrentSession();
    }
  }

  bool get hasSeenOnboarding => _mockDataService.preferences.hasSeenOnboarding;

  void completeOnboarding() {
    _mockDataService.preferences = _mockDataService.preferences.copyWith(
      hasSeenOnboarding: true,
    );
  }

  UserModel? get currentUser => _currentUser;

  PendingRegistrationSession? get pendingRegistrationSession =>
      _pendingRegistrationSession;

  Future<UserModel> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final mockUser = _mockDataService.mockUserForLogin(
      email.trim(),
      password.trim(),
    );
    if (mockUser != null) {
      if (mockUser.role == UserRole.admin) {
        throw Exception('admin_separate_app');
      }
      if (mockUser.role.name == 'seller') {
        if (mockUser.sellerStatus == 'suspended' || !mockUser.isActive) {
          throw Exception('seller_suspended');
        }
        if (mockUser.sellerStatus == 'pending') {
          throw Exception('seller_pending');
        }
        final store = _mockDataService.ensureStoreForSeller(mockUser);
        final refreshedSeller =
            _mockDataService.userById(mockUser.id) ??
            mockUser.copyWith(
              linkedStoreId: store.id,
              updatedAt: DateTime.now(),
            );
        await setCurrentUser(refreshedSeller);
        return _currentUser!;
      }
      await setCurrentUser(mockUser);
      return _currentUser!;
    }
    throw Exception('invalid_credentials');
  }

  Future<UserModel> loginWithPhonePassword(
    String phone,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final normalizedPhone = PhoneNumberNormalizer.normalize(phone);
    if (!PhoneNumberNormalizer.isValid(normalizedPhone)) {
      throw Exception('invalid_phone_number');
    }
    final user = _mockDataService.userByNormalizedPhone(normalizedPhone);
    if (user == null) {
      throw Exception('phone_not_registered');
    }
    if (user.role == UserRole.admin) {
      throw Exception('admin_separate_app');
    }
    if (!user.isActive || user.status == 'suspended') {
      throw Exception('account_suspended');
    }
    if (user.status == 'deleted') {
      throw Exception('account_not_found');
    }
    if (user.role == UserRole.customer && !user.phoneVerified) {
      throw Exception('phone_not_verified');
    }
    if (user.mockPassword != password.trim()) {
      throw Exception('invalid_phone_or_password');
    }
    if (user.role == UserRole.seller) {
      if (user.sellerStatus == 'suspended') {
        throw Exception('seller_suspended');
      }
      if (user.sellerStatus == 'pending') {
        throw Exception('seller_pending');
      }
      final store = _mockDataService.ensureStoreForSeller(user);
      final refreshedSeller =
          _mockDataService.userById(user.id) ??
          user.copyWith(linkedStoreId: store.id, updatedAt: DateTime.now());
      await setCurrentUser(refreshedSeller);
      return _currentUser!;
    }
    await setCurrentUser(user);
    return _currentUser!;
  }

  Future<UserModel> register(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final normalizedEmail = email.trim().toLowerCase();
    if (_mockDataService.userByEmail(normalizedEmail) != null) {
      throw Exception('An account with this email already exists');
    }
    final newUser = _mockDataService.createDefaultUser(
      normalizedEmail,
      password: password.trim(),
      name: _mockDataService.displayNameFromEmail(normalizedEmail),
    );
    await _mockDataService.addUser(newUser);
    await setCurrentUser(newUser);
    return _currentUser!;
  }

  Future<PendingRegistrationSession> startCustomerRegistration({
    required String fullName,
    required String phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final cleanName = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanName.isEmpty) {
      throw Exception('full_name_required');
    }
    if (cleanName.split(' ').where((part) => part.trim().isNotEmpty).length <
        2) {
      throw Exception('full_name_two_words_required');
    }
    final normalizedPhone = PhoneNumberNormalizer.normalize(phone);
    if (!PhoneNumberNormalizer.isValid(normalizedPhone)) {
      throw Exception('invalid_phone_number');
    }
    if (_mockDataService.userByNormalizedPhone(normalizedPhone) != null) {
      throw Exception('phone_already_registered');
    }
    final otp = await _otpService.sendOtp(normalizedPhone);
    _pendingRegistrationSession = PendingRegistrationSession(
      sessionId: 'registration_${DateTime.now().microsecondsSinceEpoch}',
      fullName: cleanName,
      normalizedPhoneNumber: normalizedPhone,
      otpId: otp.otpId,
      expiresAt: otp.expiresAt,
      createdAt: DateTime.now(),
    );
    return _pendingRegistrationSession!;
  }

  Future<void> verifyRegistrationOtp(String code) async {
    final session = _pendingRegistrationSession;
    if (session == null) {
      throw Exception('registration_session_required');
    }
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      throw Exception('otp_required');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      throw Exception('otp_must_be_6_digits');
    }
    final result = await _otpService.verifyOtp(
      otpId: session.otpId,
      code: cleanCode,
    );
    switch (result.status) {
      case OtpVerificationStatus.verified:
        _pendingRegistrationSession = session.copyWith(otpVerified: true);
        return;
      case OtpVerificationStatus.expired:
        throw Exception('otp_expired');
      case OtpVerificationStatus.tooManyAttempts:
        throw Exception('too_many_attempts');
      case OtpVerificationStatus.invalid:
        _pendingRegistrationSession = session.copyWith(
          attemptCount: session.attemptCount + 1,
        );
        throw Exception('invalid_otp');
    }
  }

  Future<PendingRegistrationSession> resendRegistrationOtp() async {
    final session = _pendingRegistrationSession;
    if (session == null) {
      throw Exception('registration_session_required');
    }
    final otp = await _otpService.resendOtp(session.normalizedPhoneNumber);
    _pendingRegistrationSession = session.copyWith(
      otpId: otp.otpId,
      expiresAt: otp.expiresAt,
      attemptCount: 0,
      otpVerified: false,
    );
    return _pendingRegistrationSession!;
  }

  Future<UserModel> completeCustomerRegistration({
    required String password,
    required String confirmPassword,
  }) async {
    final session = _pendingRegistrationSession;
    if (session == null) {
      throw Exception('registration_session_required');
    }
    if (!session.otpVerified) {
      throw Exception('otp_not_verified');
    }
    final nextPassword = password.trim();
    if (nextPassword.isEmpty) {
      throw Exception('password_required');
    }
    if (nextPassword.length < 6) {
      throw Exception('weak_password');
    }
    if (nextPassword != confirmPassword.trim()) {
      throw Exception('passwords_do_not_match');
    }
    final digitsOnly = session.normalizedPhoneNumber.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final email = '$digitsOnly@phone.lystore.local';
    final newUser = _mockDataService
        .createDefaultUser(
          email,
          password: nextPassword,
          name: session.fullName,
        )
        .copyWith(
          phone: session.normalizedPhoneNumber,
          normalizedPhoneNumber: session.normalizedPhoneNumber,
          phoneVerified: true,
          status: 'active',
          updatedAt: DateTime.now(),
        );
    await _mockDataService.addUser(newUser);
    await setCurrentUser(newUser);
    _otpService.clearOtp(session.otpId);
    _pendingRegistrationSession = null;
    return _currentUser!;
  }

  String? debugRegistrationOtpCode() {
    final session = _pendingRegistrationSession;
    if (session == null) {
      return null;
    }
    return _otpService.debugCodeForOtp(session.otpId);
  }

  void expireRegistrationOtpForTesting() {
    final session = _pendingRegistrationSession;
    if (session != null) {
      _otpService.expireOtpForTesting(session.otpId);
    }
  }

  Future<void> forgotPassword(String emailOrPhone) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final account = _mockDataService.userByEmailOrPhone(emailOrPhone);
    if (account == null || !account.isActive) {
      throw Exception('account_not_found');
    }
    // Local password reset is for demo only. Replace with secure server-side reset tokens in production.
    _passwordResetSessions[_resetKey(emailOrPhone)] = _PasswordResetSession(
      userId: account.id,
      code: '123456',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  Future<void> resetPassword({
    required String emailOrPhone,
    required String code,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final key = _resetKey(emailOrPhone);
    final session = _passwordResetSessions[key];
    if (session == null) {
      throw Exception('reset_code_required');
    }
    if (DateTime.now().isAfter(session.expiresAt)) {
      _passwordResetSessions.remove(key);
      throw Exception('reset_code_expired');
    }
    if (session.code != code.trim()) {
      throw Exception('invalid_reset_code');
    }
    final nextPassword = password.trim();
    if (nextPassword.length < 6) {
      throw Exception('weak_password');
    }
    await _mockDataService.updateUserPassword(session.userId, nextPassword);
    _passwordResetSessions.remove(key);
  }

  String _resetKey(String value) => value.trim().toLowerCase();

  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    _mockDataService.updateUser(user);
    await _mockDataService.setCurrentSessionUser(user);
  }

  Future<void> continueAsGuest() async {
    _currentUser = null;
    await _mockDataService.clearCurrentSession();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _mockDataService.clearCurrentSession();
  }

  AppPreferencesModel get preferences => _mockDataService.preferences;

  void savePreferences(AppPreferencesModel preferences) {
    _mockDataService.preferences = preferences;
  }
}

class _PasswordResetSession {
  const _PasswordResetSession({
    required this.userId,
    required this.code,
    required this.expiresAt,
  });

  final String userId;
  final String code;
  final DateTime expiresAt;
}
