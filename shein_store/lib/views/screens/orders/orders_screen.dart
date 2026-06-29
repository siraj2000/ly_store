import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/common/app_header.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.initialStatus = 'All'});

  final String initialStatus;

  static const _tabs = [
    'All',
    'Unpaid',
    'Processing',
    'Shipped',
    'Delivered',
    'Review',
    'Returns',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final initialIndex = _tabs.indexOf(initialStatus);
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
      child: Scaffold(
        appBar: AppHeader(title: context.tr('Orders', 'الطلبات')),
        body: Column(
          children: [
            TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              isScrollable: true,
              tabs: [
                for (final tab in _tabs) Tab(text: _localizedTab(context, tab)),
              ],
            ),
            Expanded(
              child: Consumer<OrderController>(
                builder: (context, orderController, _) => TabBarView(
                  children: _tabs.map((status) {
                    final orders = orderController.getOrdersByStatus(status);
                    if (orders.isEmpty) {
                      return AppEmptyState(
                        title: context.tr(
                          'No ${status.toLowerCase()} orders',
                          'لا توجد طلبات ${_localizedTab(context, status)}',
                        ),
                        message: context.tr(
                          'Orders in this status will appear here.',
                          'ستظهر هنا الطلبات الموجودة في هذه الحالة.',
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.tr(
                                        'Order ${order.id}',
                                        'الطلب ${order.id}',
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: colors.primaryText,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceSoft,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _localizedTab(context, order.status),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatShortDate(order.createdAt),
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                context.tr(
                                  '${order.items.length} item(s)',
                                  '${order.items.length} منتج',
                                ),
                                style: TextStyle(color: colors.secondaryText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr(
                                  'Total: \$${order.total.toStringAsFixed(2)}',
                                  'الإجمالي: \$${order.total.toStringAsFixed(2)}',
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (order.status == 'Unpaid')
                                    OutlinedButton(
                                      onPressed: () {
                                        orderController.markOrderPaid(order.id);
                                        AppActionFeedback.success(
                                          context,
                                          context.tr(
                                            'Payment completed',
                                            'تم الدفع بنجاح',
                                          ),
                                        );
                                      },
                                      child: Text(
                                        context.tr('Pay Now', 'ادفع الآن'),
                                      ),
                                    ),
                                  if (order.status == 'Unpaid')
                                    OutlinedButton(
                                      onPressed: () => _confirmCancelOrder(
                                        context,
                                        orderController,
                                        order.id,
                                      ),
                                      child: Text(
                                        context.tr(
                                          'Cancel Order',
                                          'إلغاء الطلب',
                                        ),
                                      ),
                                    ),
                                  if (order.status == 'Shipped')
                                    OutlinedButton(
                                      onPressed: () => _confirmReceived(
                                        context,
                                        orderController,
                                        order.id,
                                      ),
                                      child: Text(
                                        context.tr(
                                          'Confirm Received',
                                          'تأكيد الاستلام',
                                        ),
                                      ),
                                    ),
                                  FilledButton.tonal(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.orderDetails,
                                      arguments: order.id,
                                    ),
                                    child: Text(
                                      context.tr(
                                        'View Details',
                                        'عرض التفاصيل',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedTab(BuildContext context, String value) {
    switch (value) {
      case 'All':
        return context.tr('All', 'الكل');
      case 'Unpaid':
        return context.tr('Unpaid', 'غير مدفوع');
      case 'Processing':
        return context.tr('Processing', 'قيد المعالجة');
      case 'Shipped':
        return context.tr('Shipped', 'تم الشحن');
      case 'Delivered':
        return context.tr('Delivered', 'تم التسليم');
      case 'Review':
        return context.tr('Review', 'مراجعة');
      case 'Returns':
        return context.tr('Returns', 'الإرجاع');
      case 'Cancelled':
        return context.tr('Cancelled', 'ملغي');
      default:
        return value;
    }
  }

  Future<void> _confirmCancelOrder(
    BuildContext context,
    OrderController orderController,
    String orderId,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: context.tr('Cancel this order?', 'إلغاء الطلب؟'),
      message: context.tr(
        'Are you sure you want to cancel order $orderId? This action may not be reversible.',
        'هل أنت متأكد من إلغاء الطلب $orderId؟ قد لا تتمكن من التراجع بعد التأكيد.',
      ),
      cancelLabel: context.tr('Keep Order', 'إبقاء الطلب'),
      confirmLabel: context.tr('Cancel Order', 'إلغاء الطلب'),
      icon: Icons.cancel_outlined,
      tone: AppConfirmationTone.destructive,
      barrierDismissible: false,
    );
    if (!confirmed) {
      return;
    }
    orderController.cancelOrder(orderId);
    if (context.mounted) {
      AppActionFeedback.success(
        context,
        context.tr('Order cancelled', 'تم إلغاء الطلب'),
      );
    }
  }

  Future<void> _confirmReceived(
    BuildContext context,
    OrderController orderController,
    String orderId,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: context.tr('Confirm order received', 'تأكيد استلام الطلب'),
      message: context.tr(
        'Confirm only after all items in this order have arrived correctly. This may affect cancellation and refund eligibility.',
        'أكد الاستلام فقط بعد وصول جميع منتجات هذا الطلب بحالة صحيحة. قد يؤثر التأكيد في أهلية الإلغاء والاسترداد.',
      ),
      cancelLabel: context.tr('Not Yet', 'ليس بعد'),
      confirmLabel: context.tr('Confirm Received', 'تأكيد الاستلام'),
      icon: Icons.inventory_2_outlined,
      tone: AppConfirmationTone.warning,
    );
    if (!confirmed) {
      return;
    }
    orderController.confirmReceived(orderId);
    if (context.mounted) {
      AppActionFeedback.success(
        context,
        context.tr('Order marked as received', 'تم تأكيد استلام الطلب'),
      );
    }
  }
}
