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
      appBar: isTabRoot ? null : AppHeader(title: context.tr('Bag', 'السلة')),
      body: authController.isGuest
          ? AppEmptyState(
              title: context.tr(
                'Sign in to view your bag and checkout',
                'سجل الدخول لعرض سلتك وإتمام الدفع',
              ),
              message: context.tr(
                'Browse freely as a guest, then sign in when you want to save or buy.',
                'تصفح كضيف بحرية، ثم سجّل الدخول عندما تريد الحفظ أو الشراء.',
              ),
              action: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: context.tr('Sign In', 'تسجيل الدخول'),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.login),
                    isExpanded: false,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.main),
                    child: Text(
                      context.tr('Continue Shopping', 'متابعة التسوق'),
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
            title: context.tr('Your bag is empty', 'سلتك فارغة'),
            message: context.tr(
              'Add a few pieces to unlock checkout, coupons, and order tracking.',
              'أضف بعض المنتجات لتفعيل الدفع والكوبونات وتتبع الطلبات.',
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
                            'يتم تفعيل الشحن المجاني تلقائياً للطلبات المؤهلة.',
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
              title: context.tr('Promotions', 'العروض'),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Coupon input', 'اختيار كوبون'),
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
                    title: Text(context.tr('Use points', 'استخدام النقاط')),
                    onChanged: cartController.setUsePoints,
                  ),
                  SwitchListTile(
                    value: cartController.useWallet,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr('Use wallet balance', 'استخدام رصيد المحفظة'),
                    ),
                    onChanged: cartController.setUseWallet,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: context.tr(
                        'Gift card code',
                        'رمز بطاقة الهدية',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              title: context.tr('Summary', 'الملخص'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: context.tr('Items subtotal', 'إجمالي المنتجات'),
                    value: cartController.calculateSubtotal(),
                  ),
                  _SummaryRow(
                    label: context.tr('Discount', 'الخصم'),
                    value: -cartController.calculateDiscount(),
                  ),
                  _SummaryRow(
                    label: context.tr(
                      'Shipping estimate',
                      'تكلفة الشحن المتوقعة',
                    ),
                    value: cartController.calculateShipping(),
                  ),
                  _SummaryRow(
                    label: context.tr(
                      'Tax/customs placeholder',
                      'الضرائب/الجمارك التجريبية',
                    ),
                    value: 0,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: context.tr('Total', 'الإجمالي'),
                    value: cartController.calculateTotal(),
                    bold: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => cartController.selectAll(true),
                        child: Text(context.tr('Select All', 'تحديد الكل')),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.main),
                        child: Text(
                          context.tr('Continue Shopping', 'متابعة التسوق'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: context.tr('Checkout', 'إتمام الدفع'),
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
      return context.tr('You unlocked free shipping', 'تم تفعيل الشحن المجاني');
    }
    final remaining = 49 - subtotal;
    return context.tr(
      'Spend ${formatCurrency(context, remaining)} more for free shipping',
      'أضف ${formatCurrency(context, remaining)} للحصول على الشحن المجاني',
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete item', 'حذف المنتج')),
        content: Text(
          context.tr(
            'Remove this item from your bag?',
            'هل تريد إزالة هذا المنتج من السلة؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(context.tr('Delete', 'حذف')),
          ),
        ],
      ),
    );
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
                              ? context.tr('Coupon applied', 'تم تطبيق الكوبون')
                              : context.tr(
                                  'Coupon minimum not met',
                                  'لم يتم استيفاء الحد الأدنى للكوبون',
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
