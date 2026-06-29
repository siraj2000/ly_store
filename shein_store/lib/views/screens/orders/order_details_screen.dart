import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/order_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/helpers/app_copy_helper.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/order_item_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/reviews/product_review_form_sheet.dart';

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
            title: context.tr('Order number', 'رقم الطلب'),
            child: Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      order.id,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                AppCopyIconButton(
                  text: order.id,
                  feedback: context.l10n.copiedOrderNumber,
                  tooltip: context.l10n.copy,
                ),
              ],
            ),
          ),
          _Panel(
            title: context.tr('Order timeline', 'تسلسل الطلب'),
            child: Column(
              children: [
                _TimelineTile(
                  title: context.tr('Order placed', 'تم إنشاء الطلب'),
                  subtitle: '${order.status} • ${order.paymentStatus}',
                ),
                _TimelineTile(
                  title: context.tr('Packed', 'تم التجهيز'),
                  subtitle: order.shippingStatus,
                ),
                _TimelineTile(
                  title: context.tr('Shipped', 'تم الشحن'),
                  subtitle: context.tr(
                    'Estimated delivery: ${order.estimatedDelivery.month}/${order.estimatedDelivery.day}/${order.estimatedDelivery.year}',
                    'التسليم المتوقع: ${order.estimatedDelivery.year}/${order.estimatedDelivery.month}/${order.estimatedDelivery.day}',
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
                    (item) => _OrderItemTile(
                      item: item,
                      orderReviewable: _isReviewableOrderForProductActions(
                        status: order.status,
                        paymentStatus: order.paymentStatus,
                        shippingStatus: order.shippingStatus,
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
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.helpCenter,
              arguments: order.id,
            ),
            child: Text(context.tr('Customer Service', 'خدمة العملاء')),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: order.status == 'Delivered'
                ? () => _requestReturn(context, order.id)
                : () => AppActionFeedback.info(
                    context,
                    context.tr(
                      'Returns are available after delivery.',
                      'الإرجاع متاح بعد التسليم.',
                    ),
                  ),
            child: Text(context.tr('Return / Refund', 'إرجاع / استرداد')),
          ),
        ],
      ),
    );
  }

  Future<void> _requestReturn(BuildContext context, String orderId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Return / Refund', 'إرجاع / استرداد')),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.tr('Reason', 'السبب'),
            hintText: context.tr(
              'Tell us why you want to return this order.',
              'اكتب سبب طلب الإرجاع.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('Submit', 'إرسال')),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (confirmed != true || !context.mounted) {
      return;
    }
    context.read<OrderController>().requestReturn(orderId);
    AppActionFeedback.success(
      context,
      context.tr('Return request submitted', 'تم إرسال طلب الإرجاع'),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item, required this.orderReviewable});

  final OrderItemModel item;
  final bool orderReviewable;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final productController = context.watch<ProductController>();
    final existingReview = productController.currentCustomerReviewForProduct(
      item.product.id,
    );
    final eligibility = productController.reviewEligibilityForProduct(
      item.product.id,
    );
    final showReviewAction =
        (orderReviewable && eligibility.canReview) || existingReview != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: item.product.id,
            ),
            borderRadius: BorderRadius.circular(14),
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
                        item.product.resolvedTitle(
                          Localizations.localeOf(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(width: 8),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (showReviewAction) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ProductReviewFormSheet.show(
                  context: context,
                  product: item.product,
                  existingReview: existingReview,
                  onSubmit: ({required rating, required comment}) =>
                      productController.saveProductReview(
                        productId: item.product.id,
                        rating: rating,
                        comment: comment,
                        existingReview: existingReview,
                      ),
                ),
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(
                  existingReview == null
                      ? context.tr('Review Product', 'قيّم المنتج')
                      : context.tr('Edit Review', 'تعديل التقييم'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

bool _isReviewableOrderForProductActions({
  required String status,
  required String paymentStatus,
  required String shippingStatus,
}) {
  final blocked = {
    'cancelled',
    'failed',
    'refunded',
    'returned',
    'returns',
    'return requested',
  };
  final active = {
    'paid',
    'processing',
    'readytoship',
    'ready to ship',
    'shipped',
    'delivered',
    'completed',
    'confirmedreceived',
    'confirmed received',
    'review',
  };
  final paid = {'paid', 'completed', 'captured'};
  final normalizedStatus = status.trim().toLowerCase();
  final normalizedPayment = paymentStatus.trim().toLowerCase();
  final normalizedShipping = shippingStatus.trim().toLowerCase();
  if (blocked.contains(normalizedStatus) ||
      blocked.contains(normalizedShipping)) {
    return false;
  }
  return paid.contains(normalizedPayment) ||
      active.contains(normalizedStatus) ||
      active.contains(normalizedShipping);
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
