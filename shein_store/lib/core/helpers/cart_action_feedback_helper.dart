import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../extensions/localization_extension.dart';

class CartActionFeedbackHelper {
  const CartActionFeedbackHelper._();

  static void show(BuildContext context, CartActionResult result) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messageFor(context, result))));
  }

  static String messageFor(BuildContext context, CartActionResult result) {
    if (result.isSuccess) {
      return context.tr('Added to cart', 'تمت الإضافة إلى السلة');
    }

    switch (result.errorCode) {
      case 'customer_required':
        return context.tr(
          'Please sign in with a customer account first',
          'يرجى تسجيل الدخول بحساب عميل أولا',
        );
      case 'product_not_found':
      case 'product_unavailable':
        return context.tr(
          'This product is no longer available',
          'هذا المنتج لم يعد متاحا',
        );
      case 'store_unavailable':
        return context.tr(
          'This store is not available right now',
          'هذا المتجر غير متاح حاليا',
        );
      case 'color_unavailable':
        return context.tr(
          'Please choose an available color',
          'يرجى اختيار لون متاح',
        );
      case 'size_unavailable':
        return context.tr(
          'Please choose an available size',
          'يرجى اختيار مقاس متاح',
        );
      case 'variant_unavailable':
        return context.tr(
          'This option is not available',
          'هذا الخيار غير متاح',
        );
      case 'out_of_stock':
        return context.tr(
          'This product is out of stock',
          'نفدت كمية هذا المنتج',
        );
      case 'insufficient_stock':
        final stock = result.availableStock ?? 0;
        return context.tr(
          'Only $stock pieces are available',
          'المتاح فقط $stock قطع',
        );
      case 'quantity_minimum':
        return context.tr(
          'Quantity must be at least 1',
          'يجب أن تكون الكمية 1 على الأقل',
        );
      default:
        return context.tr(
          'Could not add this product right now',
          'تعذرت إضافة هذا المنتج الآن',
        );
    }
  }
}
