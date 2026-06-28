import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../constants/app_sizes.dart';
import '../extensions/localization_extension.dart';
import 'animated_page_wrapper.dart';
import 'app_button.dart';

class AppBottomSheet {
  static Future<void> show(BuildContext context, {required Widget child}) {
    final colors = context.appColors;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        padding: EdgeInsets.only(
          left: AppSizes.lg,
          right: AppSizes.lg,
          top: AppSizes.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
        ),
        child: AnimatedPageWrapper(
          beginOffset: const Offset(0, 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showAuthRequired(BuildContext context) {
    return show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Sign in to continue', 'سجل الدخول للمتابعة'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr(
              'Create an account or sign in to save items, use coupons, place orders, and track delivery.',
              'أنشئ حساباً أو سجّل الدخول لحفظ المنتجات واستخدام الكوبونات وإتمام الطلبات وتتبع الشحن.',
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          AppButton(
            text: context.tr('Sign In', 'تسجيل الدخول'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
          const SizedBox(height: AppSizes.md),
          AppButton.secondary(
            text: context.tr('Create Account', 'إنشاء حساب'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.register);
            },
          ),
          const SizedBox(height: AppSizes.md),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Continue Browsing', 'متابعة التصفح')),
          ),
        ],
      ),
    );
  }

  static Future<String?> showSortOptions(
    BuildContext context, {
    required String selected,
  }) {
    final options = [
      context.tr('Recommended', 'موصى به'),
      context.tr('Newest', 'الأحدث'),
      context.tr('Price low to high', 'السعر من الأقل إلى الأعلى'),
      context.tr('Price high to low', 'السعر من الأعلى إلى الأقل'),
      context.tr('Top rated', 'الأعلى تقييماً'),
      context.tr('Most popular', 'الأكثر شعبية'),
      context.tr('Biggest discount', 'أكبر خصم'),
    ];
    return showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppSizes.lg),
        children: options
            .map(
              (option) => ListTile(
                title: Text(option),
                trailing: selected == option
                    ? Icon(Icons.check_circle, color: context.appColors.accent)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            )
            .toList(),
      ),
    );
  }

  static Future<Map<String, dynamic>?> showFilterOptions(BuildContext context) {
    final selections = <String, dynamic>{
      'saleOnly': false,
      'newArrivals': false,
    };
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Filter', 'تصفية'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.md),
              CheckboxListTile(
                value: selections['saleOnly'] as bool,
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Sale only', 'التخفيضات فقط')),
                onChanged: (value) =>
                    setState(() => selections['saleOnly'] = value ?? false),
              ),
              CheckboxListTile(
                value: selections['newArrivals'] as bool,
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('New arrivals', 'وصل حديثاً')),
                onChanged: (value) =>
                    setState(() => selections['newArrivals'] = value ?? false),
              ),
              const SizedBox(height: AppSizes.md),
              AppButton(
                text: context.tr('Apply Filters', 'تطبيق الفلاتر'),
                onPressed: () => Navigator.pop(context, selections),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>?> showVariantSelector(
    BuildContext context, {
    required List<String> colors,
    required List<String> sizes,
    int maxQuantity = 99,
  }) {
    String? selectedColor;
    String? selectedSize;
    int quantity = 1;
    final effectiveMaxQuantity = maxQuantity < 1 ? 0 : maxQuantity;
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Choose options', 'اختر الخيارات'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.md),
              Text(context.tr('Color', 'اللون')),
              Wrap(
                spacing: 8,
                children: colors
                    .map(
                      (color) => ChoiceChip(
                        label: Text(color),
                        selected: selectedColor == color,
                        onSelected: (_) =>
                            setState(() => selectedColor = color),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSizes.md),
              Text(context.tr('Size', 'المقاس')),
              Wrap(
                spacing: 8,
                children: sizes
                    .map(
                      (size) => ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        onSelected: (_) => setState(() => selectedSize = size),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Text(context.tr('Quantity', 'الكمية')),
                  const Spacer(),
                  IconButton(
                    onPressed: quantity == 1
                        ? null
                        : () => setState(() => quantity--),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$quantity'),
                  IconButton(
                    onPressed: quantity >= effectiveMaxQuantity
                        ? null
                        : () => setState(() => quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              AppButton(
                text: context.tr('Confirm', 'تأكيد'),
                onPressed:
                    effectiveMaxQuantity < 1 ||
                        (colors.isNotEmpty && selectedColor == null) ||
                        (sizes.isNotEmpty && selectedSize == null)
                    ? null
                    : () => Navigator.pop(context, {
                        'color': selectedColor ?? '',
                        'size': selectedSize ?? '',
                        'quantity': quantity,
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showSizeGuide(BuildContext context) {
    return show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Size Guide', 'دليل المقاسات'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          const Text('XS: Bust 32  Waist 24  Hips 34'),
          const Text('S: Bust 34  Waist 26  Hips 36'),
          const Text('M: Bust 36  Waist 28  Hips 38'),
          const Text('L: Bust 38  Waist 30  Hips 40'),
          const SizedBox(height: AppSizes.lg),
          AppButton(
            text: context.tr('Close', 'إغلاق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
