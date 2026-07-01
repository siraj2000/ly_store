import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/notification_controller.dart';
import '../../../controllers/seller_dashboard_controller.dart';
import '../../../controllers/seller_product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/notification_model.dart';
import '../../../models/product_model.dart';
import '../../../models/product_status.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerDashboardController>(
      builder: (context, controller, _) {
        final colors = context.appColors;

        if (controller.isLoading) {
          return Scaffold(
            backgroundColor: colors.background,
            body: AppLoading(
              layout: AppLoadingLayout.dashboard,
              message: context.tr(
                'Loading dashboard',
                'جاري تحميل لوحة البائع',
              ),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: colors.background,
            body: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: context.tr(
                'Failed to load dashboard',
                'فشل تحميل لوحة البائع',
              ),
              message: controller.errorMessage!,
              action: ElevatedButton(
                onPressed: controller.refresh,
                child: Text(context.tr('Try again', 'حاول مرة أخرى')),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16,
                      14,
                      16,
                      MediaQuery.paddingOf(context).bottom + 28,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SellerDashboardTopBar(controller: controller),
                        const SizedBox(height: 16),
                        _SearchAndAddRow(controller: controller),
                        const SizedBox(height: 16),
                        _EarningsCard(controller: controller),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 620;
                            if (!isWide) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _DashboardSummaryCard(
                                      title: context.tr(
                                        'Inventory Alerts',
                                        'تنبيهات المخزون',
                                      ),
                                      value: context.tr(
                                        '${controller.lowStockProducts} low-stock items',
                                        '${controller.lowStockProducts} عناصر منخفضة المخزون',
                                      ),
                                      icon: Icons.warning_amber_rounded,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.sellerProducts,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _DashboardSummaryCard(
                                      title: context.tr(
                                        'Open Orders',
                                        'الطلبات المفتوحة',
                                      ),
                                      value: context.tr(
                                        '${controller.openOrders.length} shipments',
                                        '${controller.openOrders.length} شحنات',
                                      ),
                                      icon: Icons.shopping_bag_rounded,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.sellerOrders,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: (constraints.maxWidth - 12) / 2,
                                  child: _DashboardSummaryCard(
                                    title: context.tr(
                                      'Inventory Alerts',
                                      'تنبيهات المخزون',
                                    ),
                                    value: context.tr(
                                      '${controller.lowStockProducts} low-stock items',
                                      '${controller.lowStockProducts} عناصر منخفضة المخزون',
                                    ),
                                    icon: Icons.warning_amber_rounded,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.sellerProducts,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: (constraints.maxWidth - 12) / 2,
                                  child: _DashboardSummaryCard(
                                    title: context.tr(
                                      'Open Orders',
                                      'الطلبات المفتوحة',
                                    ),
                                    value: context.tr(
                                      '${controller.openOrders.length} shipments',
                                      '${controller.openOrders.length} شحنات',
                                    ),
                                    icon: Icons.shopping_bag_rounded,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.sellerOrders,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _VerificationCard(controller: controller),
                        const SizedBox(height: 20),
                        _ProductsSection(controller: controller),
                        const SizedBox(height: 16),
                        _SalesSummaryCard(controller: controller),
                        const SizedBox(height: 20),
                        _NotificationsSection(controller: controller),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SellerDashboardTopBar extends StatelessWidget {
  const _SellerDashboardTopBar({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_rounded, color: colors.info, size: 18),
              const SizedBox(width: 7),
              Text(
                'LY STORE',
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              context.tr('Dashboard', 'لوحة البائع'),
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        _SellerBellButton(count: controller.unreadNotifications),
      ],
    );
  }
}

class _SellerBellButton extends StatelessWidget {
  const _SellerBellButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = count > 99 ? '99+' : '$count';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_rounded,
                color: colors.primaryText,
                size: 24,
              ),
            ),
            if (count > 0)
              PositionedDirectional(
                top: 2,
                end: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: colors.discount,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndAddRow extends StatelessWidget {
  const _SearchAndAddRow({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: context.tr(
                'Search products, orders or customers',
                'ابحث عن المنتجات أو الطلبات أو العملاء',
              ),
              filled: true,
              fillColor: colors.surface,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: controller.clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          height: 54,
          child: FilledButton(
            onPressed: () => _openAddProduct(context, controller),
            style: FilledButton.styleFrom(
              backgroundColor: colors.info,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.tr('Add', 'إضافة'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final change = controller.earningsLastWeekChangePercent;
    return _DashboardCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.sellerFinance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SmallLabel(text: context.tr('Earnings', 'الأرباح')),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(controller.totalSales),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (change != null)
                      Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% ${context.tr('since last week', 'منذ الأسبوع الماضي')}',
                        style: TextStyle(
                          color: change >= 0 ? colors.info : colors.discount,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 82,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.info, colors.accent],
                    begin: AlignmentDirectional.bottomStart,
                    end: AlignmentDirectional.topEnd,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: _MiniChartPainter(
                    values: controller.revenueChartPoints,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStatBox(
                  label: context.tr('Today', 'اليوم'),
                  value: formatCurrency(controller.todaySales),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatBox(
                  label: context.tr('Pending', 'بانتظار'),
                  value: formatCurrency(controller.pendingEarnings),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStatBox(
                  label: context.tr('Month', 'الشهر'),
                  value: formatCurrency(controller.earningsThisMonth),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _DashboardCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmallLabel(text: title),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _IconTile(icon: icon),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final complete = controller.storeIsActive;
    final status = complete
        ? context.tr('Approved', 'معتمد')
        : context.tr(
            'Identity verified • Bank pending',
            'الهوية موثقة • الحساب البنكي بانتظار المراجعة',
          );
    return _DashboardCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmallLabel(
                  text: context.tr('Store verification', 'توثيق المتجر'),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: context.appColors.primaryText,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.sellerStore),
            child: Text(
              complete
                  ? context.tr('View all', 'عرض الكل')
                  : context.tr('Resolve', 'معالجة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.dashboardProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: context.tr('Products', 'المنتجات'),
          trailing: context.tr(
            '${controller.filteredProducts.length} items',
            '${controller.filteredProducts.length} عناصر',
          ),
          onTap: () => Navigator.pushNamed(context, AppRoutes.sellerProducts),
        ),
        const SizedBox(height: 10),
        if (products.isEmpty)
          _DashboardCard(
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.tr('No products yet', 'لا توجد منتجات بعد'),
              message: context.tr(
                'Add products to start selling.',
                'أضف منتجات لتبدأ البيع.',
              ),
              action: FilledButton(
                onPressed: () => _openAddProduct(context, controller),
                child: Text(context.tr('Add', 'إضافة')),
              ),
            ),
          )
        else
          ...products.map((product) => _ProductDashboardRow(product: product)),
      ],
    );
  }
}

class _ProductDashboardRow extends StatelessWidget {
  const _ProductDashboardRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _DashboardCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: ProductImage(
                imageUrl: product.imageUrl,
                imageUrls: [...product.imageUrls, ...product.localImagePaths],
                radius: 10,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.resolvedTitle(locale),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('SKU', 'رمز المنتج')}: ${product.sku} • ${_productMeta(context, product)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatCurrency(product.price),
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (product.status != ProductStatus.active)
                        _StatusPill(
                          label: _statusLabel(context, product.status),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.sellerEditProduct,
                    arguments: product,
                  ),
                  child: Text(context.tr('Edit', 'تعديل')),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _copyProduct(context, product),
                  child: Text(context.tr('Copy', 'نسخ')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesSummaryCard extends StatelessWidget {
  const _SalesSummaryCard({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.sellerFinance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: context.tr('Sales Summary', 'ملخص المبيعات'),
            subtitle: context.tr('Revenue breakdown', 'تفصيل الإيرادات'),
            trailing: context.tr('Last 30 days', 'آخر 30 يوم'),
          ),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _SalesChartPainter(
                values: controller.revenueChartPoints,
                color: context.appColors.info,
                mutedColor: context.appColors.border,
                textColor: context.appColors.secondaryText,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _MiniStatText(
                  label: context.tr('Today', 'اليوم'),
                  value: formatCurrency(controller.todaySales),
                ),
              ),
              Expanded(
                child: _MiniStatText(
                  label: context.tr('7 days', '7 أيام'),
                  value: formatCurrency(controller.sales7Days),
                ),
              ),
              Expanded(
                child: _MiniStatText(
                  label: context.tr('30 days', '30 يوم'),
                  value: formatCurrency(controller.sales30Days),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({required this.controller});

  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final notifications = controller.latestNotifications;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: context.tr('Notifications', 'الإشعارات'),
          trailing: context.tr(
            '${controller.unreadNotifications} unread',
            '${controller.unreadNotifications} غير مقروءة',
          ),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        const SizedBox(height: 10),
        if (notifications.isEmpty)
          _DashboardCard(
            child: AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: context.tr('No notifications yet', 'لا توجد إشعارات بعد'),
              message: context.tr(
                'Seller notifications will appear here.',
                'ستظهر إشعارات البائع هنا.',
              ),
            ),
          )
        else
          ...notifications.map(
            (notification) => _NotificationDashboardRow(
              notification: notification,
              controller: controller,
            ),
          ),
      ],
    );
  }
}

class _NotificationDashboardRow extends StatelessWidget {
  const _NotificationDashboardRow({
    required this.notification,
    required this.controller,
  });

  final NotificationModel notification;
  final SellerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _DashboardCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _openNotification(context, notification, controller),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: notification.isRead
                  ? colors.surfaceSoft
                  : colors.info.withValues(alpha: 0.12),
              child: Icon(
                _notificationIcon(notification.type),
                color: notification.isRead ? colors.secondaryText : colors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _notificationTitle(context, notification),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: notification.isRead
                          ? FontWeight.w700
                          : FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_notificationMessage(context, notification)} • ${_relativeTime(context, notification.createdAt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.10 : 0.03,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(trailing!))
        else if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.appColors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.info.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: colors.info),
    );
  }
}

class _MiniStatBox extends StatelessWidget {
  const _MiniStatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
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
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primaryText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatText extends StatelessWidget {
  const _MiniStatText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: colors.secondaryText, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.primaryText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.warning,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  const _MiniChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = _scaledPoints(values, size);
    if (points.length < 2) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _SalesChartPainter extends CustomPainter {
  const _SalesChartPainter({
    required this.values,
    required this.color,
    required this.mutedColor,
    required this.textColor,
  });

  final List<double> values;
  final Color color;
  final Color mutedColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = textColor
      ..strokeWidth = 2;
    final left = 22.0;
    final bottom = size.height - 24;
    canvas.drawLine(Offset(left, 12), Offset(left, bottom), axisPaint);
    canvas.drawLine(
      Offset(left, bottom),
      Offset(size.width - 10, bottom),
      axisPaint,
    );

    final chartSize = Size(size.width - 44, size.height - 44);
    final points = _scaledPoints(
      values,
      chartSize,
    ).map((point) => point.translate(left, 10)).toList();
    if (points.length < 2) {
      return;
    }
    final mutedPath = Path()..moveTo(points.first.dx, points.first.dy + 10);
    for (final point in points.skip(1)) {
      mutedPath.lineTo(point.dx, math.min(bottom, point.dy + 10));
    }
    canvas.drawPath(
      mutedPath,
      Paint()
        ..color = mutedColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.mutedColor != mutedColor;
}

List<Offset> _scaledPoints(List<double> values, Size size) {
  if (values.isEmpty) {
    return const [];
  }
  final maxValue = values.reduce(math.max);
  final safeMax = maxValue <= 0 ? 1.0 : maxValue;
  final step = values.length == 1
      ? size.width
      : size.width / (values.length - 1);
  return List<Offset>.generate(values.length, (index) {
    final x = index * step;
    final y = size.height - ((values[index] / safeMax) * (size.height - 8)) - 4;
    return Offset(x, y);
  });
}

Future<void> _openAddProduct(
  BuildContext context,
  SellerDashboardController controller,
) async {
  if (controller.storeIsSuspended) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'Your seller account is suspended. Add product is unavailable.',
            'حساب البائع موقوف. إضافة المنتجات غير متاحة.',
          ),
        ),
      ),
    );
    return;
  }
  Navigator.pushNamed(context, AppRoutes.sellerAddProduct);
}

Future<void> _copyProduct(BuildContext context, ProductModel product) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.tr('Copy product', 'نسخ المنتج')),
      content: Text(
        context.tr(
          'A draft copy will be created for your store.',
          'سيتم إنشاء نسخة مسودة لهذا المنتج داخل متجرك.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.tr('Cancel', 'إلغاء')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.tr('Copy', 'نسخ')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }
  final result = await context.read<SellerProductController>().duplicateProduct(
    product,
  );
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result == null
            ? context.tr('Could not copy this product.', 'تعذر نسخ هذا المنتج.')
            : context.tr(
                'Draft product copy created.',
                'تم إنشاء نسخة مسودة من المنتج.',
              ),
      ),
    ),
  );
}

void _openNotification(
  BuildContext context,
  NotificationModel notification,
  SellerDashboardController controller,
) {
  context.read<NotificationController>().markAsRead(notification.id);
  if (notification.entityType == 'seller_order' ||
      notification.type == NotificationType.newOrderSeller) {
    Navigator.pushNamed(
      context,
      AppRoutes.sellerOrderDetails,
      arguments: notification.entityId,
    );
    return;
  }
  if (notification.entityType == 'product') {
    final matches = controller.sellerProducts.where(
      (product) => product.id == notification.entityId,
    );
    if (matches.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.sellerEditProduct,
        arguments: matches.first,
      );
      return;
    }
  }
  if (notification.type == NotificationType.refundCompleted) {
    Navigator.pushNamed(context, AppRoutes.sellerFinance);
    return;
  }
  Navigator.pushNamed(context, AppRoutes.notifications);
}

String _productMeta(BuildContext context, ProductModel product) {
  final variantCount = product.variants.length;
  if (variantCount > 0) {
    return context.tr(
      '$variantCount variants • ${product.stock} in stock',
      '$variantCount متغيرات • ${product.stock} في المخزون',
    );
  }
  return context.tr('${product.stock} in stock', '${product.stock} في المخزون');
}

String _statusLabel(BuildContext context, ProductStatus status) {
  return switch (status) {
    ProductStatus.pendingApproval => context.tr('Pending', 'بانتظار'),
    ProductStatus.submitted ||
    ProductStatus.automatedReview ||
    ProductStatus.manualReview ||
    ProductStatus.informationRequired => context.tr(
      'In review',
      'قيد المراجعة',
    ),
    ProductStatus.rejected => context.tr('Rejected', 'مرفوض'),
    ProductStatus.draft => context.tr('Draft', 'مسودة'),
    ProductStatus.outOfStock => context.tr('Out of stock', 'غير متوفر'),
    ProductStatus.inactive => context.tr('Inactive', 'غير نشط'),
    ProductStatus.restricted ||
    ProductStatus.suspended ||
    ProductStatus.recalled ||
    ProductStatus.archived => context.tr('Restricted', 'مقيد'),
    ProductStatus.deleted => context.tr('Deleted', 'محذوف'),
    ProductStatus.active => context.tr('Active', 'نشط'),
  };
}

IconData _notificationIcon(NotificationType type) {
  return switch (type) {
    NotificationType.newOrderSeller => Icons.shopping_cart_rounded,
    NotificationType.lowStock => Icons.error_rounded,
    NotificationType.refundCompleted => Icons.account_balance_wallet_rounded,
    NotificationType.productApproved => Icons.verified_rounded,
    NotificationType.productRejected => Icons.report_problem_rounded,
    _ => Icons.notifications_rounded,
  };
}

String _notificationTitle(
  BuildContext context,
  NotificationModel notification,
) {
  if (notification.legacyTitle != null) {
    return notification.legacyTitle!;
  }
  return switch (notification.type) {
    NotificationType.newOrderSeller => context.tr('New order', 'طلب جديد'),
    NotificationType.lowStock => context.tr('Low stock', 'مخزون منخفض'),
    NotificationType.refundCompleted => context.tr(
      'Payout processed',
      'تمت معالجة الدفعة',
    ),
    NotificationType.productApproved => context.tr(
      'Product approved',
      'تمت الموافقة على المنتج',
    ),
    NotificationType.productRejected => context.tr(
      'Product rejected',
      'تم رفض المنتج',
    ),
    _ => context.tr('Notification', 'إشعار'),
  };
}

String _notificationMessage(
  BuildContext context,
  NotificationModel notification,
) {
  if (notification.legacyMessage != null) {
    return notification.legacyMessage!;
  }
  final message = notification.data['message']?.toString();
  if (message != null && message.isNotEmpty) {
    return message;
  }
  return context.tr('Open for more details', 'افتح للمزيد من التفاصيل');
}

String _relativeTime(BuildContext context, DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) {
    return context.tr('${diff.inMinutes}m ago', 'منذ ${diff.inMinutes} د');
  }
  if (diff.inHours < 24) {
    return context.tr('${diff.inHours}h ago', 'منذ ${diff.inHours} س');
  }
  return context.tr('${diff.inDays}d ago', 'منذ ${diff.inDays} يوم');
}
