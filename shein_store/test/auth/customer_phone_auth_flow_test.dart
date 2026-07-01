import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/core/constants/app_routes.dart';
import 'package:stylehub_store/core/helpers/phone_number_normalizer.dart';
import 'package:stylehub_store/core/theme/app_theme.dart';
import 'package:stylehub_store/l10n/generated/app_localizations.dart';
import 'package:stylehub_store/models/user_role.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/views/screens/auth/login_screen.dart';
import 'package:stylehub_store/views/screens/auth/register_screen.dart';

void main() {
  group('phone number normalizer', () {
    test('normalizes Libyan numbers and Arabic digits', () {
      expect(PhoneNumberNormalizer.normalize('0912345678'), '+218912345678');
      expect(PhoneNumberNormalizer.normalize('218912345678'), '+218912345678');
      expect(PhoneNumberNormalizer.normalize('+218912345678'), '+218912345678');
      expect(PhoneNumberNormalizer.normalize('٠٩١٢٣٤٥٦٧٨'), '+218912345678');
    });
  });

  group('customer phone auth flow', () {
    test('register requires full name and valid phone', () async {
      final context = await _AuthTestContext.create();

      await expectLater(
        context.auth.startCustomerRegistration(
          fullName: '',
          phone: '0912345678',
        ),
        throwsA(_exceptionContaining('full_name_required')),
      );

      await expectLater(
        context.auth.startCustomerRegistration(
          fullName: 'Demo User',
          phone: '123',
        ),
        throwsA(_exceptionContaining('invalid_phone_number')),
      );
    });

    test('duplicate phone cannot register again', () async {
      final context = await _AuthTestContext.create();

      await expectLater(
        context.auth.startCustomerRegistration(
          fullName: 'Demo User',
          phone: '+1 555 0100',
        ),
        throwsA(_exceptionContaining('phone_already_registered')),
      );
    });

    test('OTP generated, wrong, expired, and too many attempts fail', () async {
      final wrongContext = await _AuthTestContext.create();
      await wrongContext.auth.startCustomerRegistration(
        fullName: 'New Customer',
        phone: '0912345678',
      );
      expect(wrongContext.auth.debugRegistrationOtpCode(), isNotNull);
      await expectLater(
        wrongContext.auth.verifyRegistrationOtp('000000'),
        throwsA(_exceptionContaining('invalid_otp')),
      );

      final expiredContext = await _AuthTestContext.create();
      await expiredContext.auth.startCustomerRegistration(
        fullName: 'Fresh Customer',
        phone: '0912345679',
      );
      final expiredCode = expiredContext.auth.debugRegistrationOtpCode()!;
      expiredContext.auth.expireRegistrationOtpForTesting();
      await expectLater(
        expiredContext.auth.verifyRegistrationOtp(expiredCode),
        throwsA(_exceptionContaining('otp_expired')),
      );

      final attemptsContext = await _AuthTestContext.create();
      await attemptsContext.auth.startCustomerRegistration(
        fullName: 'Careful Customer',
        phone: '0912345680',
      );
      for (var attempt = 0; attempt < 5; attempt++) {
        await expectLater(
          attemptsContext.auth.verifyRegistrationOtp('111111'),
          throwsA(_exceptionContaining('invalid_otp')),
        );
      }
      await expectLater(
        attemptsContext.auth.verifyRegistrationOtp('111111'),
        throwsA(_exceptionContaining('too_many_attempts')),
      );
    });

    test('correct OTP verifies and password rules are enforced', () async {
      final context = await _AuthTestContext.create();
      await context.auth.startCustomerRegistration(
        fullName: 'Mira Customer',
        phone: '0912345681',
      );

      await expectLater(
        context.auth.completeCustomerRegistration(
          password: 'secret1',
          confirmPassword: 'secret1',
        ),
        throwsA(_exceptionContaining('otp_not_verified')),
      );

      final code = context.auth.debugRegistrationOtpCode()!;
      await context.auth.verifyRegistrationOtp(code);
      expect(context.auth.pendingRegistrationSession?.otpVerified, isTrue);

      await expectLater(
        context.auth.completeCustomerRegistration(
          password: 'secret1',
          confirmPassword: 'secret2',
        ),
        throwsA(_exceptionContaining('passwords_do_not_match')),
      );
    });

    test(
      'successful registration creates verified customer and login works',
      () async {
        final context = await _AuthTestContext.create();
        await context.auth.startCustomerRegistration(
          fullName: 'Lina Customer',
          phone: '0912345682',
        );
        await context.auth.verifyRegistrationOtp(
          context.auth.debugRegistrationOtpCode()!,
        );
        final user = await context.auth.completeCustomerRegistration(
          password: 'secret1',
          confirmPassword: 'secret1',
        );

        expect(user.role, UserRole.customer);
        expect(user.phoneVerified, isTrue);
        expect(user.normalizedPhoneNumber, '+218912345682');

        await context.auth.logout();
        final loggedIn = await context.auth.loginWithPhonePassword(
          '0912345682',
          'secret1',
        );
        expect(loggedIn.id, user.id);
      },
    );

    test('login fails with wrong password and unverified account', () async {
      final context = await _AuthTestContext.create();
      await expectLater(
        context.auth.loginWithPhonePassword('+1 555 0100', 'badpass'),
        throwsA(_exceptionContaining('invalid_phone_or_password')),
      );

      final pendingUser = context.mockData
          .createDefaultUser(
            'pending@phone.lystore.local',
            password: 'secret1',
            name: 'Pending User',
          )
          .copyWith(
            phone: '+218912345683',
            normalizedPhoneNumber: '+218912345683',
            phoneVerified: false,
            status: 'pending_verification',
          );
      await context.mockData.addUser(pendingUser);

      await expectLater(
        context.auth.loginWithPhonePassword('0912345683', 'secret1'),
        throwsA(_exceptionContaining('phone_not_verified')),
      );
    });
  });

  group('auth screens layout', () {
    testWidgets('English LTR login screen does not overflow', (tester) async {
      final context = await _AuthTestContext.create();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _AuthScreenHarness(
          authController: context.controller,
          locale: const Locale('en'),
          themeMode: ThemeMode.light,
          child: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic RTL register screen works in dark mode', (
      tester,
    ) async {
      final context = await _AuthTestContext.create();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _AuthScreenHarness(
          authController: context.controller,
          locale: const Locale('ar'),
          themeMode: ThemeMode.dark,
          child: const RegisterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

Matcher _exceptionContaining(String text) {
  return predicate<Object>((error) => error.toString().contains(text));
}

class _AuthTestContext {
  const _AuthTestContext({
    required this.auth,
    required this.controller,
    required this.mockData,
  });

  final AuthService auth;
  final AuthController controller;
  final MockDataService mockData;

  static Future<_AuthTestContext> create() async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockData = await MockDataService.create(
      localStorageService: localStorageService,
    );
    final auth = AuthService(mockData);
    return _AuthTestContext(
      auth: auth,
      controller: AuthController(authService: auth),
      mockData: mockData,
    );
  }
}

class _AuthScreenHarness extends StatelessWidget {
  const _AuthScreenHarness({
    required this.authController,
    required this.locale,
    required this.themeMode,
    required this.child,
  });

  final AuthController authController;
  final Locale locale;
  final ThemeMode themeMode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>.value(
      value: authController,
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.otpVerification: (_) => const SizedBox.shrink(),
        },
        home: child,
      ),
    );
  }
}
