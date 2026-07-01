import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/widgets/app_loading.dart';
import '../../models/user_role.dart';
import 'app_motion.dart';
import '../../views/screens/address/address_book_screen.dart';
import '../../views/screens/address/address_form_screen.dart';
import '../../views/screens/auth/create_password_screen.dart';
import '../../views/screens/auth/forgot_password_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/otp_verification_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/cart/cart_screen.dart';
import '../../views/screens/category/category_screen.dart';
import '../../views/screens/checkout/checkout_screen.dart';
import '../../views/screens/checkout/order_success_screen.dart';
import '../../views/screens/coupons/coupons_screen.dart';
import '../../views/screens/coupons/gift_card_screen.dart';
import '../../views/screens/coupons/points_screen.dart';
import '../../views/screens/coupons/wallet_screen.dart';
import '../../views/screens/customer_service/help_center_screen.dart';
import '../../views/screens/customer_service/live_chat_screen.dart';
import '../../views/screens/main/main_tab_screen.dart';
import '../../views/screens/measurements/measurements_screen.dart';
import '../../views/screens/notifications/notifications_screen.dart';
import '../../views/screens/onboarding/onboarding_screen.dart';
import '../../views/screens/orders/order_details_screen.dart';
import '../../views/screens/orders/orders_screen.dart';
import '../../views/screens/payment/payment_form_screen.dart';
import '../../views/screens/payment/payment_options_screen.dart';
import '../../views/screens/product/product_details_screen.dart';
import '../../views/screens/product/product_listing_screen.dart';
import '../../views/screens/profile/edit_profile_screen.dart';
import '../../views/screens/profile/recently_viewed_screen.dart';
import '../../views/screens/store/all_stores_screen.dart';
import '../../views/screens/store/storefront_screen.dart';
import '../../views/screens/search/search_screen.dart';
import '../../views/screens/settings/account_security_screen.dart';
import '../../views/screens/settings/settings_screen.dart';
import '../../views/screens/splash/splash_screen.dart';
import '../../views/screens/wishlist/wishlist_board_screen.dart';
import '../../views/screens/wishlist/wishlist_screen.dart';
import '../../views/screens/seller/seller_add_product_screen.dart';
import '../../views/screens/seller/seller_edit_product_screen.dart';
import '../../views/screens/seller/seller_finance_screen.dart';
import '../../views/screens/seller/seller_main_screen.dart';
import '../../views/screens/seller/seller_order_details_screen.dart';
import '../../views/screens/seller/seller_orders_screen.dart';
import '../../views/screens/seller/seller_products_screen.dart';
import '../../views/screens/seller/seller_store_screen.dart';
import '../../views/screens/seller/seller_dashboard_screen.dart';
import '../../models/product_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String createPassword = '/create-password';
  static const String forgotPassword = '/forgot-password';
  static const String search = '/search';
  static const String productListing = '/product-listing';
  static const String productDetails = '/product-details';
  static const String allStores = '/all-stores';
  static const String storefront = '/storefront';
  static const String wishlist = '/wishlist';
  static const String wishlistBoard = '/wishlist-board';
  static const String recentlyViewed = '/recently-viewed';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String editProfile = '/edit-profile';
  static const String addressBook = '/address-book';
  static const String addressForm = '/address-form';
  static const String paymentOptions = '/payment-options';
  static const String paymentForm = '/payment-form';
  static const String measurements = '/measurements';
  static const String coupons = '/coupons';
  static const String points = '/points';
  static const String wallet = '/wallet';
  static const String giftCard = '/gift-card';
  static const String notifications = '/notifications';
  static const String helpCenter = '/help-center';
  static const String liveChat = '/live-chat';
  static const String settings = '/settings';
  static const String accountSecurity = '/account-security';
  static const String categories = '/categories';
  static const String sellerMain = '/seller-main';
  static const String sellerDashboard = '/seller-dashboard';
  static const String sellerProducts = '/seller-products';
  static const String sellerAddProduct = '/seller-add-product';
  static const String sellerEditProduct = '/seller-edit-product';
  static const String sellerOrders = '/seller-orders';
  static const String sellerOrderDetails = '/seller-order-details';
  static const String sellerFinance = '/seller-finance';
  static const String sellerStore = '/seller-store';
  static const String adminMain = '/admin-main';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminAccounts = '/admin-accounts';
  static const String adminCustomers = '/admin-customers';
  static const String adminSellers = '/admin-sellers';
  static const String adminAddSeller = '/admin-sellers/add';
  static const String adminEditSeller = '/admin-sellers/edit';
  static const String adminSellerDetails = '/admin-sellers/details';
  static const String adminStoreDetails = '/admin-stores/details';
  static const String adminSellerApproval = '/admin-seller-approval';
  static const String adminProductApproval = '/admin-product-approval';
  static const String adminProducts = '/admin-products';
  static const String adminCategories = '/admin-categories';
  static const String adminOrders = '/admin-orders';
  static const String adminCoupons = '/admin-coupons';
  static const String adminBanners = '/admin-banners';
  static const String adminReports = '/admin-reports';
  static const String adminComplaints = '/admin-complaints';
  static const String adminSettings = '/admin-settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _animatedRoute(
          routeSettings,
          child: const SplashScreen(),
          animate: false,
        );
      case onboarding:
        return _animatedRoute(routeSettings, child: const OnboardingScreen());
      case main:
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: const MainTabScreen(),
        );
      case login:
        return _animatedRoute(routeSettings, child: const LoginScreen());
      case register:
        return _animatedRoute(routeSettings, child: const RegisterScreen());
      case otpVerification:
        return _animatedRoute(
          routeSettings,
          child: const OtpVerificationScreen(),
        );
      case createPassword:
        return _animatedRoute(
          routeSettings,
          child: const CreatePasswordScreen(),
        );
      case forgotPassword:
        return _animatedRoute(
          routeSettings,
          child: const ForgotPasswordScreen(),
        );
      case search:
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: const SearchScreen(),
        );
      case productListing:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: ProductListingScreen(
            title: args['title'] as String? ?? 'Products',
            categoryId: args['categoryId'] as String?,
            categoryIds: (args['categoryIds'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(),
            subcategoryId: args['subcategoryId'] as String?,
            department: args['department'] as String?,
            campaignTag: args['campaignTag'] as String?,
          ),
        );
      case productDetails:
        final productId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: ProductDetailsScreen(productId: productId),
        );
      case allStores:
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: const AllStoresScreen(),
        );
      case storefront:
        final storeId = routeSettings.arguments as String? ?? '';
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: StorefrontScreen(storeId: storeId),
        );
      case wishlist:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const WishlistScreen(),
        );
      case wishlistBoard:
        final boardId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: WishlistBoardScreen(boardId: boardId),
        );
      case recentlyViewed:
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: const RecentlyViewedScreen(),
        );
      case cart:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const CartScreen(),
        );
      case checkout:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const CheckoutScreen(),
        );
      case orderSuccess:
        final orderId = routeSettings.arguments as String? ?? '';
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: OrderSuccessScreen(orderId: orderId),
        );
      case orders:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: OrdersScreen(
            initialStatus: args['status'] as String? ?? 'All',
          ),
        );
      case orderDetails:
        final orderId = routeSettings.arguments as String? ?? '';
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: OrderDetailsScreen(orderId: orderId),
        );
      case editProfile:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const EditProfileScreen(),
        );
      case addressBook:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const AddressBookScreen(),
        );
      case addressForm:
        final addressId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: AddressFormScreen(addressId: addressId),
        );
      case paymentOptions:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const PaymentOptionsScreen(),
        );
      case paymentForm:
        final paymentMethodId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: PaymentFormScreen(paymentMethodId: paymentMethodId),
        );
      case measurements:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const MeasurementsScreen(),
        );
      case coupons:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const CouponsScreen(),
        );
      case points:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const PointsScreen(),
        );
      case wallet:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const WalletScreen(),
        );
      case giftCard:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const GiftCardScreen(),
        );
      case notifications:
        return _guardedRoute(
          allowedRoles: const {
            UserRole.guest,
            UserRole.customer,
            UserRole.seller,
          },
          child: const NotificationsScreen(),
        );
      case helpCenter:
        final orderId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: HelpCenterScreen(orderId: orderId),
        );
      case liveChat:
        final orderId = routeSettings.arguments as String?;
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: LiveChatScreen(orderId: orderId),
        );
      case AppRoutes.settings:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const SettingsScreen(),
        );
      case accountSecurity:
        return _guardedRoute(
          allowedRoles: const {UserRole.customer},
          child: const AccountSecurityScreen(),
        );
      case categories:
        return _guardedRoute(
          allowedRoles: const {UserRole.guest, UserRole.customer},
          child: const CategoryScreen(),
        );
      case sellerMain:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerMainScreen(),
        );
      case sellerDashboard:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerDashboardScreen(),
        );
      case sellerProducts:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerProductsScreen(),
        );
      case sellerAddProduct:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerAddProductScreen(),
        );
      case sellerEditProduct:
        final product = routeSettings.arguments as ProductModel?;
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: SellerEditProductScreen(product: product),
        );
      case sellerOrders:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerOrdersScreen(),
        );
      case sellerOrderDetails:
        final orderId = routeSettings.arguments as String? ?? '';
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: SellerOrderDetailsScreen(orderId: orderId),
        );
      case sellerFinance:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerFinanceScreen(),
        );
      case sellerStore:
        return _guardedRoute(
          allowedRoles: const {UserRole.seller},
          child: const SellerStoreScreen(),
        );
      case adminMain:
      case adminDashboard:
      case adminAccounts:
      case adminCustomers:
      case adminSellers:
      case adminAddSeller:
      case adminEditSeller:
      case adminSellerDetails:
      case adminStoreDetails:
      case adminSellerApproval:
      case adminProductApproval:
      case adminProducts:
      case adminCategories:
      case adminOrders:
      case adminCoupons:
      case adminBanners:
      case adminReports:
      case adminComplaints:
      case adminSettings:
        return _animatedRoute(routeSettings, child: const _AdminMovedScreen());
      default:
        return _animatedRoute(routeSettings, child: const SplashScreen());
    }
  }

  static Route<dynamic> _guardedRoute({
    required Set<UserRole> allowedRoles,
    required Widget child,
  }) {
    return _animatedRoute(
      null,
      child: _RoleGuard(allowedRoles: allowedRoles, child: child),
    );
  }

  static Route<dynamic> _animatedRoute(
    RouteSettings? settings, {
    required Widget child,
    bool animate = true,
  }) {
    if (!animate) {
      return MaterialPageRoute(settings: settings, builder: (_) => child);
    }

    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: AppMotion.pageTransition,
      reverseTransitionDuration: AppMotion.fast,
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (AppMotion.reduceMotion(context)) {
          return child;
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.standard,
          reverseCurve: AppMotion.emphasized,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: AppMotion.pageSlideOffset(context),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _AdminMovedScreen extends StatelessWidget {
  const _AdminMovedScreen();

  static const _messageEn =
      'Admin access is available in the separate Admin application.';
  static const _messageAr = 'دخول الإدارة متاح من خلال تطبيق الإدارة المنفصل.';

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings_outlined, size: 56),
              const SizedBox(height: 14),
              Text(
                isArabic ? _messageAr : _messageEn,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                ),
                child: Text(isArabic ? 'العودة' : 'Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleGuard extends StatelessWidget {
  const _RoleGuard({required this.allowedRoles, required this.child});

  final Set<UserRole> allowedRoles;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final requiresAdmin = allowedRoles.contains(UserRole.admin);
    final requiresSeller = allowedRoles.contains(UserRole.seller);
    final hasAllowedRole = allowedRoles.contains(authController.currentRole);
    if (hasAllowedRole &&
        (!requiresAdmin || authController.isAdminActive) &&
        (!requiresSeller || authController.canAccessSellerArea())) {
      return child;
    }
    final guestNeedsCustomer =
        authController.currentRole == UserRole.guest &&
        allowedRoles.contains(UserRole.customer);
    final inactiveAdminBlocked =
        requiresAdmin &&
        authController.currentRole == UserRole.admin &&
        !authController.isAdminActive;
    final inactiveSellerBlocked =
        requiresSeller &&
        authController.currentRole == UserRole.seller &&
        !authController.canAccessSellerArea();
    final shouldRedirectToLanding =
        !guestNeedsCustomer && !inactiveAdminBlocked && !inactiveSellerBlocked;
    if (shouldRedirectToLanding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          authController.landingRoute,
          (_) => false,
        );
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Redirecting')),
        body: const AppLoading(
          layout: AppLoadingLayout.list,
          message: 'Redirecting to the correct screen for your account...',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Access Restricted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                inactiveAdminBlocked
                    ? 'Your admin account is inactive.'
                    : inactiveSellerBlocked
                    ? 'Your seller account is not active.'
                    : guestNeedsCustomer
                    ? 'Sign in as a customer to continue.'
                    : 'This area is not available for your current role.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  guestNeedsCustomer
                      ? AppRoutes.login
                      : authController.landingRoute,
                  (_) => false,
                ),
                child: Text(guestNeedsCustomer ? 'Sign In' : 'Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
