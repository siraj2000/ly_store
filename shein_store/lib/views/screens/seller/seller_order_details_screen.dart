import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/helpers/app_copy_helper.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/order_model.dart';
import '../../widgets/common/app_header.dart';

class SellerOrderDetailsScreen extends StatelessWidget {
  const SellerOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SellerOrderController>();
    final matches = controller.orders.where((order) => order.id == orderId);
    final order = matches.isEmpty ? null : matches.first;
    final sellerOrder = controller.sellerOrderById(orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppHeader(title: context.l10n.sellerOrderDetailsTitle),
        body: const AppEmptyState(
          title: 'Order missing',
          message: 'This seller order could not be found.',
        ),
      );
    }

    final firstItem = order.items.first;
    final imagePath = firstItem.product.localImagePaths.isNotEmpty
        ? firstItem.product.localImagePaths.first
        : firstItem.product.imageUrl;
    final displayStatus = controller.displayStatus(order);
    final primaryAction = controller.primaryActionLabel(order);
    final nextStatus = controller.nextStatusFor(order);
    final colors = context.appColors;
    final localizedTitle = firstItem.product.resolvedTitle(
      Localizations.localeOf(context),
    );

    return Scaffold(
      appBar: AppHeader(title: context.l10n.sellerOrderDetailsTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        width: 92,
                        height: 108,
                        child: ProductImage(
                          imageUrl: imagePath,
                          imageUrls: imagePath == null ? const [] : [imagePath],
                          radius: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedTitle,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Badge(
                                label: localizedOrderStatus(
                                  context,
                                  displayStatus,
                                ),
                                background: _statusColor(
                                  context,
                                  displayStatus,
                                ).withValues(alpha: 0.12),
                                foreground: _statusColor(
                                  context,
                                  displayStatus,
                                ),
                              ),
                              _Badge(
                                label: localizedOrderStatus(
                                  context,
                                  order.paymentStatus,
                                ),
                                background: colors.info.withValues(alpha: 0.12),
                                foreground: colors.info,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    order.id,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                AppCopyIconButton(
                                  text: order.id,
                                  feedback: context.l10n.copiedOrderNumber,
                                  tooltip: context.l10n.copy,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${firstItem.selectedColor} / ${firstItem.selectedSize}  •  Qty ${firstItem.quantity}',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 13,
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
                      child: _InfoTile(
                        label: context.l10n.sellerOrdersSellerNet,
                        value: formatCurrency(
                          context,
                          order.total - order.platformCommission,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoTile(
                        label: context.l10n.sellerOrdersCommission,
                        value: formatCurrency(
                          context,
                          order.platformCommission,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoTile(
                        label: context.l10n.sellerOrdersShipping,
                        value: localizedOrderStatus(
                          context,
                          order.shippingStatus,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.sellerOrdersOrderSummary,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: context.l10n.sellerOrdersCustomer,
                  value: order.address.fullName.isNotEmpty
                      ? order.address.fullName
                      : order.customerName,
                ),
                _SummaryRow(
                  label: context.tr('Phone', 'الهاتف'),
                  value: order.address.phone,
                  copyFeedback: context.l10n.copiedPhoneNumber,
                ),
                _SummaryRow(
                  label: context.l10n.sellerOrdersOrderDate,
                  value: formatShortDate(context, order.createdAt),
                ),
                _SummaryRow(
                  label: context.l10n.sellerOrdersEstimatedDelivery,
                  value: formatShortDate(context, order.estimatedDelivery),
                ),
                _SummaryRow(
                  label: context.l10n.sellerOrdersAddress,
                  value:
                      '${order.address.streetAddress}, ${order.address.region}, ${order.address.city}, ${order.address.country}',
                  copyFeedback: context.l10n.copiedAddress,
                ),
                _SummaryRow(
                  label: context.l10n.sellerOrdersItems,
                  value: '${order.items.length}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (sellerOrder != null &&
              (sellerOrder.trackingNumber.isNotEmpty ||
                  sellerOrder.cancellationReason.isNotEmpty))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sellerOrder.cancellationReason.isNotEmpty
                        ? context.tr('Cancellation details', 'تفاصيل الإلغاء')
                        : context.tr('Shipping tracking', 'تتبع الشحن'),
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sellerOrder.cancellationReason.isNotEmpty) ...[
                    _SummaryRow(
                      label: context.tr('Cancellation Reason', 'سبب الإلغاء'),
                      value: sellerOrder.cancellationReason,
                    ),
                    if (sellerOrder.cancelledAt != null)
                      _SummaryRow(
                        label: context.tr('Cancelled at', 'وقت الإلغاء'),
                        value: formatShortDate(
                          context,
                          sellerOrder.cancelledAt!,
                        ),
                      ),
                  ] else ...[
                    _SummaryRow(
                      label: context.tr('Carrier', 'شركة الشحن'),
                      value: sellerOrder.carrierName,
                    ),
                    _SummaryRow(
                      label: context.tr('Tracking Number', 'رقم التتبع'),
                      value: sellerOrder.trackingNumber,
                      copyFeedback: context.l10n.copiedTrackingNumber,
                    ),
                    if (sellerOrder.shippedAt != null)
                      _SummaryRow(
                        label: context.tr('Shipped at', 'وقت الشحن'),
                        value: formatShortDate(context, sellerOrder.shippedAt!),
                      ),
                    if (sellerOrder.shippingNotes.isNotEmpty)
                      _SummaryRow(
                        label: context.tr('Notes', 'ملاحظات'),
                        value: sellerOrder.shippingNotes,
                      ),
                  ],
                ],
              ),
            ),
          if (sellerOrder != null &&
              (sellerOrder.trackingNumber.isNotEmpty ||
                  sellerOrder.cancellationReason.isNotEmpty))
            const SizedBox(height: 16),
          if (primaryAction != null && nextStatus != null)
            FilledButton.icon(
              onPressed: () => _confirmSellerOrderTransition(
                context,
                controller,
                order,
                displayStatus,
                nextStatus,
              ),
              icon: Icon(_statusIcon(nextStatus)),
              label: Text(_localizedPrimaryAction(context, primaryAction)),
            ),
          if (controller.canCancel(order)) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  _showCancelOrderDialog(context, controller, order.id),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(context.tr('Cancel Order', 'إلغاء الطلب')),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _confirmSellerOrderTransition(
  BuildContext context,
  SellerOrderController controller,
  OrderModel order,
  String currentStatus,
  String nextStatus,
) async {
  if (nextStatus == 'Shipped') {
    await _showShippingDialog(context, controller, order.id);
    return;
  }
  final confirmed = await AppConfirmationDialog.show(
    context,
    title: context.tr('Update order status?', 'تحديث حالة الطلب؟'),
    message: _sellerTransitionMessage(context, nextStatus),
    cancelLabel: context.tr('Cancel', 'إلغاء'),
    confirmLabel: localizedOrderStatus(context, nextStatus),
    icon: _statusIcon(nextStatus),
    tone: nextStatus == 'Delivered'
        ? AppConfirmationTone.warning
        : AppConfirmationTone.neutral,
    details: AppConfirmationDetails(
      children: [
        AppConfirmationDetailRow(
          label: context.tr('Order', 'الطلب'),
          value: order.id,
        ),
        AppConfirmationDetailRow(
          label: context.tr('Current status', 'الحالة الحالية'),
          value: localizedOrderStatus(context, currentStatus),
        ),
        AppConfirmationDetailRow(
          label: context.tr('New status', 'الحالة الجديدة'),
          value: localizedOrderStatus(context, nextStatus),
          emphasized: true,
        ),
        AppConfirmationDetailRow(
          label: context.tr('Items', 'المنتجات'),
          value: '${order.items.length}',
        ),
        AppConfirmationDetailRow(
          label: context.tr('Customer city', 'مدينة العميل'),
          value: order.address.city,
        ),
      ],
    ),
  );
  if (!confirmed) {
    return;
  }
  final updated = await controller.updateOrderStatus(order.id, nextStatus);
  if (context.mounted) {
    if (updated) {
      AppActionFeedback.success(
        context,
        context.tr('Order status updated', 'تم تحديث حالة الطلب'),
      );
    } else {
      AppActionFeedback.error(
        context,
        context.tr('Unable to update order', 'تعذر تحديث الطلب'),
      );
    }
  }
}

Future<void> _showShippingDialog(
  BuildContext context,
  SellerOrderController controller,
  String orderId,
) async {
  final carrierController = TextEditingController();
  final trackingController = TextEditingController();
  final notesController = TextEditingController();
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('Confirm Shipment', 'تأكيد الشحن')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: carrierController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.tr('Carrier', 'شركة الشحن'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trackingController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.tr('Tracking Number', 'رقم التتبع'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.tr('Shipping notes', 'ملاحظات الشحن'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.tr('Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.tr('Confirm Shipment', 'تأكيد الشحن')),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final updated = await controller.markOrderShipped(
      orderId: orderId,
      carrierName: carrierController.text,
      trackingNumber: trackingController.text,
      shippingNotes: notesController.text,
    );
    if (!context.mounted) return;
    if (updated) {
      AppActionFeedback.success(
        context,
        context.tr('Shipment confirmed', 'تم تأكيد الشحن'),
      );
    } else {
      AppActionFeedback.error(
        context,
        context.tr(
          'Carrier and tracking number are required',
          'شركة الشحن ورقم التتبع مطلوبان',
        ),
      );
    }
  } finally {
    carrierController.dispose();
    trackingController.dispose();
    notesController.dispose();
  }
}

Future<void> _showCancelOrderDialog(
  BuildContext context,
  SellerOrderController controller,
  String orderId,
) async {
  final reasonController = TextEditingController();
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('Cancel Order', 'إلغاء الطلب')),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: context.tr('Cancellation Reason', 'سبب الإلغاء'),
              helperText: context.tr(
                'The customer will be notified of the cancellation reason',
                'سيتم إشعار العميل بسبب الإلغاء',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.tr('Keep Order', 'إبقاء الطلب')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.tr('Cancel Order', 'إلغاء الطلب')),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final cancelled = await controller.cancelOrder(
      orderId: orderId,
      reason: reasonController.text,
    );
    if (!context.mounted) return;
    if (cancelled) {
      AppActionFeedback.success(
        context,
        context.tr('Order cancelled', 'تم إلغاء الطلب'),
      );
    } else {
      AppActionFeedback.error(
        context,
        context.tr('Cancellation reason is required', 'سبب الإلغاء مطلوب'),
      );
    }
  } finally {
    reasonController.dispose();
  }
}

String _sellerTransitionMessage(BuildContext context, String nextStatus) {
  switch (nextStatus) {
    case 'Processing':
      return context.tr(
        'Confirm that preparation has started for this customer order.',
        'أكد بدء تجهيز طلب العميل.',
      );
    case 'Ready to Ship':
      return context.tr(
        'Confirm that the package is ready for carrier handover.',
        'أكد أن الطرد جاهز للتسليم لشركة الشحن.',
      );
    case 'Shipped':
      return context.tr(
        'Confirm that the package has been handed to the carrier. Tracking fields can be connected later.',
        'أكد تسليم الطرد لشركة الشحن. يمكن ربط بيانات التتبع لاحقاً.',
      );
    case 'Delivered':
      return context.tr(
        'Confirm delivery only after actual delivery. This may affect finance settlement and customer return timing.',
        'أكد التسليم فقط بعد وصول الطلب فعلياً. قد يؤثر ذلك في تسوية الأرباح ومدة الإرجاع.',
      );
    default:
      return context.tr(
        'Confirm this status change before updating the customer order.',
        'أكد تغيير الحالة قبل تحديث طلب العميل.',
      );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.copyFeedback,
  });

  final String label;
  final String value;
  final String? copyFeedback;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: TextStyle(
                color: colors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (copyFeedback != null)
            AppCopyIconButton(
              text: value,
              feedback: copyFeedback,
              tooltip: context.l10n.copy,
              iconSize: 18,
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  final colors = context.appColors;
  switch (status) {
    case 'New':
      return colors.accent;
    case 'Processing':
      return colors.warning;
    case 'Ready to Ship':
      return colors.info;
    case 'Shipped':
      return colors.info;
    case 'Delivered':
      return colors.success;
    case 'Cancelled':
      return colors.mutedText;
    case 'Returned':
      return colors.discount;
    default:
      return colors.primaryText;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'Processing':
      return Icons.autorenew_rounded;
    case 'Ready to Ship':
      return Icons.inventory_2_outlined;
    case 'Shipped':
      return Icons.local_shipping_outlined;
    case 'Delivered':
      return Icons.check_circle_outline;
    default:
      return Icons.receipt_long_outlined;
  }
}

String _localizedPrimaryAction(BuildContext context, String action) {
  switch (action) {
    case 'Accept Order':
      return context.l10n.sellerOrdersAcceptOrder;
    case 'Prepare Order':
      return context.l10n.sellerOrdersPrepareOrder;
    case 'Mark Shipped':
      return context.l10n.sellerOrdersMarkShipped;
    case 'Mark Delivered':
      return context.l10n.sellerOrdersMarkDelivered;
    default:
      return action;
  }
}
