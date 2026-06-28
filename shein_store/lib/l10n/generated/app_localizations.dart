import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get commonDetails;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get commonSystemDefault;

  /// No description provided for @commonCountWithLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String commonCountWithLabel(Object label, int count);

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get navCategory;

  /// No description provided for @navTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get navTrends;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navProfile;

  /// No description provided for @trendsTitle.
  ///
  /// In en, this message translates to:
  /// **'LY STORE Trends'**
  String get trendsTitle;

  /// No description provided for @trendsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trends, stores, or products'**
  String get trendsSearchHint;

  /// No description provided for @trendsTrendingPicks.
  ///
  /// In en, this message translates to:
  /// **'Trending Picks'**
  String get trendsTrendingPicks;

  /// No description provided for @trendsStore.
  ///
  /// In en, this message translates to:
  /// **'Trends Store'**
  String get trendsStore;

  /// No description provided for @trendsForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get trendsForYou;

  /// No description provided for @trendsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get trendsFilter;

  /// No description provided for @trendsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get trendsCategory;

  /// No description provided for @trendsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get trendsNew;

  /// No description provided for @trendsViewStore.
  ///
  /// In en, this message translates to:
  /// **'View Store'**
  String get trendsViewStore;

  /// No description provided for @trendsSoldCount.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get trendsSoldCount;

  /// No description provided for @trendsFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get trendsFollowers;

  /// No description provided for @trendsNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No trending products found'**
  String get trendsNoProducts;

  /// No description provided for @trendsNoStores.
  ///
  /// In en, this message translates to:
  /// **'No trend stores found'**
  String get trendsNoStores;

  /// No description provided for @trendsNoResults.
  ///
  /// In en, this message translates to:
  /// **'Try another search, tag, or category filter.'**
  String get trendsNoResults;

  /// No description provided for @trendsCampaignShopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get trendsCampaignShopNow;

  /// No description provided for @trendsCloseFilter.
  ///
  /// In en, this message translates to:
  /// **'Close filter'**
  String get trendsCloseFilter;

  /// No description provided for @trendsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get trendsAll;

  /// No description provided for @trendsStoreNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get trendsStoreNewBadge;

  /// No description provided for @trendsStoreTrendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trendsStoreTrendingBadge;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get navStore;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCountryRegion.
  ///
  /// In en, this message translates to:
  /// **'Country / Region'**
  String get settingsCountryRegion;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsNotifications;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsLightMode;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsPrivacyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Privacy Preferences'**
  String get settingsPrivacyPreferences;

  /// No description provided for @settingsManageVisibility.
  ///
  /// In en, this message translates to:
  /// **'Manage visibility and app permissions'**
  String get settingsManageVisibility;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mock action for demo purposes'**
  String get settingsClearCacheSubtitle;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAboutApp;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Original Flutter marketplace demo'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTermsConditions;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign out and return to guest mode?'**
  String get settingsLogoutMessage;

  /// No description provided for @settingsSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemLanguage;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsArabic;

  /// No description provided for @settingsCountryUs.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get settingsCountryUs;

  /// No description provided for @settingsCountryUk.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get settingsCountryUk;

  /// No description provided for @settingsCountryUae.
  ///
  /// In en, this message translates to:
  /// **'UAE'**
  String get settingsCountryUae;

  /// No description provided for @profileSwitchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get profileSwitchToEnglish;

  /// No description provided for @profileSwitchToArabic.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get profileSwitchToArabic;

  /// No description provided for @profileSwitchToLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get profileSwitchToLightMode;

  /// No description provided for @profileSwitchToDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get profileSwitchToDarkMode;

  /// No description provided for @profileAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get profileAssets;

  /// No description provided for @profileCoupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get profileCoupons;

  /// No description provided for @profilePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get profileWallet;

  /// No description provided for @profileGiftCard.
  ///
  /// In en, this message translates to:
  /// **'Gift Card'**
  String get profileGiftCard;

  /// No description provided for @profileMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get profileMyOrders;

  /// No description provided for @profileOrderUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get profileOrderUnpaid;

  /// No description provided for @profileOrderReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get profileOrderReview;

  /// No description provided for @profileOrderReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get profileOrderReturns;

  /// No description provided for @profileWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileWishlist;

  /// No description provided for @profileRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get profileRecentlyViewed;

  /// No description provided for @profileAddressBook.
  ///
  /// In en, this message translates to:
  /// **'Address Book'**
  String get profileAddressBook;

  /// No description provided for @profilePaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Payment Options'**
  String get profilePaymentOptions;

  /// No description provided for @profileCustomerService.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get profileCustomerService;

  /// No description provided for @profileWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LY STORE'**
  String get profileWelcomeTitle;

  /// No description provided for @profileWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites, track orders, and unlock member perks.'**
  String get profileWelcomeSubtitle;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get profileCreateAccount;

  /// No description provided for @profilePointsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{points} points available'**
  String profilePointsAvailable(int points);

  /// No description provided for @onboardingStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop trends at great prices'**
  String get onboardingStartTitle;

  /// No description provided for @onboardingStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover fashion, beauty, home, accessories, and more.'**
  String get onboardingStartSubtitle;

  /// No description provided for @onboardingStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get onboardingStartShopping;

  /// No description provided for @onboardingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get onboardingSignIn;

  /// No description provided for @onboardingStayCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay close to every drop'**
  String get onboardingStayCloseTitle;

  /// No description provided for @onboardingStayCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get sale alerts, new arrivals, and order updates.'**
  String get onboardingStayCloseSubtitle;

  /// No description provided for @onboardingEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get onboardingEnableNotifications;

  /// No description provided for @onboardingNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get onboardingNotNow;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your shopping region'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your country, language, and currency preferences.'**
  String get onboardingPreferencesSubtitle;

  /// No description provided for @onboardingCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get onboardingCountry;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get onboardingCurrency;

  /// No description provided for @languageEnglishNative.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishNative;

  /// No description provided for @languageArabicNative.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabicNative;

  /// No description provided for @sellerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Orders'**
  String get sellerOrdersTitle;

  /// No description provided for @sellerOrdersHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Manager'**
  String get sellerOrdersHeroTitle;

  /// No description provided for @sellerOrdersHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review every order lane with clearer status flow and product previews.'**
  String get sellerOrdersHeroSubtitle;

  /// No description provided for @sellerOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order id, customer, product, or SKU'**
  String get sellerOrdersSearchHint;

  /// No description provided for @sellerOrdersTotal.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get sellerOrdersTotal;

  /// No description provided for @sellerOrdersOrderLanes.
  ///
  /// In en, this message translates to:
  /// **'Order lanes'**
  String get sellerOrdersOrderLanes;

  /// No description provided for @sellerOrdersLaneTitle.
  ///
  /// In en, this message translates to:
  /// **'{status} orders'**
  String sellerOrdersLaneTitle(Object status);

  /// No description provided for @sellerOrdersLaneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders in this lane} =1{1 order in this lane} other{{count} orders in this lane}}'**
  String sellerOrdersLaneSubtitle(int count);

  /// No description provided for @sellerOrdersOrganizedByStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders organized by status} =1{1 order organized by status} other{{count} orders organized by status}}'**
  String sellerOrdersOrganizedByStatus(int count);

  /// No description provided for @sellerOrdersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 order} other{{count} orders}}'**
  String sellerOrdersCountLabel(int count);

  /// No description provided for @sellerOrdersNoOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No seller orders yet'**
  String get sellerOrdersNoOrdersTitle;

  /// No description provided for @sellerOrdersNoOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'New customer orders will appear here as they come in.'**
  String get sellerOrdersNoOrdersMessage;

  /// No description provided for @sellerOrdersNothingInLaneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this lane'**
  String get sellerOrdersNothingInLaneTitle;

  /// No description provided for @sellerOrdersNothingInLaneMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another status or wait for new order activity.'**
  String get sellerOrdersNothingInLaneMessage;

  /// No description provided for @sellerOrdersAcceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get sellerOrdersAcceptOrder;

  /// No description provided for @sellerOrdersPrepareOrder.
  ///
  /// In en, this message translates to:
  /// **'Prepare Order'**
  String get sellerOrdersPrepareOrder;

  /// No description provided for @sellerOrdersMarkShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark Shipped'**
  String get sellerOrdersMarkShipped;

  /// No description provided for @sellerOrdersMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get sellerOrdersMarkDelivered;

  /// No description provided for @sellerOrdersShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get sellerOrdersShipping;

  /// No description provided for @sellerOrdersCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get sellerOrdersCommission;

  /// No description provided for @sellerOrdersItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get sellerOrdersItems;

  /// No description provided for @sellerOrdersOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get sellerOrdersOrderSummary;

  /// No description provided for @sellerOrdersCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get sellerOrdersCustomer;

  /// No description provided for @sellerOrdersOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get sellerOrdersOrderDate;

  /// No description provided for @sellerOrdersEstimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get sellerOrdersEstimatedDelivery;

  /// No description provided for @sellerOrdersAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sellerOrdersAddress;

  /// No description provided for @sellerOrdersSellerNet.
  ///
  /// In en, this message translates to:
  /// **'Seller net'**
  String get sellerOrdersSellerNet;

  /// No description provided for @sellerOrderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Order Details'**
  String get sellerOrderDetailsTitle;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusReadyToShip.
  ///
  /// In en, this message translates to:
  /// **'Ready to Ship'**
  String get statusReadyToShip;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get commonManage;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @sellerAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get sellerAddProduct;

  /// No description provided for @sellerEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get sellerEditProduct;

  /// No description provided for @sellerSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get sellerSaveDraft;

  /// No description provided for @sellerSubmitApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for Approval'**
  String get sellerSubmitApproval;

  /// No description provided for @sellerSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get sellerSaving;

  /// No description provided for @sellerProductSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully'**
  String get sellerProductSaved;

  /// No description provided for @sellerProductSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Product submitted for approval'**
  String get sellerProductSubmitted;

  /// No description provided for @sellerEnglishContent.
  ///
  /// In en, this message translates to:
  /// **'English Content'**
  String get sellerEnglishContent;

  /// No description provided for @sellerArabicContent.
  ///
  /// In en, this message translates to:
  /// **'Arabic Content'**
  String get sellerArabicContent;

  /// No description provided for @sellerEnglishContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the buyer-facing English copy for this product.'**
  String get sellerEnglishContentSubtitle;

  /// No description provided for @sellerArabicContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the buyer-facing Arabic copy for this product.'**
  String get sellerArabicContentSubtitle;

  /// No description provided for @sellerProductFormHeroCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a polished listing'**
  String get sellerProductFormHeroCreateTitle;

  /// No description provided for @sellerProductFormHeroEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your product'**
  String get sellerProductFormHeroEditTitle;

  /// No description provided for @sellerProductFormHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use clear sections, bilingual content, and product images so the listing is easier to manage and approve.'**
  String get sellerProductFormHeroSubtitle;

  /// No description provided for @sellerProductTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Product Title (English)'**
  String get sellerProductTitleEn;

  /// No description provided for @sellerProductTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Product Title (Arabic)'**
  String get sellerProductTitleAr;

  /// No description provided for @sellerProductDescriptionEn.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get sellerProductDescriptionEn;

  /// No description provided for @sellerProductDescriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get sellerProductDescriptionAr;

  /// No description provided for @sellerMaterialEn.
  ///
  /// In en, this message translates to:
  /// **'Material (English)'**
  String get sellerMaterialEn;

  /// No description provided for @sellerMaterialAr.
  ///
  /// In en, this message translates to:
  /// **'Material (Arabic)'**
  String get sellerMaterialAr;

  /// No description provided for @sellerCompositionEn.
  ///
  /// In en, this message translates to:
  /// **'Composition (English)'**
  String get sellerCompositionEn;

  /// No description provided for @sellerCompositionAr.
  ///
  /// In en, this message translates to:
  /// **'Composition (Arabic)'**
  String get sellerCompositionAr;

  /// No description provided for @sellerCareInstructionsEn.
  ///
  /// In en, this message translates to:
  /// **'Care Instructions (English)'**
  String get sellerCareInstructionsEn;

  /// No description provided for @sellerCareInstructionsAr.
  ///
  /// In en, this message translates to:
  /// **'Care Instructions (Arabic)'**
  String get sellerCareInstructionsAr;

  /// No description provided for @sellerClassificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get sellerClassificationTitle;

  /// No description provided for @sellerClassificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Department, category, and subcategory organize the listing.'**
  String get sellerClassificationSubtitle;

  /// No description provided for @sellerPricingInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Inventory'**
  String get sellerPricingInventoryTitle;

  /// No description provided for @sellerPricingInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set selling price, compare price, stock, and SKU.'**
  String get sellerPricingInventorySubtitle;

  /// No description provided for @sellerVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get sellerVariantsTitle;

  /// No description provided for @sellerVariantsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the available colors and sizes for this product.'**
  String get sellerVariantsSubtitle;

  /// No description provided for @sellerDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get sellerDepartment;

  /// No description provided for @sellerCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sellerCategory;

  /// No description provided for @sellerSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get sellerSubcategory;

  /// No description provided for @sellerPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sellerPrice;

  /// No description provided for @sellerOldPrice.
  ///
  /// In en, this message translates to:
  /// **'Old Price'**
  String get sellerOldPrice;

  /// No description provided for @sellerStockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get sellerStockQuantity;

  /// No description provided for @sellerSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sellerSku;

  /// No description provided for @sellerColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get sellerColors;

  /// No description provided for @sellerSizes.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get sellerSizes;

  /// No description provided for @sellerAddColors.
  ///
  /// In en, this message translates to:
  /// **'Add Colors'**
  String get sellerAddColors;

  /// No description provided for @sellerSelectColors.
  ///
  /// In en, this message translates to:
  /// **'Select Colors'**
  String get sellerSelectColors;

  /// No description provided for @sellerNoColorsSelected.
  ///
  /// In en, this message translates to:
  /// **'No colors selected yet'**
  String get sellerNoColorsSelected;

  /// No description provided for @sellerAddSizes.
  ///
  /// In en, this message translates to:
  /// **'Add Sizes'**
  String get sellerAddSizes;

  /// No description provided for @sellerSelectSizes.
  ///
  /// In en, this message translates to:
  /// **'Select Sizes'**
  String get sellerSelectSizes;

  /// No description provided for @sellerNoSizesSelected.
  ///
  /// In en, this message translates to:
  /// **'No sizes selected yet'**
  String get sellerNoSizesSelected;

  /// No description provided for @sellerProductImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get sellerProductImages;

  /// No description provided for @sellerProductImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add 1 to 9 product photos from your gallery. The first image is used as the cover.'**
  String get sellerProductImagesSubtitle;

  /// No description provided for @sellerProductImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the gallery tile to pick photos from your iPhone or Android device.'**
  String get sellerProductImagesHint;

  /// No description provided for @sellerProductOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Options'**
  String get sellerProductOptionsTitle;

  /// No description provided for @sellerProductOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how the product should behave in the store.'**
  String get sellerProductOptionsSubtitle;

  /// No description provided for @sellerReturnable.
  ///
  /// In en, this message translates to:
  /// **'Returnable'**
  String get sellerReturnable;

  /// No description provided for @sellerReturnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow customers to request returns for this product.'**
  String get sellerReturnableSubtitle;

  /// No description provided for @sellerSaveAsDraftOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The product will stay private as a draft.'**
  String get sellerSaveAsDraftOnSubtitle;

  /// No description provided for @sellerSaveAsDraftOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The product will be submitted for approval.'**
  String get sellerSaveAsDraftOffSubtitle;

  /// No description provided for @sellerSelectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select {label}'**
  String sellerSelectLabel(Object label);

  /// No description provided for @sellerChoosePreviousFieldFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose previous field first'**
  String get sellerChoosePreviousFieldFirst;

  /// No description provided for @sellerCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get sellerCover;

  /// No description provided for @sellerGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get sellerGallery;

  /// No description provided for @sellerSelectMultipleOptions.
  ///
  /// In en, this message translates to:
  /// **'Tap to select or remove multiple options.'**
  String get sellerSelectMultipleOptions;

  /// No description provided for @sellerImageMessageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 9 images only.'**
  String get sellerImageMessageLimitReached;

  /// No description provided for @sellerImageMessageRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart the app once to enable gallery access.'**
  String get sellerImageMessageRestart;

  /// No description provided for @sellerImageMessagePermission.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission is required to add product images.'**
  String get sellerImageMessagePermission;

  /// No description provided for @sellerImageMessageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the gallery right now.'**
  String get sellerImageMessageUnavailable;

  /// No description provided for @sellerImageMessageAdded.
  ///
  /// In en, this message translates to:
  /// **'Image added from gallery.'**
  String get sellerImageMessageAdded;

  /// No description provided for @sellerImageMessageAddedMultiple.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No images added} =1{1 image added from gallery.} other{{count} images added from gallery.}}'**
  String sellerImageMessageAddedMultiple(int count);

  /// No description provided for @sellerProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Products'**
  String get sellerProductsTitle;

  /// No description provided for @sellerProductsAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get sellerProductsAddTooltip;

  /// No description provided for @sellerProductsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products by name or SKU'**
  String get sellerProductsSearchHint;

  /// No description provided for @sellerProductsCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your catalog'**
  String get sellerProductsCatalogTitle;

  /// No description provided for @sellerProductsCatalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products ready to manage} =1{1 product ready to manage} other{{count} products ready to manage}}'**
  String sellerProductsCatalogSubtitle(int count);

  /// No description provided for @sellerProductsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog Manager'**
  String get sellerProductsHeroTitle;

  /// No description provided for @sellerProductsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See product images, monitor status, and manage the full catalog faster.'**
  String get sellerProductsHeroSubtitle;

  /// No description provided for @sellerProductsTotalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get sellerProductsTotalProducts;

  /// No description provided for @sellerProductsPendingApprovalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pending approval} =1{1 pending approval} other{{count} pending approval}}'**
  String sellerProductsPendingApprovalCount(int count);

  /// No description provided for @sellerProductsLowStockCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No low stock} =1{1 low stock} other{{count} low stock}}'**
  String sellerProductsLowStockCount(int count);

  /// No description provided for @sellerProductsVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get sellerProductsVisible;

  /// No description provided for @sellerProductsHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get sellerProductsHidden;

  /// No description provided for @sellerProductsStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get sellerProductsStock;

  /// No description provided for @sellerProductsViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get sellerProductsViews;

  /// No description provided for @sellerProductsSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sellerProductsSold;

  /// No description provided for @sellerProductsLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get sellerProductsLow;

  /// No description provided for @sellerProductsGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sellerProductsGood;

  /// No description provided for @sellerProductsTraffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get sellerProductsTraffic;

  /// No description provided for @sellerProductsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sellerProductsOrders;

  /// No description provided for @sellerProductsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get sellerProductsEmptyTitle;

  /// No description provided for @sellerProductsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter or add a new product to start building your seller catalog.'**
  String get sellerProductsEmptyMessage;

  /// No description provided for @sellerProductsActionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a quick action for this product.'**
  String get sellerProductsActionPrompt;

  /// No description provided for @sellerProductsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get sellerProductsDuplicate;

  /// No description provided for @sellerProductsAddFiveStock.
  ///
  /// In en, this message translates to:
  /// **'Add 5 to stock'**
  String get sellerProductsAddFiveStock;

  /// No description provided for @sellerProductsIncreasePrice.
  ///
  /// In en, this message translates to:
  /// **'Increase price by \$2'**
  String get sellerProductsIncreasePrice;

  /// No description provided for @sellerProductsDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get sellerProductsDeactivate;

  /// No description provided for @sellerProductsActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get sellerProductsActivate;

  /// No description provided for @validationProductTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Product title is required'**
  String get validationProductTitleRequired;

  /// No description provided for @validationArabicTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic title is required'**
  String get validationArabicTitleRequired;

  /// No description provided for @validationDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get validationDescriptionRequired;

  /// No description provided for @validationArabicDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic description is required'**
  String get validationArabicDescriptionRequired;

  /// No description provided for @validationDepartmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get validationDepartmentRequired;

  /// No description provided for @validationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validationCategoryRequired;

  /// No description provided for @validationSubcategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a subcategory'**
  String get validationSubcategoryRequired;

  /// No description provided for @validationColorRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one color'**
  String get validationColorRequired;

  /// No description provided for @validationSizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one size'**
  String get validationSizeRequired;

  /// No description provided for @validationImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product image'**
  String get validationImageRequired;

  /// No description provided for @validationMaximumImages.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 9 images only.'**
  String get validationMaximumImages;

  /// No description provided for @validationValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price greater than 0'**
  String get validationValidPrice;

  /// No description provided for @validationOldPriceMin.
  ///
  /// In en, this message translates to:
  /// **'Old price must be greater than or equal to price'**
  String get validationOldPriceMin;

  /// No description provided for @validationValidStock.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid stock quantity'**
  String get validationValidStock;

  /// No description provided for @validationSkuRequired.
  ///
  /// In en, this message translates to:
  /// **'SKU is required'**
  String get validationSkuRequired;

  /// No description provided for @validationMaterialRequired.
  ///
  /// In en, this message translates to:
  /// **'Material is required'**
  String get validationMaterialRequired;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPendingApproval;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get statusOutOfStock;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusInactiveProduct.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactiveProduct;

  /// No description provided for @statusSubmittedProduct.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmittedProduct;

  /// No description provided for @statusAutomatedReview.
  ///
  /// In en, this message translates to:
  /// **'Automated Review'**
  String get statusAutomatedReview;

  /// No description provided for @statusManualReview.
  ///
  /// In en, this message translates to:
  /// **'Manual Review'**
  String get statusManualReview;

  /// No description provided for @statusInformationRequired.
  ///
  /// In en, this message translates to:
  /// **'Information Required'**
  String get statusInformationRequired;

  /// No description provided for @statusRestrictedProduct.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get statusRestrictedProduct;

  /// No description provided for @statusSuspendedProduct.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspendedProduct;

  /// No description provided for @statusRecalledProduct.
  ///
  /// In en, this message translates to:
  /// **'Recalled'**
  String get statusRecalledProduct;

  /// No description provided for @statusArchivedProduct.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchivedProduct;

  /// No description provided for @statusDeletedProduct.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get statusDeletedProduct;

  /// No description provided for @adminSellersTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Sellers'**
  String get adminSellersTitle;

  /// No description provided for @adminSearchSellersHint.
  ///
  /// In en, this message translates to:
  /// **'Search sellers, stores, email, phone, or city'**
  String get adminSearchSellersHint;

  /// No description provided for @adminSellerListSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No seller accounts found} =1{1 seller account found} other{{count} seller accounts found}}'**
  String adminSellerListSummary(int count);

  /// No description provided for @adminNoSellersFound.
  ///
  /// In en, this message translates to:
  /// **'No seller accounts match the current search.'**
  String get adminNoSellersFound;

  /// No description provided for @adminTotalSellers.
  ///
  /// In en, this message translates to:
  /// **'Total sellers'**
  String get adminTotalSellers;

  /// No description provided for @adminTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total sales'**
  String get adminTotalSales;

  /// No description provided for @adminCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String adminCreatedOn(Object date);

  /// No description provided for @adminViewCredentials.
  ///
  /// In en, this message translates to:
  /// **'View Credentials'**
  String get adminViewCredentials;

  /// No description provided for @adminSuspendSeller.
  ///
  /// In en, this message translates to:
  /// **'Suspend Seller'**
  String get adminSuspendSeller;

  /// No description provided for @adminActivateSeller.
  ///
  /// In en, this message translates to:
  /// **'Activate Seller'**
  String get adminActivateSeller;

  /// No description provided for @adminOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Open Store'**
  String get adminOpenStore;

  /// No description provided for @adminStoreInactive.
  ///
  /// In en, this message translates to:
  /// **'Store inactive'**
  String get adminStoreInactive;

  /// No description provided for @adminSuspendReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Add a reason for suspension'**
  String get adminSuspendReasonHint;

  /// No description provided for @adminStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get adminStoreLabel;

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRoleLabel;

  /// No description provided for @adminRoleSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get adminRoleSeller;

  /// No description provided for @adminDemoPasswordNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing generated password is for local demo only. In production, send invitation/reset link by email and never display raw password.'**
  String get adminDemoPasswordNotice;

  /// No description provided for @adminSellerAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Seller Account Information'**
  String get adminSellerAccountInformation;

  /// No description provided for @adminEditSeller.
  ///
  /// In en, this message translates to:
  /// **'Edit Seller'**
  String get adminEditSeller;

  /// No description provided for @adminAddSeller.
  ///
  /// In en, this message translates to:
  /// **'Add Seller'**
  String get adminAddSeller;

  /// No description provided for @adminCreateSeller.
  ///
  /// In en, this message translates to:
  /// **'Create Seller'**
  String get adminCreateSeller;

  /// No description provided for @adminCreateSellerAndView.
  ///
  /// In en, this message translates to:
  /// **'Create Seller and View'**
  String get adminCreateSellerAndView;

  /// No description provided for @adminStoreInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get adminStoreInformation;

  /// No description provided for @adminStoreSettings.
  ///
  /// In en, this message translates to:
  /// **'Store Settings'**
  String get adminStoreSettings;

  /// No description provided for @adminStoreNameAr.
  ///
  /// In en, this message translates to:
  /// **'Store Name Arabic'**
  String get adminStoreNameAr;

  /// No description provided for @adminStoreNameEn.
  ///
  /// In en, this message translates to:
  /// **'Store Name English'**
  String get adminStoreNameEn;

  /// No description provided for @adminStorePhone.
  ///
  /// In en, this message translates to:
  /// **'Store Phone'**
  String get adminStorePhone;

  /// No description provided for @adminStoreAddressAr.
  ///
  /// In en, this message translates to:
  /// **'Store Address Arabic'**
  String get adminStoreAddressAr;

  /// No description provided for @adminStoreAddressEn.
  ///
  /// In en, this message translates to:
  /// **'Store Address English'**
  String get adminStoreAddressEn;

  /// No description provided for @adminCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get adminCity;

  /// No description provided for @adminCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get adminCountry;

  /// No description provided for @adminBusinessActivity.
  ///
  /// In en, this message translates to:
  /// **'Business Activity'**
  String get adminBusinessActivity;

  /// No description provided for @adminStoreDescriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Store Description Arabic'**
  String get adminStoreDescriptionAr;

  /// No description provided for @adminStoreDescriptionEn.
  ///
  /// In en, this message translates to:
  /// **'Store Description English'**
  String get adminStoreDescriptionEn;

  /// No description provided for @adminStoreActive.
  ///
  /// In en, this message translates to:
  /// **'Store Active'**
  String get adminStoreActive;

  /// No description provided for @adminVerifiedStore.
  ///
  /// In en, this message translates to:
  /// **'Verified Store'**
  String get adminVerifiedStore;

  /// No description provided for @adminFeaturedStore.
  ///
  /// In en, this message translates to:
  /// **'Featured Store'**
  String get adminFeaturedStore;

  /// No description provided for @adminVacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get adminVacationMode;

  /// No description provided for @adminCommissionPercentage.
  ///
  /// In en, this message translates to:
  /// **'Commission Percentage'**
  String get adminCommissionPercentage;

  /// No description provided for @adminAllowedCategories.
  ///
  /// In en, this message translates to:
  /// **'Allowed Categories'**
  String get adminAllowedCategories;

  /// No description provided for @adminSellerDetails.
  ///
  /// In en, this message translates to:
  /// **'Seller Details'**
  String get adminSellerDetails;

  /// No description provided for @adminPerformanceSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Performance Snapshot'**
  String get adminPerformanceSnapshot;

  /// No description provided for @adminAuditSummary.
  ///
  /// In en, this message translates to:
  /// **'Audit Summary'**
  String get adminAuditSummary;

  /// No description provided for @adminCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get adminCreatedAt;

  /// No description provided for @adminUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get adminUpdatedAt;

  /// No description provided for @adminSuspendReason.
  ///
  /// In en, this message translates to:
  /// **'Suspend Reason'**
  String get adminSuspendReason;

  /// No description provided for @adminStoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Store Details'**
  String get adminStoreDetails;

  /// No description provided for @adminStoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found.'**
  String get adminStoreNotFound;

  /// No description provided for @adminAllCategoriesAllowed.
  ///
  /// In en, this message translates to:
  /// **'All categories are allowed for this seller.'**
  String get adminAllCategoriesAllowed;

  /// No description provided for @adminAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get adminAccountStatus;

  /// No description provided for @adminStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatusActive;

  /// No description provided for @adminStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminStatusPending;

  /// No description provided for @adminStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminStatusSuspended;

  /// No description provided for @adminUnableToLoadSellers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sellers right now.'**
  String get adminUnableToLoadSellers;

  /// No description provided for @adminSellerPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage sellers.'**
  String get adminSellerPermissionDenied;

  /// No description provided for @adminSellerValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Please review the seller form and fix the highlighted fields.'**
  String get adminSellerValidationFailed;

  /// No description provided for @adminSellerCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create the seller account.'**
  String get adminSellerCreateFailed;

  /// No description provided for @adminSellerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Seller account not found.'**
  String get adminSellerNotFound;

  /// No description provided for @adminSellerUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the seller account.'**
  String get adminSellerUpdateFailed;

  /// No description provided for @adminSellerUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Seller account updated successfully.'**
  String get adminSellerUpdatedSuccessfully;

  /// No description provided for @adminSellerStatusChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update seller status right now.'**
  String get adminSellerStatusChangeFailed;

  /// No description provided for @adminSellerPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset the seller password.'**
  String get adminSellerPasswordResetFailed;

  /// No description provided for @adminSellerPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Seller password reset successfully.'**
  String get adminSellerPasswordResetSuccess;

  /// No description provided for @validationSellerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Seller name is required.'**
  String get validationSellerNameRequired;

  /// No description provided for @validationSellerNameMin.
  ///
  /// In en, this message translates to:
  /// **'Seller name must be at least 3 characters.'**
  String get validationSellerNameMin;

  /// No description provided for @validationSellerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Seller email is required.'**
  String get validationSellerEmailRequired;

  /// No description provided for @validationSellerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid seller email address.'**
  String get validationSellerEmailInvalid;

  /// No description provided for @validationSellerPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Seller phone must contain at least 7 digits.'**
  String get validationSellerPhoneRequired;

  /// No description provided for @validationSellerPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get validationSellerPasswordMin;

  /// No description provided for @validationSellerConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the password.'**
  String get validationSellerConfirmPasswordRequired;

  /// No description provided for @validationStoreNameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic store name is required.'**
  String get validationStoreNameArRequired;

  /// No description provided for @validationStoreNameEnRequired.
  ///
  /// In en, this message translates to:
  /// **'English store name is required.'**
  String get validationStoreNameEnRequired;

  /// No description provided for @validationStorePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Store phone must contain at least 7 digits.'**
  String get validationStorePhoneRequired;

  /// No description provided for @validationStoreAddressArRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic store address is required.'**
  String get validationStoreAddressArRequired;

  /// No description provided for @validationStoreAddressEnRequired.
  ///
  /// In en, this message translates to:
  /// **'English store address is required.'**
  String get validationStoreAddressEnRequired;

  /// No description provided for @validationCityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required.'**
  String get validationCityRequired;

  /// No description provided for @validationCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required.'**
  String get validationCountryRequired;

  /// No description provided for @validationEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get validationEmailAlreadyExists;

  /// No description provided for @validationSelectBusinessActivity.
  ///
  /// In en, this message translates to:
  /// **'Select a business activity.'**
  String get validationSelectBusinessActivity;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationInvalidCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission must be between 0 and 100.'**
  String get validationInvalidCommission;

  /// No description provided for @authErrorSellerSuspended.
  ///
  /// In en, this message translates to:
  /// **'This seller account is suspended.'**
  String get authErrorSellerSuspended;

  /// No description provided for @authErrorSellerPending.
  ///
  /// In en, this message translates to:
  /// **'This seller account is pending activation.'**
  String get authErrorSellerPending;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @businessClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get businessClothing;

  /// No description provided for @businessShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get businessShoes;

  /// No description provided for @businessBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get businessBags;

  /// No description provided for @businessBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get businessBeauty;

  /// No description provided for @businessMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get businessMakeup;

  /// No description provided for @businessElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get businessElectronics;

  /// No description provided for @businessHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get businessHome;

  /// No description provided for @businessAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get businessAccessories;

  /// No description provided for @businessJewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get businessJewelry;

  /// No description provided for @businessKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get businessKids;

  /// No description provided for @businessSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get businessSports;

  /// No description provided for @businessPerfumes.
  ///
  /// In en, this message translates to:
  /// **'Perfumes'**
  String get businessPerfumes;

  /// No description provided for @businessAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get businessAppliances;

  /// No description provided for @businessMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed Store'**
  String get businessMixed;

  /// No description provided for @adminSellerCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Seller Created Successfully'**
  String get adminSellerCreatedSuccessfully;

  /// No description provided for @adminSellerFullName.
  ///
  /// In en, this message translates to:
  /// **'Seller Full Name'**
  String get adminSellerFullName;

  /// No description provided for @adminSellerEmail.
  ///
  /// In en, this message translates to:
  /// **'Seller Email'**
  String get adminSellerEmail;

  /// No description provided for @adminSellerPhone.
  ///
  /// In en, this message translates to:
  /// **'Seller Phone'**
  String get adminSellerPhone;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPassword;

  /// No description provided for @adminConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get adminConfirmPassword;

  /// No description provided for @adminGeneratePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate Password'**
  String get adminGeneratePassword;

  /// No description provided for @adminResetSellerPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Seller Password'**
  String get adminResetSellerPassword;

  /// No description provided for @adminSellerSuspended.
  ///
  /// In en, this message translates to:
  /// **'Seller account suspended.'**
  String get adminSellerSuspended;

  /// No description provided for @adminSellerActivated.
  ///
  /// In en, this message translates to:
  /// **'Seller account activated.'**
  String get adminSellerActivated;

  /// No description provided for @adminCredentialsCopied.
  ///
  /// In en, this message translates to:
  /// **'Credentials copied.'**
  String get adminCredentialsCopied;

  /// No description provided for @adminCopyCredentials.
  ///
  /// In en, this message translates to:
  /// **'Copy Credentials'**
  String get adminCopyCredentials;

  /// No description provided for @adminOpenSellerDetails.
  ///
  /// In en, this message translates to:
  /// **'Open Seller Details'**
  String get adminOpenSellerDetails;

  /// No description provided for @categoryJustForYou.
  ///
  /// In en, this message translates to:
  /// **'Just for You'**
  String get categoryJustForYou;

  /// No description provided for @categoryPicksForYou.
  ///
  /// In en, this message translates to:
  /// **'Picks for You'**
  String get categoryPicksForYou;

  /// No description provided for @categoryYouMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You May Also Like'**
  String get categoryYouMayAlsoLike;

  /// No description provided for @categoryNewIn.
  ///
  /// In en, this message translates to:
  /// **'New In'**
  String get categoryNewIn;

  /// No description provided for @categorySale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get categorySale;

  /// No description provided for @categoryWomenClothing.
  ///
  /// In en, this message translates to:
  /// **'Women Clothing'**
  String get categoryWomenClothing;

  /// No description provided for @categoryBeachwear.
  ///
  /// In en, this message translates to:
  /// **'Beachwear'**
  String get categoryBeachwear;

  /// No description provided for @categoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get categoryShoes;

  /// No description provided for @categoryCurve.
  ///
  /// In en, this message translates to:
  /// **'Curve'**
  String get categoryCurve;

  /// No description provided for @categoryMenClothing.
  ///
  /// In en, this message translates to:
  /// **'Men Clothing'**
  String get categoryMenClothing;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// No description provided for @categoryJewelryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Jewelry & Accessories'**
  String get categoryJewelryAccessories;

  /// No description provided for @categoryHomeLiving.
  ///
  /// In en, this message translates to:
  /// **'Home & Living'**
  String get categoryHomeLiving;

  /// No description provided for @categoryUnderwearSleepwear.
  ///
  /// In en, this message translates to:
  /// **'Underwear & Sleepwear'**
  String get categoryUnderwearSleepwear;

  /// No description provided for @categoryBabyMaternity.
  ///
  /// In en, this message translates to:
  /// **'Baby & Maternity'**
  String get categoryBabyMaternity;

  /// No description provided for @categoryBeautyHealth.
  ///
  /// In en, this message translates to:
  /// **'Beauty & Health'**
  String get categoryBeautyHealth;

  /// No description provided for @categorySportsOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Sports & Outdoors'**
  String get categorySportsOutdoors;

  /// No description provided for @categoryBagsLuggage.
  ///
  /// In en, this message translates to:
  /// **'Bags & Luggage'**
  String get categoryBagsLuggage;

  /// No description provided for @categoryCellPhonesAccessories.
  ///
  /// In en, this message translates to:
  /// **'Cell Phones & Accessories'**
  String get categoryCellPhonesAccessories;

  /// No description provided for @categoryToysGames.
  ///
  /// In en, this message translates to:
  /// **'Toys & Games'**
  String get categoryToysGames;

  /// No description provided for @categoryHomeTextiles.
  ///
  /// In en, this message translates to:
  /// **'Home Textiles'**
  String get categoryHomeTextiles;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryToolsHomeImprovement.
  ///
  /// In en, this message translates to:
  /// **'Tools & Home Improvement'**
  String get categoryToolsHomeImprovement;

  /// No description provided for @categoryOfficeSchoolSupplies.
  ///
  /// In en, this message translates to:
  /// **'Office & School Supplies'**
  String get categoryOfficeSchoolSupplies;

  /// No description provided for @categoryAutomotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get categoryAutomotive;

  /// No description provided for @categoryPetSupplies.
  ///
  /// In en, this message translates to:
  /// **'Pet Supplies'**
  String get categoryPetSupplies;

  /// No description provided for @categoryAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get categoryAppliances;

  /// No description provided for @categoryViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get categoryViewAll;

  /// No description provided for @categoryNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get categoryNoProducts;

  /// No description provided for @categoryNoSubcategories.
  ///
  /// In en, this message translates to:
  /// **'No subcategories'**
  String get categoryNoSubcategories;

  /// No description provided for @categorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search shoes, bags, beauty...'**
  String get categorySearchHint;

  /// No description provided for @categoryOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get categoryOpenMenu;

  /// No description provided for @categoryCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get categoryCloseMenu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
