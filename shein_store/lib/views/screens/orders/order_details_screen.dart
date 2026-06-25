import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../widgets/common/app_header.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderController>().orders;
    final orderMatches = orders.where((item) => item.id == orderId);
    final order = orderMatches.isEmpty ? null : orderMatches.first;
    if (order == null) {
      return Scaffold(
        appBar: AppHeader(title: context.tr('Order Details', 'تفاصيل الطلب')),
        body: AppEmptyState(
          title: context.tr('Order not found', 'الطلب غير موجود'),
          message: context.tr(
            'The requested order could not be loaded.',
            'تعذر تحميل الطلب المطلوب.',
          ),
        ),
      );
    }
    final colors = context.appColors;
    return Scaffold(
      appBar: AppHeader(title: context.tr('Order Details', 'تفاصيل الطلب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Panel(
            title: context.tr('Order timeline', 'تسلسل الطلب'),
            child: Column(
              children: [
                _TimelineTile(
                  title: context.tr('Order placed', 'تم إنشاء الطلب'),
                  subtitle: context.tr(
                    'Payment pending or confirmed',
                    'الدفع قيد الانتظار أو تم تأكيده',
                  ),
                ),
                _TimelineTile(
                  title: context.tr('Packed', 'تم التجهيز'),
                  subtitle: context.tr(
                    'Warehouse preparing items',
                    'المخزن يجهز المنتجات',
                  ),
                ),
                _TimelineTile(
                  title: context.tr('Shipped', 'تم الشحن'),
                  subtitle: context.tr(
                    'Carrier picked up package',
                    'شركة الشحن استلمت الطرد',
                  ),
                ),
              ],
            ),
          ),
          _Panel(
            title: context.tr('Shipping address', 'عنوان الشحن'),
            child: Text(
              '${order.address.fullName}\n${order.address.streetAddress}, ${order.address.city}',
              style: TextStyle(height: 1.4, color: colors.secondaryText),
            ),
          ),
          _Panel(
            title: context.tr('Payment summary', 'ملخص الدفع'),
            child: Text(
              '${order.paymentMethod.brand} ${order.paymentMethod.maskedNumber}',
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
          _Panel(
            title: context.tr('Items', 'المنتجات'),
            child: Column(
              children: order.items
                  .map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ProductImage(
                            imageUrl: item.product.imageUrl,
                            imageUrls: item.product.imageUrls,
                            width: 62,
                            height: 78,
                            radius: 12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ).copyWith(color: colors.primaryText),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.selectedColor} / ${item.selectedSize} x${item.quantity}',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _Panel(
            title: context.tr('Invoice', 'الفاتورة'),
            child: Text(
              context.tr(
                'Invoice tools can be connected to a real backend later.',
                'يمكن ربط أدوات الفاتورة بخادم حقيقي لاحقاً.',
              ),
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
          FilledButton(
            onPressed: () {},
            child: Text(context.tr('Customer Service', 'خدمة العملاء')),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: Text(context.tr('Return / Refund', 'إرجاع / استرداد')),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.primaryText,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 34, color: colors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
