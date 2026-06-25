import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/order_model.dart';
import '../../widgets/common/app_header.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOrderController>(
      builder: (context, controller, _) {
        final colors = context.appColors;
        final allOrders = controller.orders;
        final visibleSections = controller.selectedStatus == 'All'
            ? SellerOrderController.statusSections
                  .where((status) => status != 'All')
                  .where(
                    (status) => controller.ordersByStatus(status).isNotEmpty,
                  )
                  .toList()
            : [controller.selectedStatus];

        return Scaffold(
          appBar: AppHeader(title: context.l10n.sellerOrdersTitle),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _SellerOrdersHero(controller: controller),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: context.l10n.sellerOrdersSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: colors.border),
                    ),
                  ),
                  onChanged: controller.setQuery,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: SellerOrderController.statusSections
                      .map((status) => _OrderStatusChip(label: status))
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              _SectionRow(
                title: controller.selectedStatus == 'All'
                    ? context.l10n.sellerOrdersOrderLanes
                    : context.l10n.sellerOrdersLaneTitle(
                        localizedOrderStatus(
                          context,
                          controller.selectedStatus,
                        ),
                      ),
                subtitle: controller.selectedStatus == 'All'
                    ? context.l10n.sellerOrdersOrganizedByStatus(
                        allOrders.length,
                      )
                    : context.l10n.sellerOrdersLaneSubtitle(
                        controller.filteredOrders.length,
                      ),
              ),
              const SizedBox(height: 12),
              if (allOrders.isEmpty)
                _EmptyOrdersState(
                  title: context.l10n.sellerOrdersNoOrdersTitle,
                  message: context.l10n.sellerOrdersNoOrdersMessage,
                )
              else if (controller.selectedStatus != 'All' &&
                  controller.filteredOrders.isEmpty)
                _EmptyOrdersState(
                  title: context.l10n.sellerOrdersNothingInLaneTitle,
                  message: context.l10n.sellerOrdersNothingInLaneMessage,
                )
              else
                ...visibleSections.expand((status) {
                  final orders = controller.selectedStatus == 'All'
                      ? controller.ordersByStatus(status)
                      : controller.filteredOrders;
                  if (orders.isEmpty) {
                    return <Widget>[];
                  }
                  return [
                    _OrdersLaneHeader(status: status, count: orders.length),
                    const SizedBox(height: 10),
                    ...orders.map((order) => _SellerOrderCard(order: order)),
                    const SizedBox(height: 16),
                  ];
                }),
            ],
          ),
        );
      },
    );
  }
}

class _SellerOrdersHero extends StatelessWidget {
  const _SellerOrdersHero({required this.controller});

  final SellerOrderController controller;

  @override
  Widget build(BuildContext context) {
    final newCount = controller.countForStatus('New');
    final shippedCount = controller.countForStatus('Shipped');
    final returnedCount = controller.countForStatus('Returned');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF16202B), Color(0xFF364055), Color(0xFF704E42)]
              : const [Color(0xFF171717), Color(0xFF4A556A), Color(0xFFA36A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sellerOrdersHeroTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.sellerOrdersHeroSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: context.l10n.sellerOrdersTotal,
                  value: '${controller.orders.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: context.l10n.statusNew,
                  value: '$newCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(
                icon: Icons.autorenew_rounded,
                text:
                    '${controller.countForStatus('Processing')} ${context.l10n.statusProcessing}',
              ),
              _HeroPill(
                icon: Icons.local_shipping_outlined,
                text: '$shippedCount ${context.l10n.statusShipped}',
              ),
              _HeroPill(
                icon: Icons.assignment_return_outlined,
                text: '$returnedCount ${context.l10n.statusReturned}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SellerOrderController>();
    final colors = context.appColors;
    final selected = controller.selectedStatus == label;
    final count = controller.countForStatus(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          context.l10n.commonCountWithLabel(
            localizedOrderStatus(context, label),
            count,
          ),
        ),
        selected: selected,
        labelStyle: TextStyle(
          color: selected ? colors.surface : colors.primaryText,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colors.border),
        backgroundColor: colors.card,
        selectedColor: colors.primaryText,
        onSelected: (_) => controller.setStatusFilter(label),
      ),
    );
  }
}

class _OrdersLaneHeader extends StatelessWidget {
  const _OrdersLaneHeader({required this.status, required this.count});

  final String status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = _statusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon(status), color: tint, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              localizedOrderStatus(context, status),
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            context.l10n.sellerOrdersCountLabel(count),
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  const _SellerOrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SellerOrderController>();
    final colors = context.appColors;
    final firstItem = order.items.first;
    final product = firstItem.product;
    final imagePath = product.localImagePaths.isNotEmpty
        ? product.localImagePaths.first
        : product.imageUrl;
    final displayStatus = controller.displayStatus(order);
    final primaryAction = controller.primaryActionLabel(order);
    final nextStatus = controller.nextStatusFor(order);
    final sellerNet = order.total - order.platformCommission;
    final moreItemsCount = order.items.length - 1;
    final localizedTitle = product.resolvedTitle(
      Localizations.localeOf(context),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                  width: 88,
                  height: 104,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            localizedTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatCurrency(context, sellerNet),
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: localizedOrderStatus(context, displayStatus),
                          background: _statusColor(
                            context,
                            displayStatus,
                          ).withValues(alpha: 0.12),
                          foreground: _statusColor(context, displayStatus),
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
                      child: Text(
                        order.id,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.customerName.substring(0, 2)}***  •  ${formatShortDate(context, order.createdAt)}',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${firstItem.selectedColor} / ${firstItem.selectedSize}  •  Qty ${firstItem.quantity}'
                      '${moreItemsCount > 0 ? '  •  +$moreItemsCount more item${moreItemsCount > 1 ? 's' : ''}' : ''}',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 13,
                        height: 1.3,
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
                child: _MiniOrderStat(
                  label: context.l10n.sellerOrdersShipping,
                  value: localizedOrderStatus(context, order.shippingStatus),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniOrderStat(
                  label: context.l10n.sellerOrdersCommission,
                  value: formatCurrency(context, order.platformCommission),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniOrderStat(
                  label: context.l10n.sellerOrdersItems,
                  value: '${order.items.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.sellerOrderDetails,
                    arguments: order.id,
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(context.l10n.commonDetails),
                ),
              ),
              if (primaryAction != null && nextStatus != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmSellerOrderTransition(
                      context,
                      controller,
                      order,
                      displayStatus,
                      nextStatus,
                    ),
                    icon: Icon(_statusIcon(nextStatus), size: 18),
                    label: Text(
                      _localizedPrimaryAction(context, primaryAction),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
  controller.updateOrderStatus(order.id, nextStatus);
  if (context.mounted) {
    AppActionFeedback.success(
      context,
      context.tr('Order status updated', 'تم تحديث حالة الطلب'),
    );
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

class _MiniOrderStat extends StatelessWidget {
  const _MiniOrderStat({required this.label, required this.value});

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colors.inactiveIcon,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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

IconData _statusIcon(String status) {
  switch (status) {
    case 'New':
      return Icons.fiber_new_rounded;
    case 'Processing':
      return Icons.autorenew_rounded;
    case 'Ready to Ship':
      return Icons.inventory_2_outlined;
    case 'Shipped':
      return Icons.local_shipping_outlined;
    case 'Delivered':
      return Icons.check_circle_outline;
    case 'Cancelled':
      return Icons.cancel_outlined;
    case 'Returned':
      return Icons.assignment_return_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}
