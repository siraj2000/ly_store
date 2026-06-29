import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/profile_menu_item.dart';
import '../../widgets/profile/order_status_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppHeader(
        title: context.l10n.navProfile,
        actions: const [_ProfileHeaderActions()],
      ),
      body: authController.isGuest
          ? const _GuestProfileView()
          : const _SignedInProfileView(),
    );
  }
}

class _ProfileHeaderActions extends StatelessWidget {
  const _ProfileHeaderActions();

  @override
  Widget build(BuildContext context) {
    final languageController = context.watch<LanguageController>();
    final themeController = context.watch<ThemeController>();
    final colors = context.appColors;
    final isDarkMode = themeController.isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          tooltip: languageController.isArabic
              ? context.l10n.profileSwitchToEnglish
              : context.l10n.profileSwitchToArabic,
          onTap: () async {
            if (languageController.isArabic) {
              await languageController.setEnglish();
            } else {
              await languageController.setArabic();
            }
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('Language changed', 'تم تغيير اللغة')),
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.translate_rounded, color: colors.primaryText),
              PositionedDirectional(
                end: -8,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryText,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.isArabic ? 'AR' : 'EN',
                    style: TextStyle(
                      color: colors.surface,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          tooltip: isDarkMode
              ? context.l10n.profileSwitchToLightMode
              : context.l10n.profileSwitchToDarkMode,
          onTap: themeController.toggleDarkMode,
          child: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: colors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        const _GuestHeaderCard(),
        const SizedBox(height: 14),
        _ProfileSectionLabel(context.l10n.profileAssets),
        const SizedBox(height: 10),
        _AssetRow(
          items: [
            _AssetItem(
              label: context.l10n.profileCoupons,
              icon: Icons.local_offer_outlined,
              locked: true,
            ),
            _AssetItem(
              label: context.l10n.profilePoints,
              icon: Icons.stars_outlined,
              locked: true,
            ),
            _AssetItem(
              label: context.l10n.profileWallet,
              icon: Icons.account_balance_wallet_outlined,
              locked: true,
            ),
            _AssetItem(
              label: context.l10n.profileGiftCard,
              icon: Icons.card_giftcard_outlined,
              locked: true,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ProfileSectionLabel(context.l10n.profileMyOrders),
        const SizedBox(height: 10),
        Row(
          children: [
            _GuestOrderStatusCard(
              label: context.l10n.profileOrderUnpaid,
              icon: Icons.payment_outlined,
            ),
            _GuestOrderStatusCard(
              label: context.l10n.statusProcessing,
              icon: Icons.inventory_2_outlined,
            ),
            _GuestOrderStatusCard(
              label: context.l10n.statusShipped,
              icon: Icons.local_shipping_outlined,
            ),
            _GuestOrderStatusCard(
              label: context.l10n.profileOrderReview,
              icon: Icons.rate_review_outlined,
            ),
            _GuestOrderStatusCard(
              label: context.l10n.profileOrderReturns,
              icon: Icons.assignment_return_outlined,
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...[
          (
            Icons.favorite_border,
            context.l10n.profileWishlist,
            AppRoutes.wishlist,
          ),
          (
            Icons.history,
            context.l10n.profileRecentlyViewed,
            AppRoutes.recentlyViewed,
          ),
          (
            Icons.location_on_outlined,
            context.l10n.profileAddressBook,
            AppRoutes.addressBook,
          ),
          (
            Icons.credit_card_outlined,
            context.l10n.profilePaymentOptions,
            AppRoutes.paymentOptions,
          ),
          (
            Icons.support_agent_outlined,
            context.l10n.profileCustomerService,
            AppRoutes.helpCenter,
          ),
          (
            Icons.settings_outlined,
            context.l10n.settingsTitle,
            AppRoutes.settings,
          ),
        ].map(
          (item) => ProfileMenuItem(
            icon: item.$1,
            title: item.$2,
            onTap: () => AuthRequiredHelper.guard(
              context,
              onAuthenticated: () => Navigator.pushNamed(context, item.$3),
            ),
            trailing: const _MenuLockTrailing(),
          ),
        ),
      ],
    );
  }
}

class _SignedInProfileView extends StatelessWidget {
  const _SignedInProfileView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, profileController, _) {
        final user = profileController.user!;
        final walletController = context.watch<WalletController>();

        return ListView(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            12,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            _SignedInHeaderCard(
              name: user.name,
              email: user.email,
              points: user.points,
            ),
            const SizedBox(height: 14),
            _AssetRow(
              items: [
                _AssetItem(
                  label: context.l10n.profileCoupons,
                  value: '${user.coupons.length}',
                  icon: Icons.local_offer_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.coupons),
                ),
                _AssetItem(
                  label: context.l10n.profilePoints,
                  value: '${user.points}',
                  icon: Icons.stars_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.points),
                ),
                _AssetItem(
                  label: context.l10n.profileWallet,
                  value: formatCurrency(user.walletBalance),
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
                ),
                _AssetItem(
                  label: context.l10n.profileGiftCard,
                  value: '${walletController.redeemedGiftCardCount}',
                  icon: Icons.card_giftcard_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.giftCard),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ProfileSectionLabel(context.l10n.profileMyOrders),
            const SizedBox(height: 10),
            Row(
              children: [
                OrderStatusCard(
                  label: context.l10n.profileOrderUnpaid,
                  icon: Icons.payment_outlined,
                  onTap: () => _openOrders(context, 'Unpaid'),
                ),
                OrderStatusCard(
                  label: context.l10n.statusProcessing,
                  icon: Icons.inventory_2_outlined,
                  onTap: () => _openOrders(context, 'Processing'),
                ),
                OrderStatusCard(
                  label: context.l10n.statusShipped,
                  icon: Icons.local_shipping_outlined,
                  onTap: () => _openOrders(context, 'Shipped'),
                ),
                OrderStatusCard(
                  label: context.l10n.profileOrderReview,
                  icon: Icons.rate_review_outlined,
                  onTap: () => _openOrders(context, 'Review'),
                ),
                OrderStatusCard(
                  label: context.l10n.profileOrderReturns,
                  icon: Icons.assignment_return_outlined,
                  onTap: () => _openOrders(context, 'Returns'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...[
              (
                Icons.favorite_border,
                context.l10n.profileWishlist,
                AppRoutes.wishlist,
              ),
              (
                Icons.history,
                context.l10n.profileRecentlyViewed,
                AppRoutes.recentlyViewed,
              ),
              (
                Icons.location_on_outlined,
                context.l10n.profileAddressBook,
                AppRoutes.addressBook,
              ),
              (
                Icons.credit_card_outlined,
                context.l10n.profilePaymentOptions,
                AppRoutes.paymentOptions,
              ),
              (
                Icons.support_agent_outlined,
                context.l10n.profileCustomerService,
                AppRoutes.helpCenter,
              ),
              (
                Icons.settings_outlined,
                context.l10n.settingsTitle,
                AppRoutes.settings,
              ),
            ].map(
              (item) => ProfileMenuItem(
                icon: item.$1,
                title: item.$2,
                onTap: () => Navigator.pushNamed(context, item.$3),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openOrders(BuildContext context, String status) {
    Navigator.pushNamed(
      context,
      AppRoutes.orders,
      arguments: {'status': status},
    );
  }
}

class _GuestHeaderCard extends StatelessWidget {
  const _GuestHeaderCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, size: 28, color: colors.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileWelcomeTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.profileWelcomeSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: context.l10n.onboardingSignIn,
                  filled: true,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileActionButton(
                  label: context.l10n.profileCreateAccount,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignedInHeaderCard extends StatelessWidget {
  const _SignedInHeaderCard({
    required this.name,
    required this.email,
    required this.points,
  });

  final String name;
  final String email;
  final int points;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, size: 28, color: colors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.secondaryText),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.l10n.profilePointsAvailable(points),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
            style: TextButton.styleFrom(
              foregroundColor: colors.primaryText,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(context.l10n.commonEdit),
          ),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.items});

  final List<_AssetItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _AssetCard(item: item),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item});

  final _AssetItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 18, color: colors.icon),
              ),
              const SizedBox(height: 8),
              if (item.value != null)
                Text(
                  item.value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
              if (item.value != null) const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
          if (item.locked)
            const Positioned(top: -2, right: -2, child: _LockBadge()),
        ],
      ),
    );

    if (item.onTap == null) return child;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: child,
    );
  }
}

class _GuestOrderStatusCard extends StatelessWidget {
  const _GuestOrderStatusCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: colors.icon),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
              const Positioned(top: -2, right: -2, child: _LockBadge()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 44,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryText,
                foregroundColor: context.isDarkMode
                    ? colors.background
                    : colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryText,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(label),
            ),
    );
  }
}

class _ProfileSectionLabel extends StatelessWidget {
  const _ProfileSectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: colors.primaryText,
      ),
    );
  }
}

class _MenuLockTrailing extends StatelessWidget {
  const _MenuLockTrailing();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _LockBadge(),
        const SizedBox(width: 6),
        Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          color: context.appColors.inactiveIcon,
        ),
      ],
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: colors.primaryText,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(
        Icons.lock_outline,
        size: 10,
        color: context.isDarkMode ? colors.background : colors.surface,
      ),
    );
  }
}

class _AssetItem {
  const _AssetItem({
    required this.label,
    required this.icon,
    this.value,
    this.onTap,
    this.locked = false,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool locked;
}
