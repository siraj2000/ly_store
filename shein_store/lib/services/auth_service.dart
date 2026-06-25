import '../models/app_preferences_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import 'mock_data_service.dart';

class AuthService {
  AuthService(this._mockDataService);

  final MockDataService _mockDataService;
  UserModel? _currentUser;
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
