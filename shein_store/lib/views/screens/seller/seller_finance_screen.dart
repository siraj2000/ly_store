import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_finance_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/seller_order_model.dart';
import '../../widgets/common/app_header.dart';

class SellerFinanceScreen extends StatelessWidget {
  const SellerFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerFinanceController>(
      builder: (context, controller, _) {
        final colors = context.appColors;

        return Scaffold(
          appBar: const AppHeader(title: 'Seller Finance'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _FinanceHero(controller: controller),
              const SizedBox(height: 18),
              const _FinanceSectionHeader(
                title: 'Finance snapshot',
                subtitle: 'The numbers that matter for payouts and margins.',
              ),
              const SizedBox(height: 12),
              _FinanceMetricGrid(controller: controller),
              const SizedBox(height: 18),
              const _FinanceSectionHeader(
                title: 'Payout flow',
                subtitle: 'See what is ready now and what is still processing.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniFinanceCard(
                      label: 'This week',
                      value: _currency(controller.thisWeekNet),
                      caption: 'Net revenue',
                      icon: Icons.calendar_view_week_outlined,
                      tint: colors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniFinanceCard(
                      label: 'This month',
                      value: _currency(controller.thisMonthNet),
                      caption: 'Net revenue',
                      icon: Icons.calendar_month_outlined,
                      tint: colors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniFinanceCard(
                      label: 'Delivered',
                      value: '${controller.deliveredOrdersCount}',
                      caption: 'Ready orders',
                      icon: Icons.check_circle_outline,
                      tint: colors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniFinanceCard(
                      label: 'Pending',
                      value: '${controller.pendingOrdersCount}',
                      caption: 'In progress',
                      icon: Icons.schedule_outlined,
                      tint: colors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle(
                      title: 'Payout method',
                      subtitle:
                          'Ready for bank integration when payouts are connected.',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Icon(
                              Icons.account_balance_outlined,
                              color: colors.primaryText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payout backend not connected',
                                  style: TextStyle(
                                    color: colors.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Connect an API payout provider before withdrawals go live.',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'API-ready',
                              style: TextStyle(
                                color: colors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _FinanceSectionHeader(
                title: 'Recent transactions',
                subtitle:
                    'Per-order payout view with commission and payment status.',
              ),
              const SizedBox(height: 12),
              if (controller.sellerOrders.isEmpty)
                const _EmptyFinanceState()
              else
                ...controller.sellerOrders
                    .take(6)
                    .map((order) => _TransactionCard(order: order)),
            ],
          ),
        );
      },
    );
  }
}

class _FinanceHero extends StatelessWidget {
  const _FinanceHero({required this.controller});

  final SellerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.payoutReadiness;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF131D2A), Color(0xFF23405A), Color(0xFF1D6E69)]
              : const [Color(0xFF121212), Color(0xFF244960), Color(0xFF2E8976)],
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
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payout Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track net earnings, balances, and payout readiness in one place.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
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
          Text(
            _currency(controller.availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available to withdraw now',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroFinancePill(
                  label: 'Pending balance',
                  value: _currency(controller.pendingBalance),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroFinancePill(
                  label: 'Commission',
                  value: _currency(controller.totalCommission),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Withdrawal readiness',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: controller.availableBalance <= 0
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Withdrawal requests require backend payout integration.',
                              ),
                            ),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF131D2A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Request Withdrawal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceMetricGrid extends StatelessWidget {
  const _FinanceMetricGrid({required this.controller});

  final SellerFinanceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = [
      _FinanceMetricItem(
        label: 'Total earnings',
        value: _currency(controller.totalEarnings),
        caption: 'Net seller revenue',
        icon: Icons.savings_outlined,
        tint: colors.success,
      ),
      _FinanceMetricItem(
        label: 'Avg. net order',
        value: _currency(controller.averageOrderNet),
        caption: 'Per seller order',
        icon: Icons.show_chart_outlined,
        tint: colors.info,
      ),
      _FinanceMetricItem(
        label: 'Paid orders',
        value: '${controller.paidOrdersCount}',
        caption: 'Payment confirmed',
        icon: Icons.payments_outlined,
        tint: colors.warning,
      ),
      _FinanceMetricItem(
        label: 'Platform fee',
        value: _currency(controller.totalCommission),
        caption: 'Commission total',
        icon: Icons.receipt_long_outlined,
        tint: colors.accent,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) => _MetricFinanceCard(item: items[index]),
    );
  }
}

class _MetricFinanceCard extends StatelessWidget {
  const _MetricFinanceCard({required this.item});

  final _FinanceMetricItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.tint),
          ),
          const Spacer(),
          Text(
            item.label,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MiniFinanceCard extends StatelessWidget {
  const _MiniFinanceCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(color: colors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.order});

  final SellerOrderModel order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final net = order.sellerNetAmount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showTransactionDetails(context, order),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${order.customerName}  •  ${_formatDate(order.createdAt)}',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currency(net),
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: colors.secondaryText,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      label: order.status,
                      background: _statusColor(
                        context,
                        order.status,
                      ).withValues(alpha: 0.12),
                      foreground: _statusColor(context, order.status),
                    ),
                    _StatusBadge(
                      label: order.paymentStatus,
                      background: colors.info.withValues(alpha: 0.12),
                      foreground: colors.info,
                    ),
                    _StatusBadge(
                      label:
                          'Commission ${_currency(order.platformCommission)}',
                      background: colors.warning.withValues(alpha: 0.12),
                      foreground: colors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: colors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to view more details',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showTransactionDetails(
  BuildContext context,
  SellerOrderModel order,
) async {
  final colors = context.appColors;
  final net = order.sellerNetAmount;
  final payoutState =
      order.status == 'Delivered' && order.paymentStatus == 'Paid'
      ? 'Available for payout'
      : 'Still processing';
  final totalItems = order.items.fold<int>(
    0,
    (sum, item) => sum + item.quantity,
  );
  final topProduct = order.items.isEmpty
      ? 'No products'
      : order.items.first.product.title;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction details',
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A closer payout breakdown for ${order.id}.',
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DetailMetric(
                            label: 'Seller net',
                            value: _currency(net),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailMetric(
                            label: 'Order total',
                            value: _currency(order.subtotal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailMetric(
                            label: 'Commission',
                            value: _currency(order.platformCommission),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailMetric(
                            label: 'Payout state',
                            value: payoutState,
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
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order summary',
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Order ID', value: order.id),
                    _DetailRow(label: 'Customer', value: order.customerName),
                    _DetailRow(
                      label: 'Order date',
                      value: _formatDate(order.createdAt),
                    ),
                    _DetailRow(
                      label: 'Estimated delivery',
                      value: _formatDate(order.estimatedDelivery),
                    ),
                    _DetailRow(label: 'Order status', value: order.status),
                    _DetailRow(
                      label: 'Payment status',
                      value: order.paymentStatus,
                    ),
                    _DetailRow(
                      label: 'Shipping status',
                      value: order.shippingStatus,
                    ),
                    _DetailRow(
                      label: 'Payment method',
                      value:
                          '${order.paymentMethod.brand} ${order.paymentMethod.maskedNumber}',
                    ),
                    _DetailRow(
                      label: 'Ship to',
                      value:
                          '${order.address.streetAddress}, ${order.address.city}, ${order.address.region}',
                    ),
                    _DetailRow(label: 'Items', value: '$totalItems item(s)'),
                    _DetailRow(label: 'Top product', value: topProduct),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.sellerOrderDetails,
                          arguments: order.id,
                        );
                      },
                      child: const Text('Open Full Order'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FinanceSectionHeader extends StatelessWidget {
  const _FinanceSectionHeader({required this.title, required this.subtitle});

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
            fontSize: 26,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: colors.secondaryText, fontSize: 13),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

class _HeroFinancePill extends StatelessWidget {
  const _HeroFinancePill({required this.label, required this.value});

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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFinanceState extends StatelessWidget {
  const _EmptyFinanceState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
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
              Icons.account_balance_wallet_outlined,
              color: colors.inactiveIcon,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No finance activity yet',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Once orders start coming in, payouts and transaction summaries will appear here.',
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

class _FinanceMetricItem {
  const _FinanceMetricItem({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color tint;
}

String _currency(double value) => '\$${value.toStringAsFixed(2)}';

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

Color _statusColor(BuildContext context, String status) {
  final colors = context.appColors;
  switch (status) {
    case 'Delivered':
      return colors.success;
    case 'Processing':
      return colors.warning;
    case 'Shipped':
      return colors.info;
    case 'Unpaid':
      return colors.accent;
    default:
      return colors.primaryText;
  }
}
