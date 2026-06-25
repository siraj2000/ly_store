import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_dashboard_controller.dart';
import '../../../controllers/seller_order_controller.dart';
import '../../../controllers/seller_product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../models/product_model.dart';
import '../../../models/seller_order_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/notification_bell_button.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerDashboardController>(
      builder: (context, controller, _) {
        final colors = context.appColors;

        return Scaffold(
          appBar: AppHeader(
            title: context.tr('Seller Dashboard', 'لوحة البائع'),
            actions: [
              const NotificationBellButton(),
              IconButton(
                tooltip: context.tr('Add Product', 'إضافة منتج'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerAddProduct),
                icon: const Icon(Icons.add_box_outlined),
              ),
              IconButton(
                tooltip: context.tr('Store', 'المتجر'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerStore),
                icon: const Icon(Icons.storefront_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _OverviewHero(controller: controller),
              const SizedBox(height: 18),
              _SectionHeader(
                title: context.tr('Seller command center', 'مركز تحكم البائع'),
                subtitle: context.tr(
                  'Tap a card to open the exact orders or products that need attention.',
                  'اضغط على البطاقة لفتح الطلبات أو المنتجات المطلوبة مباشرة.',
                ),
              ),
              const SizedBox(height: 12),
              _MetricsGrid(controller: controller),
              const SizedBox(height: 18),
              _SectionHeader(
                title: context.tr('Today’s actions', 'إجراءات اليوم'),
                subtitle: context.tr(
                  'The most important things to handle before the next order rush.',
                  'أهم الأشياء التي تحتاج متابعتها قبل موجة الطلبات التالية.',
                ),
              ),
              const SizedBox(height: 12),
              _TodaysActions(controller: controller),
              const SizedBox(height: 18),
              _SectionHeader(
                title: context.tr('Quick actions', 'إجراءات سريعة'),
                subtitle: context.tr(
                  'Common seller tasks in one place.',
                  'مهام البائع اليومية في مكان واحد.',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ActionCard(
                      label: context.tr('Add Product', 'إضافة منتج'),
                      caption: context.tr(
                        'Create a listing',
                        'أنشئ منتجًا جديدًا',
                      ),
                      icon: Icons.add_box_outlined,
                      tint: colors.accent,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.sellerAddProduct,
                      ),
                    ),
                    _ActionCard(
                      label: context.tr('Products', 'المنتجات'),
                      caption: context.tr(
                        '${controller.sellerProducts.length} listed',
                        '${controller.sellerProducts.length} منتج',
                      ),
                      icon: Icons.inventory_2_outlined,
                      tint: colors.info,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.sellerProducts,
                      ),
                    ),
                    _ActionCard(
                      label: context.tr('Orders', 'الطلبات'),
                      caption: context.tr(
                        '${controller.processingOrders} to process',
                        '${controller.processingOrders} قيد التجهيز',
                      ),
                      icon: Icons.receipt_long_outlined,
                      tint: colors.warning,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sellerOrders),
                    ),
                    _ActionCard(
                      label: context.tr('Finance', 'المالية'),
                      caption: context.tr(
                        '\$${controller.averageOrderValue.toStringAsFixed(0)} avg order',
                        'متوسط الطلب \$${controller.averageOrderValue.toStringAsFixed(0)}',
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      tint: colors.success,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sellerFinance),
                    ),
                    _ActionCard(
                      label: context.tr('Store', 'المتجر'),
                      caption: context.tr(
                        'Profile and settings',
                        'الملف والإعدادات',
                      ),
                      icon: Icons.store_mall_directory_outlined,
                      tint: colors.accent,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sellerStore),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: context.tr('Latest orders', 'أحدث الطلبات'),
                subtitle: context.tr(
                  'Recent customer activity and order status.',
                  'آخر نشاط العملاء وحالة الطلبات.',
                ),
                trailingLabel: context.tr('View all', 'عرض الكل'),
                onTrailingTap: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerOrders),
              ),
              const SizedBox(height: 12),
              if (controller.sellerOrders.isEmpty)
                _EmptyDashboardCard(
                  title: context.tr('No orders yet', 'لا توجد طلبات بعد'),
                  message: context.tr(
                    'New customer orders will appear here.',
                    'ستظهر طلبات العملاء الجديدة هنا.',
                  ),
                )
              else
                ...controller.sellerOrders
                    .take(4)
                    .map((order) => _OrderCard(order: order)),
              const SizedBox(height: 18),
              _SectionHeader(
                title: context.tr('Top products', 'أفضل المنتجات'),
                subtitle: context.tr(
                  'Best sellers with stock and visibility snapshot.',
                  'المنتجات الأفضل مع ملخص المخزون والظهور.',
                ),
              ),
              const SizedBox(height: 12),
              if (controller.bestSellingProducts.isEmpty)
                _EmptyDashboardCard(
                  title: context.tr('No products yet', 'لا توجد منتجات بعد'),
                  message: context.tr(
                    'Add products to start tracking store performance.',
                    'أضف منتجات لتبدأ متابعة أداء المتجر.',
                  ),
                )
              else
                ...controller.bestSellingProducts.map(
                  (product) => _ProductInsightCard(product: product),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final statusColor = _storeStatusColor(
      context.appColors,
      controller.storeStatusId,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF17202D), Color(0xFF25354A), Color(0xFF3A253C)]
              : const [Color(0xFF171717), Color(0xFF5A3B31), Color(0xFFA45A48)],
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                        'Hi, ${controller.sellerName}',
                        'مرحبًا، ${controller.sellerName}',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.storeAddress.isNotEmpty
                          ? controller.storeAddress
                          : context.tr(
                              'A clear overview for sales, stock, and orders.',
                              'نظرة واضحة على المبيعات والمخزون والطلبات.',
                            ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (controller.storePhone.isNotEmpty ||
              controller.businessActivityType.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (controller.storePhone.isNotEmpty)
                    _HeroChip(
                      icon: Icons.phone_outlined,
                      text: controller.storePhone,
                    ),
                  if (controller.businessActivityType.isNotEmpty)
                    _HeroChip(
                      icon: Icons.category_outlined,
                      text: localizedBusinessActivity(
                        context,
                        controller.businessActivityType,
                      ),
                    ),
                  _HeroChip(
                    icon: controller.storeIsActive
                        ? Icons.verified_outlined
                        : Icons.pause_circle_outline,
                    text: _localizedStoreStatus(
                      context,
                      controller.storeStatusId,
                    ),
                  ),
                ],
              ),
            ),
          if (controller.storePhone.isNotEmpty ||
              controller.businessActivityType.isNotEmpty)
            const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final statusBadge = _StoreStatusBadge(
                label: _localizedStoreStatus(context, controller.storeStatusId),
                color: statusColor,
              );
              final addButton = _AddProductHeroButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerAddProduct),
              );
              if (constraints.maxWidth < 350) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statusBadge,
                    const SizedBox(height: 10),
                    addButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: statusBadge),
                  const SizedBox(width: 12),
                  Flexible(child: addButton),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroValue(
                  label: context.tr('Net sales', 'صافي المبيعات'),
                  value: '\$${controller.totalSales.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroValue(
                  label: context.tr('Today', 'اليوم'),
                  value: '\$${controller.todaySales.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.local_shipping_outlined,
                text: context.tr(
                  '${controller.shippedOrders} shipped',
                  '${controller.shippedOrders} مشحون',
                ),
              ),
              _HeroChip(
                icon: Icons.pending_actions_outlined,
                text: context.tr(
                  '${controller.pendingApprovalProducts} pending approval',
                  '${controller.pendingApprovalProducts} بانتظار الموافقة',
                ),
              ),
              _HeroChip(
                icon: Icons.warning_amber_rounded,
                text: context.tr(
                  '${controller.lowStockProducts} low stock',
                  '${controller.lowStockProducts} مخزون منخفض',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MiniSnapshot(
                    label: context.tr('Active', 'نشط'),
                    value: '${controller.activeProducts}',
                  ),
                ),
                Expanded(
                  child: _MiniSnapshot(
                    label: context.tr('Drafts', 'مسودات'),
                    value: '${controller.draftProducts}',
                  ),
                ),
                Expanded(
                  child: _MiniSnapshot(
                    label: context.tr('Views', 'مشاهدات'),
                    value: _compactNumber(controller.totalProductViews),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricItem(
        label: context.tr('New Orders', 'طلبات جديدة'),
        value: '${controller.newOrders}',
        icon: Icons.shopping_bag_outlined,
        urgent: controller.newOrders > 0,
        onTap: () => _openSellerOrders(context, 'New'),
      ),
      _MetricItem(
        label: context.tr('Processing Orders', 'طلبات قيد التجهيز'),
        value: '${controller.processingOrders}',
        icon: Icons.autorenew_rounded,
        onTap: () => _openSellerOrders(context, 'Processing'),
      ),
      _MetricItem(
        label: context.tr('Ready to Ship', 'جاهزة للشحن'),
        value: '${controller.readyToShipOrders}',
        icon: Icons.inventory_2_outlined,
        urgent: controller.readyToShipOrders > 0,
        onTap: () => _openSellerOrders(context, 'Ready to Ship'),
      ),
      _MetricItem(
        label: context.tr('Shipped', 'تم الشحن'),
        value: '${controller.shippedOrders}',
        icon: Icons.local_shipping_outlined,
        onTap: () => _openSellerOrders(context, 'Shipped'),
      ),
      _MetricItem(
        label: context.tr('Delivered', 'تم التسليم'),
        value: '${controller.deliveredOrders}',
        icon: Icons.check_circle_outline,
        onTap: () => _openSellerOrders(context, 'Delivered'),
      ),
      _MetricItem(
        label: context.tr('Returns / Refunds', 'الإرجاع / الاسترداد'),
        value: '${controller.returnOrRefundOrders}',
        icon: Icons.assignment_return_outlined,
        onTap: () => _openSellerOrders(context, 'Returned'),
      ),
      _MetricItem(
        label: context.tr('Active Products', 'منتجات نشطة'),
        value: '${controller.activeProducts}',
        icon: Icons.storefront_outlined,
        onTap: () => _openSellerProducts(context, 'Active'),
      ),
      _MetricItem(
        label: context.tr('Draft Products', 'مسودات المنتجات'),
        value: '${controller.draftProducts}',
        icon: Icons.edit_note_outlined,
        onTap: () => _openSellerProducts(context, 'Draft'),
      ),
      _MetricItem(
        label: context.tr('Pending Approval', 'بانتظار الموافقة'),
        value: '${controller.pendingApprovalProducts}',
        icon: Icons.hourglass_top_outlined,
        urgent: controller.pendingApprovalProducts > 0,
        onTap: () => _openSellerProducts(context, 'Pending Approval'),
      ),
      _MetricItem(
        label: context.tr('Out of Stock', 'نفد المخزون'),
        value: '${controller.outOfStockProducts}',
        icon: Icons.warning_amber_rounded,
        urgent: controller.outOfStockProducts > 0,
        onTap: () => _openSellerProducts(context, 'Out of Stock'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 620 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth >= 620 ? 1.38 : 1.1,
          ),
          itemBuilder: (context, index) => _MetricCard(item: items[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.urgent ? colors.warning : colors.border,
            width: item.urgent ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.urgent
                        ? colors.warning.withValues(alpha: 0.14)
                        : colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.urgent ? colors.warning : colors.icon,
                  ),
                ),
                const Spacer(),
                if (item.urgent)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
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
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.caption,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 172,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SellerOrderModel order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = _statusColor(colors, order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long_outlined, color: colors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id.replaceAll('_', ' ').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(label: order.status, color: statusColor),
                    Text(
                      _maskCustomerName(order.customerName),
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.sellerNetAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                style: TextStyle(color: colors.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductInsightCard extends StatelessWidget {
  const _ProductInsightCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stockRatio = (product.stock / 30).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoPill(label: 'Sold', value: '${product.soldCount}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  label: 'Views',
                  value: _compactNumber(product.views),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(label: 'Stock', value: '${product.stock}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: stockRatio,
              backgroundColor: colors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(
                product.stock <= 5 ? colors.warning : colors.success,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.stock <= 5 ? 'Restock soon' : 'Healthy stock level',
            style: TextStyle(
              color: product.stock <= 5 ? colors.warning : colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
        if (trailingLabel != null)
          TextButton(onPressed: onTrailingTap, child: Text(trailingLabel!)),
      ],
    );
  }
}

class _HeroValue extends StatelessWidget {
  const _HeroValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.64),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSnapshot extends StatelessWidget {
  const _MiniSnapshot({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyDashboardCard extends StatelessWidget {
  const _EmptyDashboardCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.urgent = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool urgent;
}

class _TodaysActions extends StatelessWidget {
  const _TodaysActions({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _TodayActionData(
        icon: Icons.shopping_bag_outlined,
        title: context.tr('Accept new orders', 'قبول الطلبات الجديدة'),
        subtitle: context.tr(
          '${controller.newOrders} waiting for seller action',
          '${controller.newOrders} بانتظار إجراء من البائع',
        ),
        count: controller.newOrders,
        onTap: () => _openSellerOrders(context, 'New'),
      ),
      _TodayActionData(
        icon: Icons.inventory_2_outlined,
        title: context.tr('Restock products', 'تحديث المخزون'),
        subtitle: context.tr(
          '${controller.outOfStockProducts} out of stock',
          '${controller.outOfStockProducts} نفد من المخزون',
        ),
        count: controller.outOfStockProducts,
        onTap: () => _openSellerProducts(context, 'Out of Stock'),
      ),
      _TodayActionData(
        icon: Icons.fact_check_outlined,
        title: context.tr('Approval follow-up', 'متابعة الموافقات'),
        subtitle: context.tr(
          '${controller.pendingApprovalProducts} pending, ${controller.rejectedProducts} rejected',
          '${controller.pendingApprovalProducts} بانتظار الموافقة، ${controller.rejectedProducts} مرفوض',
        ),
        count: controller.pendingApprovalProducts + controller.rejectedProducts,
        onTap: () => _openSellerProducts(
          context,
          controller.rejectedProducts > 0 ? 'Rejected' : 'Pending Approval',
        ),
      ),
      _TodayActionData(
        icon: Icons.notifications_none_outlined,
        title: context.tr('Unread notifications', 'إشعارات غير مقروءة'),
        subtitle: context.tr(
          '${controller.unreadNotifications} unread messages',
          '${controller.unreadNotifications} إشعار غير مقروء',
        ),
        count: controller.unreadNotifications,
        onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
      ),
    ];
    final activeActions = actions.where((action) => action.count > 0).toList();

    if (activeActions.isEmpty) {
      return _EmptyDashboardCard(
        title: context.tr('No urgent actions', 'لا توجد إجراءات عاجلة'),
        message: context.tr(
          'No data available yet',
          'لا توجد بيانات متاحة بعد',
        ),
      );
    }

    return Column(
      children: activeActions
          .map((action) => _TodayActionTile(action: action))
          .toList(),
    );
  }
}

class _TodayActionData {
  const _TodayActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;
}

class _TodayActionTile extends StatelessWidget {
  const _TodayActionTile({required this.action});

  final _TodayActionData action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: colors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        color: colors.secondaryText,
                        height: 1.25,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: colors.inactiveIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreStatusBadge extends StatelessWidget {
  const _StoreStatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProductHeroButton extends StatelessWidget {
  const _AddProductHeroButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.add_box_outlined, size: 18),
      label: Text(
        context.tr('Add Product', 'إضافة منتج'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

String _maskCustomerName(String name) {
  if (name.length <= 2) {
    return name;
  }
  return '${name.substring(0, 2)}***';
}

void _openSellerOrders(BuildContext context, String status) {
  context.read<SellerOrderController>().setStatusFilter(status);
  Navigator.pushNamed(context, AppRoutes.sellerOrders);
}

void _openSellerProducts(BuildContext context, String status) {
  context.read<SellerProductController>().setStatusFilter(status);
  Navigator.pushNamed(context, AppRoutes.sellerProducts);
}

String _localizedStoreStatus(BuildContext context, String statusId) {
  switch (statusId) {
    case 'active':
      return context.tr('Active', 'نشط');
    case 'inactive':
      return context.tr('Inactive', 'غير نشط');
    case 'vacation':
      return context.tr('Vacation Mode', 'وضع الإجازة');
    case 'suspended':
      return context.tr('Suspended', 'موقوف');
    default:
      return context.tr('No data available yet', 'لا توجد بيانات متاحة بعد');
  }
}

Color _storeStatusColor(AppThemeColors colors, String statusId) {
  switch (statusId) {
    case 'active':
      return colors.success;
    case 'vacation':
      return colors.info;
    case 'suspended':
      return colors.discount;
    case 'inactive':
      return colors.warning;
    default:
      return colors.secondaryText;
  }
}

Color _statusColor(AppThemeColors colors, String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return colors.warning;
    case 'shipped':
      return colors.info;
    case 'delivered':
      return colors.success;
    case 'unpaid':
      return colors.discount;
    default:
      return colors.secondaryText;
  }
}

String _compactNumber(int value) {
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}k';
  }
  return '$value';
}
