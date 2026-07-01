import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/checkout_controller.dart';
import 'controllers/coupon_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/seller_dashboard_controller.dart';
import 'controllers/seller_finance_controller.dart';
import 'controllers/seller_order_controller.dart';
import 'controllers/seller_product_controller.dart';
import 'controllers/seller_store_controller.dart';
import 'controllers/store_review_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/trend_controller.dart';
import 'controllers/wallet_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/auth_otp_service.dart';
import 'services/cart_service.dart';
import 'services/local_storage_service.dart';
import 'services/mock_data_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'repositories/admin_repository.dart';
import 'repositories/local_admin_repository.dart';
import 'repositories/local_marketplace_repository.dart';
import 'repositories/marketplace_repository.dart';

class StyleHubBootstrap extends StatelessWidget {
  const StyleHubBootstrap({
    super.key,
    required this.localStorageService,
    required this.mockDataService,
  });

  final LocalStorageService localStorageService;
  final MockDataService mockDataService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: localStorageService),
        ChangeNotifierProvider<MockDataService>.value(value: mockDataService),
        Provider<MarketplaceRepository>(
          create: (context) => LocalMarketplaceRepository(
            mockDataService: context.read<MockDataService>(),
          ),
        ),
        Provider<AdminRepository>(
          create: (context) => LocalAdminRepository(
            localStorageService: context.read<LocalStorageService>(),
          ),
        ),
        Provider(create: (_) => AuthOtpService()),
        Provider(
          create: (context) => AuthService(
            context.read<MockDataService>(),
            otpService: context.read<AuthOtpService>(),
          ),
        ),
        Provider(
          create: (context) => ProductService(context.read<MockDataService>()),
        ),
        Provider(
          create: (context) => CartService(context.read<MockDataService>()),
        ),
        Provider(
          create: (context) => OrderService(context.read<MockDataService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeController(
            localStorageService: context.read<LocalStorageService>(),
            mockDataService: context.read<MockDataService>(),
            initialMode: switch (context
                .read<MockDataService>()
                .preferences
                .themeMode) {
              'light' => ThemeMode.light,
              'dark' => ThemeMode.dark,
              _ => ThemeMode.system,
            },
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LanguageController(
            localStorageService: context.read<LocalStorageService>(),
            mockDataService: context.read<MockDataService>(),
          )..initializeLanguage(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthController(authService: context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthController, ProductController>(
          create: (context) => ProductController(
            productService: context.read<ProductService>(),
            mockDataService: context.read<MockDataService>(),
          )..loadInitialData(),
          update: (_, auth, controller) =>
              controller!..bind(authController: auth),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryController(
            mockDataService: context.read<MockDataService>(),
          )..loadCategories(),
        ),
        ChangeNotifierProxyProvider<ProductController, TrendController>(
          create: (context) => TrendController(
            marketplaceRepository: context.read<MarketplaceRepository>(),
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, products, controller) =>
              controller!..bind(productController: products),
        ),
        ChangeNotifierProxyProvider2<
          AuthController,
          ProductController,
          CartController
        >(
          create: (context) =>
              CartController(cartService: context.read<CartService>()),
          update: (_, auth, products, cart) =>
              cart!..bind(authController: auth, productController: products),
        ),
        ChangeNotifierProxyProvider2<
          AuthController,
          ProductController,
          WishlistController
        >(
          create: (_) => WishlistController(),
          update: (_, auth, products, wishlist) =>
              wishlist!
                ..bind(authController: auth, productController: products),
        ),
        ChangeNotifierProxyProvider<AuthController, OrderController>(
          create: (context) =>
              OrderController(orderService: context.read<OrderService>()),
          update: (_, auth, orders) => orders!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider3<
          AuthController,
          CartController,
          OrderController,
          CheckoutController
        >(
          create: (context) => CheckoutController(
            mockDataService: context.read<MockDataService>(),
            orderService: context.read<OrderService>(),
          ),
          update: (_, auth, cart, orders, checkout) => checkout!
            ..bind(
              authController: auth,
              cartController: cart,
              orderController: orders,
            ),
        ),
        ChangeNotifierProvider(
          create: (context) => StoreReviewController(
            marketplaceRepository: context.read<MarketplaceRepository>(),
            mockDataService: context.read<MockDataService>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthController, ProfileController>(
          create: (context) => ProfileController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, profile) => profile!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, CouponController>(
          create: (context) => CouponController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, coupon) => coupon!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, WalletController>(
          create: (context) => WalletController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, wallet) => wallet!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, NotificationController>(
          create: (context) => NotificationController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, notifications) =>
              notifications!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider3<
          AuthController,
          ProductController,
          CategoryController,
          SearchController
        >(
          create: (context) => SearchController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, products, categories, search) => search!
            ..bind(
              authController: auth,
              productController: products,
              categoryController: categories,
            ),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsController(
            mockDataService: context.read<MockDataService>(),
          )..load(),
        ),
        ChangeNotifierProxyProvider<AuthController, SellerDashboardController>(
          create: (context) => SellerDashboardController(
            mockDataService: context.read<MockDataService>(),
          ),
          update: (_, auth, controller) =>
              controller!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, SellerProductController>(
          create: (context) => SellerProductController(
            mockDataService: context.read<MockDataService>(),
            adminRepository: context.read<AdminRepository>(),
            marketplaceRepository: context.read<MarketplaceRepository>(),
          ),
          update: (_, auth, controller) =>
              controller!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, SellerOrderController>(
          create: (context) =>
              SellerOrderController(orderService: context.read<OrderService>()),
          update: (_, auth, controller) =>
              controller!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider<AuthController, SellerFinanceController>(
          create: (context) => SellerFinanceController(
            orderService: context.read<OrderService>(),
          ),
          update: (_, auth, controller) =>
              controller!..bind(authController: auth),
        ),
        ChangeNotifierProxyProvider2<
          AuthController,
          SellerProductController,
          SellerStoreController
        >(
          create: (context) => SellerStoreController(
            marketplaceRepository: context.read<MarketplaceRepository>(),
          ),
          update: (_, auth, products, controller) =>
              controller!
                ..bind(authController: auth, sellerProductController: products),
        ),
      ],
      child: Consumer2<ThemeController, LanguageController>(
        builder: (context, themeController, languageController, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            locale: languageController.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) {
                return const Locale('en');
              }
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('en');
            },
            themeMode: themeController.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.splash,
            builder: (context, child) {
              final activeLocale = Localizations.localeOf(context);
              return Directionality(
                textDirection: languageController.directionFor(activeLocale),
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => SelectionArea(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
