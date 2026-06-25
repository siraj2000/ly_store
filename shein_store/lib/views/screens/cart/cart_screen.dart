import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/coupon_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/cart/cart_item_row.dart';
import '../../widgets/common/app_header.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.isTabRoot = false});

  final bool isTabRoot;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    return Scaffold(
      appBar: isTabRoot
          ? null
          : AppHeader(title: context.tr('Bag', 'Ø§Ù„Ø³Ù„Ø©')),
      body: authController.isGuest
          ? AppEmptyState(
              title: context.tr(
                'Sign in to view your bag and checkout',
                'Ø³Ø¬Ù„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ù„Ø¹Ø±Ø¶ Ø³Ù„ØªÙƒ ÙˆØ¥ØªÙ…Ø§Ù… Ø§Ù„Ø¯ÙØ¹',
              ),
              message: context.tr(
                'Browse freely as a guest, then sign in when you want to save or buy.',
                'ØªØµÙØ­ ÙƒØ¶ÙŠÙ Ø¨Ø­Ø±ÙŠØ©ØŒ Ø«Ù… Ø³Ø¬Ù‘Ù„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ø¹Ù†Ø¯Ù…Ø§ ØªØ±ÙŠØ¯ Ø§Ù„Ø­ÙØ¸ Ø£Ùˆ Ø§Ù„Ø´Ø±Ø§Ø¡.',
              ),
              action: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: context.tr('Sign In', 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„'),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    isExpanded: false,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.main),
                    child: Text(
                      context.tr(
                        'Continue Shopping',
                        'Ù…ØªØ§Ø¨Ø¹Ø© Ø§Ù„ØªØ³ÙˆÙ‚',
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const _LoggedInCartBody(),
    );
  }
}

class _LoggedInCartBody extends StatelessWidget {
  const _LoggedInCartBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Consumer3<CartController, CouponController, WishlistController>(
      builder: (context, cartController, couponController, wishlistController, _) {
        if (cartController.items.isEmpty) {
          return AppEmptyState(
            title: context.tr('Your bag is empty', 'Ø³Ù„ØªÙƒ ÙØ§Ø±ØºØ©'),
            message: context.tr(
              'Add a few pieces to unlock checkout, coupons, and order tracking.',
              'Ø£Ø¶Ù Ø¨Ø¹Ø¶ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª Ù„ØªÙØ¹ÙŠÙ„ Ø§Ù„Ø¯ÙØ¹ ÙˆØ§Ù„ÙƒÙˆØ¨ÙˆÙ†Ø§Øª ÙˆØªØªØ¨Ø¹ Ø§Ù„Ø·Ù„Ø¨Ø§Øª.',
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 18,
                        color: colors.icon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr(
                            'Free shipping unlocks automatically on qualifying orders.',
                            'ÙŠØªÙ… ØªÙØ¹ÙŠÙ„ Ø§Ù„Ø´Ø­Ù† Ø§Ù„Ù…Ø¬Ø§Ù†ÙŠ ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹ Ù„Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…Ø¤Ù‡Ù„Ø©.',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _freeShippingLabel(context, cartController),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.discount,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...cartController.items.map(
              (item) => CartItemRow(
                item: item,
                onSelect: (selected) =>
                    cartController.selectItem(item.id, selected),
                onDelete: () => _confirmDelete(context, () {
                  cartController.removeFromCart(item.id);
                }),
                onIncrease: () =>
                    cartController.updateQuantity(item.id, item.quantity + 1),
                onDecrease: () =>
                    cartController.updateQuantity(item.id, item.quantity - 1),
                onSaveForLater: () {
                  wishlistController.toggleWishlist(item.product);
                  cartController.removeFromCart(item.id);
                },
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _Panel(
              title: context.tr('Promotions', 'Ø§Ù„Ø¹Ø±ÙˆØ¶'),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: context.tr(
                        'Coupon input',
                        'Ø§Ø®ØªÙŠØ§Ø± ÙƒÙˆØ¨ÙˆÙ†',
                      ),
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    onTap: () => _showCouponPicker(
                      context,
                      couponController,
                      cartController,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    value: cartController.usePoints,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('Use points', 'Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ù†Ù‚Ø§Ø·'),
                    ),
                    onChanged: cartController.setUsePoints,
                  ),
                  SwitchListTile(
                    value: cartController.useWallet,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr(
                        'Use wallet balance',
                        'Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø±ØµÙŠØ¯ Ø§Ù„Ù…Ø­ÙØ¸Ø©',
                      ),
                    ),
                    onChanged: cartController.setUseWallet,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: context.tr(
                        'Gift card code',
                        'Ø±Ù…Ø² Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ù‡Ø¯ÙŠØ©',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              title: context.tr('Summary', 'Ø§Ù„Ù…Ù„Ø®Øµ'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: context.tr(
                      'Items subtotal',
                      'Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª',
                    ),
                    value: cartController.calculateSubtotal(),
                  ),
                  _SummaryRow(
                    label: context.tr('Discount', 'Ø§Ù„Ø®ØµÙ…'),
                    value: -cartController.calculateDiscount(),
                  ),
                  _SummaryRow(
                    label: context.tr(
                      'Shipping estimate',
                      'ØªÙƒÙ„ÙØ© Ø§Ù„Ø´Ø­Ù† Ø§Ù„Ù…ØªÙˆÙ‚Ø¹Ø©',
                    ),
                    value: cartController.calculateShipping(),
                  ),
                  _SummaryRow(
                    label: context.tr(
                      'Tax/customs placeholder',
                      'Ø§Ù„Ø¶Ø±Ø§Ø¦Ø¨/Ø§Ù„Ø¬Ù…Ø§Ø±Ùƒ Ø§Ù„ØªØ¬Ø±ÙŠØ¨ÙŠØ©',
                    ),
                    value: 0,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: context.tr('Total', 'Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ'),
                    value: cartController.calculateTotal(),
                    bold: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => cartController.selectAll(true),
                        child: Text(
                          context.tr('Select All', 'ØªØ­Ø¯ÙŠØ¯ Ø§Ù„ÙƒÙ„'),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.main),
                        child: Text(
                          context.tr(
                            'Continue Shopping',
                            'Ù…ØªØ§Ø¨Ø¹Ø© Ø§Ù„ØªØ³ÙˆÙ‚',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: context.tr('Checkout', 'Ø¥ØªÙ…Ø§Ù… Ø§Ù„Ø¯ÙØ¹'),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.checkout),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _freeShippingLabel(
    BuildContext context,
    CartController cartController,
  ) {
    final subtotal = cartController.calculateSubtotal();
    if (subtotal >= 49) {
      return context.tr(
        'You unlocked free shipping',
        'ØªÙ… ØªÙØ¹ÙŠÙ„ Ø§Ù„Ø´Ø­Ù† Ø§Ù„Ù…Ø¬Ø§Ù†ÙŠ',
      );
    }
    final remaining = 49 - subtotal;
    return context.tr(
      'Spend ${formatCurrency(context, remaining)} more for free shipping',
      'Ø£Ø¶Ù ${formatCurrency(context, remaining)} Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ø´Ø­Ù† Ø§Ù„Ù…Ø¬Ø§Ù†ÙŠ',
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: context.tr('Remove item?', 'حذف المنتج؟'),
      message: context.tr(
        'This product will be removed from your bag. You can add it again later from the product page.',
        'سيتم حذف هذا المنتج من السلة. يمكنك إضافته مرة أخرى لاحقاً من صفحة المنتج.',
      ),
      cancelLabel: context.tr('Keep Item', 'إبقاء المنتج'),
      confirmLabel: context.tr('Remove', 'حذف'),
      icon: Icons.delete_outline_rounded,
      tone: AppConfirmationTone.destructive,
    );
    if (confirmed) {
      onConfirm();
    }
  }

  void _showCouponPicker(
    BuildContext context,
    CouponController couponController,
    CartController cartController,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: couponController.allCoupons
            .map(
              (coupon) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.appColors.border),
                ),
                child: ListTile(
                  title: Text(coupon.title),
                  subtitle: Text(coupon.code),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    final applied = cartController.applyCoupon(coupon);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          applied
                              ? context.tr(
                                  'Coupon applied',
                                  'ØªÙ… ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„ÙƒÙˆØ¨ÙˆÙ†',
                                )
                              : context.tr(
                                  'Coupon minimum not met',
                                  'Ù„Ù… ÙŠØªÙ… Ø§Ø³ØªÙŠÙØ§Ø¡ Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ø¯Ù†Ù‰ Ù„Ù„ÙƒÙˆØ¨ÙˆÙ†',
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ).copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 15 : 13,
      color: bold ? colors.primaryText : colors.secondaryText,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(formatCurrency(context, value), style: style),
        ],
      ),
    );
  }
}
