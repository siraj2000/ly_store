import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../widgets/common/app_header.dart';

class SellerOrderDetailsScreen extends StatelessWidget {
  const SellerOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SellerOrderController>();
    final matches = controller.orders.where((order) => order.id == orderId);
    final order = matches.isEmpty ? null : matches.first;
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
                            child: Text(
                              order.id,
                              style: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w700,
                              ),
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
                  value: '${order.customerName.substring(0, 2)}***',
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
                  value: '${order.address.city}, ${order.address.region}',
                ),
                _SummaryRow(
                  label: context.l10n.sellerOrdersItems,
                  value: '${order.items.length}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (primaryAction != null && nextStatus != null)
            FilledButton.icon(
              onPressed: () =>
                  controller.updateOrderStatus(order.id, nextStatus),
              icon: Icon(_statusIcon(nextStatus)),
              label: Text(_localizedPrimaryAction(context, primaryAction)),
            ),
        ],
      ),
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
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

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
