import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/core/constants/app_routes.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';

void main() {
  group('admin separation', () {
    test('admin demo accounts are blocked from this app', () async {
      final context = await _AuthTestContext.create();
      final auth = context.authController;

      final success = await auth.loginWithEmail('admin@stylehub.com', '123456');

      expect(success, isFalse);
      expect(auth.isLoggedIn, isFalse);
      expect(auth.errorMessage, 'admin_separate_app');
      expect(auth.canAccessAdminArea(), isFalse);
      expect(auth.hasPermission('*'), isFalse);
    });

    test(
      'customer and seller accounts still land in the marketplace app',
      () async {
        final customerContext = await _AuthTestContext.create();
        final customerAuth = customerContext.authController;

        expect(
          await customerAuth.loginWithEmail('customer@stylehub.com', '123456'),
          isTrue,
        );
        expect(customerAuth.landingRoute, AppRoutes.main);

        final sellerContext = await _AuthTestContext.create();
        final sellerAuth = sellerContext.authController;

        expect(
          await sellerAuth.loginWithEmail('seller@stylehub.com', '123456'),
          isTrue,
        );
        expect(sellerAuth.landingRoute, AppRoutes.sellerMain);
        expect(sellerAuth.canAccessSellerArea(), isTrue);
      },
    );
  });
}

class _AuthTestContext {
  const _AuthTestContext({required this.authController});

  final AuthController authController;

  static Future<_AuthTestContext> create() async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockData = await MockDataService.create(
      localStorageService: localStorageService,
    );
    return _AuthTestContext(
      authController: AuthController(authService: AuthService(mockData)),
    );
  }
}
