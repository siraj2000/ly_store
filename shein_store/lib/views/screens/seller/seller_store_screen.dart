import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/seller_store_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../widgets/common/app_header.dart';

class SellerStoreScreen extends StatelessWidget {
  const SellerStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerStoreController>(
      builder: (context, controller, _) {
        final locale = Localizations.localeOf(context);
        return Scaffold(
          appBar: AppHeader(
            title: _tr(context, 'Seller Profile', 'ملف البائع'),
            actions: const [_SellerProfileActions()],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _SellerProfileHero(controller: controller, locale: locale),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Performance snapshot', 'نظرة على الأداء'),
                subtitle: _tr(
                  context,
                  'A fast read on how this seller account is performing right now.',
                  'نظرة سريعة على أداء حساب البائع الآن.',
                ),
              ),
              const SizedBox(height: 12),
              _ProfileMetricsGrid(controller: controller),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Account details', 'تفاصيل الحساب'),
                subtitle: _tr(
                  context,
                  'Core business identity, contact details, and account health.',
                  'هوية النشاط التجارية وبيانات التواصل وحالة الحساب.',
                ),
              ),
              const SizedBox(height: 12),
              _SellerIdentityCard(controller: controller),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Store profile', 'ملف المتجر'),
                subtitle: _tr(
                  context,
                  'The public-facing story shoppers see when they visit the store.',
                  'الوصف العام الذي يراه المتسوقون عند زيارة المتجر.',
                ),
              ),
              const SizedBox(height: 12),
              _StoreProfileCard(controller: controller, locale: locale),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Operations', 'العمليات'),
                subtitle: _tr(
                  context,
                  'Seller controls and shortcuts for catalog and order management.',
                  'أدوات واختصارات البائع لإدارة المنتجات والطلبات.',
                ),
              ),
              const SizedBox(height: 12),
              _OperationsCard(controller: controller),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Business setup', 'إعدادات النشاط'),
                subtitle: _tr(
                  context,
                  'Payout, warehouse, and customer promise details in one place.',
                  'تفاصيل الدفع والمخزن ووعود خدمة العملاء في مكان واحد.',
                ),
              ),
              const SizedBox(height: 12),
              _BusinessSetupCard(controller: controller),
              const SizedBox(height: 18),
              _ProfileSectionHeader(
                title: _tr(context, 'Featured products', 'المنتجات المميزة'),
                subtitle: _tr(
                  context,
                  'Top catalog pieces that currently represent this seller best.',
                  'أفضل المنتجات التي تمثل هذا البائع حاليًا.',
                ),
              ),
              const SizedBox(height: 12),
              if (controller.featuredProducts.isEmpty)
                const _EmptyStoreState()
              else
                SizedBox(
                  height: 276,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.featuredProducts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _FeaturedProductCard(
                      product: controller.featuredProducts[index],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SellerProfileActions extends StatelessWidget {
  const _SellerProfileActions();

  @override
  Widget build(BuildContext context) {
    final languageController = context.watch<LanguageController>();
    final themeController = context.watch<ThemeController>();
    final isDarkMode = themeController.isDarkMode(context);
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopActionButton(
          tooltip: languageController.isArabic
              ? _tr(context, 'Switch to English', 'التبديل إلى الإنجليزية')
              : _tr(context, 'Switch to Arabic', 'التبديل إلى العربية'),
          onTap: () {
            if (languageController.isArabic) {
              languageController.setEnglish();
              return;
            }
            languageController.setArabic();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.translate_rounded, color: colors.primaryText),
              PositionedDirectional(
                end: -8,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryText,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.isArabic ? 'AR' : 'EN',
                    style: TextStyle(
                      color: colors.surface,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _TopActionButton(
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          onTap: themeController.toggleDarkMode,
          child: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: colors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _SellerProfileHero extends StatelessWidget {
  const _SellerProfileHero({required this.controller, required this.locale});

  final SellerStoreController controller;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final storeName = controller.localizedStoreName(locale);
    final storeDescription = controller.localizedStoreDescription(locale);
    final statusText = controller.vacationMode
        ? _tr(context, 'Vacation mode', 'وضع الإجازة')
        : _tr(context, 'Store live', 'المتجر نشط');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF131C28), Color(0xFF2C4E67), Color(0xFFA45F68)]
              : const [Color(0xFF16181D), Color(0xFF3F617B), Color(0xFFD07A72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.sellerName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroChip(
                          icon: Icons.verified_outlined,
                          text: statusText,
                        ),
                        _HeroChip(
                          icon: Icons.calendar_month_outlined,
                          text: _tr(
                            context,
                            'Since ${controller.memberSince}',
                            'منذ ${controller.memberSince}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            storeDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    label: _tr(context, 'Live products', 'المنتجات النشطة'),
                    value: '${controller.activeProducts}',
                  ),
                ),
                Expanded(
                  child: _HeroMetric(
                    label: _tr(context, 'Orders served', 'الطلبات المنجزة'),
                    value: '${controller.totalSold}',
                  ),
                ),
                Expanded(
                  child: _HeroMetric(
                    label: _tr(context, 'Followers', 'المتابعون'),
                    value: _compactNumber(controller.followers),
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
                  onPressed: () => _showSellerProfileSheet(context, controller),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A2431),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _tr(context, 'Edit Seller Profile', 'تعديل ملف البائع'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.sellerProducts),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_tr(context, 'View Catalog', 'عرض المنتجات')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                controller.vacationMode
                    ? Icons.pause_circle_outline
                    : Icons.check_circle_outline,
                color: Colors.white.withValues(alpha: 0.92),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.vacationMode
                      ? _tr(
                          context,
                          'Vacation mode is enabled. Shoppers can still browse, but the team has a softer fulfillment expectation.',
                          'تم تفعيل وضع الإجازة. لا يزال المتسوقون قادرين على التصفح، لكن توقعات التنفيذ أصبحت أخف.',
                        )
                      : _tr(
                          context,
                          'This seller account is active and ready to capture new orders.',
                          'حساب البائع هذا نشط وجاهز لاستقبال الطلبات الجديدة.',
                        ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricsGrid extends StatelessWidget {
  const _ProfileMetricsGrid({required this.controller});

  final SellerStoreController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = [
      _MetricItem(
        label: _tr(context, 'Catalog views', 'مشاهدات المنتجات'),
        value: _compactNumber(controller.totalViews),
        caption: _tr(
          context,
          'Traffic across all listings',
          'الزيارات عبر جميع المنتجات',
        ),
        icon: Icons.visibility_outlined,
        tint: colors.info,
      ),
      _MetricItem(
        label: _tr(context, 'Units sold', 'الوحدات المباعة'),
        value: '${controller.totalSold}',
        caption: _tr(context, 'Completed item sales', 'المبيعات المكتملة'),
        icon: Icons.shopping_bag_outlined,
        tint: colors.success,
      ),
      _MetricItem(
        label: _tr(context, 'Store rating', 'تقييم المتجر'),
        value: controller.storeRating.toStringAsFixed(1),
        caption: _tr(context, 'Average product rating', 'متوسط تقييم المنتجات'),
        icon: Icons.star_outline_rounded,
        tint: colors.warning,
      ),
      _MetricItem(
        label: _tr(context, 'Pending approval', 'بانتظار الموافقة'),
        value: '${controller.pendingProducts}',
        caption: _tr(
          context,
          'Listings waiting for review',
          'منتجات بانتظار المراجعة',
        ),
        icon: Icons.fact_check_outlined,
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
        childAspectRatio: 1.14,
      ),
      itemBuilder: (context, index) => _MetricCard(item: items[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

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
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerIdentityCard extends StatelessWidget {
  const _SellerIdentityCard({required this.controller});

  final SellerStoreController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tiles = [
      _InfoTileData(
        icon: Icons.person_outline_rounded,
        label: _tr(context, 'Seller name', 'اسم البائع'),
        value: controller.sellerName,
      ),
      _InfoTileData(
        icon: Icons.mail_outline_rounded,
        label: _tr(context, 'Email', 'البريد الإلكتروني'),
        value: controller.sellerEmail.isEmpty
            ? _tr(context, 'No email available', 'لا يوجد بريد إلكتروني')
            : controller.sellerEmail,
      ),
      _InfoTileData(
        icon: Icons.phone_outlined,
        label: _tr(context, 'Phone', 'رقم الهاتف'),
        value: controller.sellerPhone.isEmpty
            ? _tr(context, 'No phone number added', 'لم يتم إضافة رقم هاتف')
            : controller.sellerPhone,
      ),
      _InfoTileData(
        icon: Icons.calendar_today_outlined,
        label: _tr(context, 'Member since', 'عضو منذ'),
        value: controller.memberSince,
      ),
    ];

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
          _CardTitle(
            title: _tr(context, 'Seller identity', 'هوية البائع'),
            subtitle: _tr(
              context,
              'This information defines the business account behind the storefront.',
              'هذه المعلومات تحدد هوية حساب النشاط التجاري خلف المتجر.',
            ),
          ),
          const SizedBox(height: 14),
          ...tiles.map((tile) => _InfoTile(data: tile)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TagPill(
                text: _tr(
                  context,
                  '${controller.activeProducts} active listings',
                  '${controller.activeProducts} منتجات نشطة',
                ),
                tint: colors.success,
              ),
              _TagPill(
                text: _tr(
                  context,
                  '${controller.lowStockProducts} low-stock items',
                  '${controller.lowStockProducts} منتجات منخفضة المخزون',
                ),
                tint: colors.warning,
              ),
              _TagPill(
                text: _tr(
                  context,
                  '${controller.returnableProducts} returnable products',
                  '${controller.returnableProducts} منتجات قابلة للإرجاع',
                ),
                tint: colors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreProfileCard extends StatelessWidget {
  const _StoreProfileCard({required this.controller, required this.locale});

  final SellerStoreController controller;
  final Locale locale;

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
          Row(
            children: [
              Expanded(
                child: _CardTitle(
                  title: _tr(context, 'Store presentation', 'عرض المتجر'),
                  subtitle: _tr(
                    context,
                    'Keep public-facing copy polished for both English and Arabic shoppers.',
                    'حافظ على النص الظاهر للعملاء واضحًا بالإنجليزية والعربية.',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => _showSellerProfileSheet(context, controller),
                child: Text(_tr(context, 'Edit', 'تعديل')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileDisplayBlock(
            label: _tr(context, 'Displayed store name', 'اسم المتجر المعروض'),
            value: controller.localizedStoreName(locale),
          ),
          const SizedBox(height: 12),
          _ProfileDisplayBlock(
            label: _tr(context, 'English name', 'الاسم بالإنجليزية'),
            value: controller.storeNameText.en,
          ),
          const SizedBox(height: 12),
          _ProfileDisplayBlock(
            label: _tr(context, 'Arabic name', 'الاسم بالعربية'),
            value: controller.storeNameText.ar.isEmpty
                ? _tr(context, 'Not added yet', 'لم تتم إضافته بعد')
                : controller.storeNameText.ar,
          ),
          const SizedBox(height: 12),
          _ProfileDisplayBlock(
            label: _tr(context, 'Displayed description', 'الوصف المعروض'),
            value: controller.localizedStoreDescription(locale),
          ),
        ],
      ),
    );
  }
}

class _OperationsCard extends StatelessWidget {
  const _OperationsCard({required this.controller});

  final SellerStoreController controller;

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
          _CardTitle(
            title: _tr(context, 'Seller controls', 'أدوات البائع'),
            subtitle: _tr(
              context,
              'Account-level settings that affect the storefront and team workflow.',
              'إعدادات على مستوى الحساب تؤثر على المتجر وطريقة العمل.',
            ),
          ),
          const SizedBox(height: 14),
          _ControlToggleTile(
            icon: Icons.pause_circle_outline,
            title: _tr(context, 'Vacation mode', 'وضع الإجازة'),
            subtitle: _tr(
              context,
              'Keep the profile visible while setting softer order expectations.',
              'أبقِ الملف ظاهرًا مع تقليل توقعات تنفيذ الطلبات.',
            ),
            value: controller.vacationMode,
            onChanged: controller.toggleVacationMode,
          ),
          const SizedBox(height: 8),
          Divider(color: colors.border),
          const SizedBox(height: 8),
          _ControlToggleTile(
            icon: Icons.notifications_active_outlined,
            title: _tr(context, 'Seller notifications', 'إشعارات البائع'),
            subtitle: _tr(
              context,
              'Receive updates for orders, approvals, and account activity.',
              'استلم تحديثات الطلبات والموافقات ونشاط الحساب.',
            ),
            value: controller.notificationsEnabled,
            onChanged: controller.toggleNotifications,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionPillButton(
                icon: Icons.edit_outlined,
                label: _tr(context, 'Edit profile', 'تعديل الملف'),
                onTap: () => _showSellerProfileSheet(context, controller),
              ),
              _ActionPillButton(
                icon: Icons.inventory_2_outlined,
                label: _tr(context, 'Manage products', 'إدارة المنتجات'),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerProducts),
              ),
              _ActionPillButton(
                icon: Icons.receipt_long_outlined,
                label: _tr(context, 'Review orders', 'مراجعة الطلبات'),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerOrders),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthController>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(color: colors.accent.withValues(alpha: 0.45)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              label: Text(_tr(context, 'Log out', 'تسجيل الخروج')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessSetupCard extends StatelessWidget {
  const _BusinessSetupCard({required this.controller});

  final SellerStoreController controller;

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
          _CardTitle(
            title: _tr(context, 'Business essentials', 'أساسيات النشاط'),
            subtitle: _tr(
              context,
              'Warehouse, payout, and buyer-facing commitments are grouped here.',
              'المخزن والدفع والتزامات خدمة العملاء مجمعة هنا.',
            ),
          ),
          const SizedBox(height: 14),
          _InfoTile(
            data: _InfoTileData(
              icon: Icons.location_on_outlined,
              label: _tr(context, 'Primary warehouse', 'المخزن الرئيسي'),
              value: controller.primaryAddress,
            ),
          ),
          _InfoTile(
            data: _InfoTileData(
              icon: Icons.account_balance_wallet_outlined,
              label: _tr(context, 'Payout method', 'طريقة الدفع'),
              value: controller.payoutSummary,
            ),
          ),
          _InfoTile(
            data: _InfoTileData(
              icon: Icons.replay_outlined,
              label: _tr(context, 'Return policy', 'سياسة الإرجاع'),
              value: _tr(
                context,
                '${controller.returnableProducts} of ${controller.totalProducts} products currently allow returns',
                '${controller.returnableProducts} من أصل ${controller.totalProducts} منتجًا تسمح بالإرجاع حاليًا',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_outlined, color: colors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      'Complete seller profile details help the account feel more trustworthy and make operations easier to manage later.',
                      'اكتمال تفاصيل ملف البائع يجعل الحساب أكثر موثوقية ويسهل إدارة العمليات لاحقًا.',
                    ),
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
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

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final imagePath = product.localImagePaths.isNotEmpty
        ? product.localImagePaths.first
        : product.imageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showFeaturedProductDetails(context, product),
        child: Container(
          width: 214,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(
                        imageUrl: imagePath,
                        imageUrls: imagePath == null ? const [] : [imagePath],
                        radius: 24,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryText.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.categoryName,
                          style: TextStyle(
                            color: colors.surface,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.resolvedTitle(locale),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: colors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.views}',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniProductStat(
                            label: _tr(context, 'Stock', 'المخزون'),
                            value: '${product.stock}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniProductStat(
                            label: _tr(context, 'Sold', 'المباع'),
                            value: '${product.soldCount}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 15,
                          color: colors.secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tr(context, 'Tap for details', 'اضغط للتفاصيل'),
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
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showFeaturedProductDetails(
  BuildContext context,
  ProductModel product,
) async {
  final colors = context.appColors;
  final locale = Localizations.localeOf(context);
  final imagePath = product.localImagePaths.isNotEmpty
      ? product.localImagePaths.first
      : product.imageUrl;

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
                _tr(
                  context,
                  'Featured product details',
                  'تفاصيل المنتج المميز',
                ),
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tr(
                  context,
                  'A closer look at this featured item from the seller profile.',
                  'نظرة أقرب على هذا المنتج المميز من ملف البائع.',
                ),
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: ProductImage(
                    imageUrl: imagePath,
                    imageUrls: imagePath == null ? const [] : [imagePath],
                    radius: 24,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.resolvedTitle(locale),
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.resolvedDescription(locale),
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'Price', 'السعر'),
                      value: '\$${product.price.toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'Old price', 'السعر السابق'),
                      value: '\$${product.oldPrice.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'Stock', 'المخزون'),
                      value: '${product.stock}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'Sold', 'المباع'),
                      value: '${product.soldCount}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'Views', 'المشاهدات'),
                      value: '${product.views}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailMetric(
                      label: _tr(context, 'SKU', 'رمز المنتج'),
                      value: product.sku,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
                      _tr(context, 'Product attributes', 'خصائص المنتج'),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: _tr(context, 'Category', 'الفئة'),
                      value: product.categoryName,
                    ),
                    _DetailRow(
                      label: _tr(context, 'Department', 'القسم'),
                      value: product.department,
                    ),
                    _DetailRow(
                      label: _tr(context, 'Status', 'الحالة'),
                      value: localizedSellerProductStatus(
                        context,
                        product.status,
                      ),
                    ),
                    _DetailRow(
                      label: _tr(context, 'Colors', 'الألوان'),
                      value: product.colors.join(', '),
                    ),
                    _DetailRow(
                      label: _tr(context, 'Sizes', 'المقاسات'),
                      value: product.sizes.join(', '),
                    ),
                    _DetailRow(
                      label: _tr(context, 'Material', 'الخامة'),
                      value: product.resolvedMaterial(locale),
                    ),
                    _DetailRow(
                      label: _tr(context, 'Care', 'العناية'),
                      value: product.resolvedCareInstructions(locale),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(_tr(context, 'Close', 'إغلاق')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.sellerEditProduct,
                          arguments: product,
                        );
                      },
                      child: Text(_tr(context, 'Edit Product', 'تعديل المنتج')),
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

class _MiniProductStat extends StatelessWidget {
  const _MiniProductStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({required this.title, required this.subtitle});

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

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, required this.subtitle});

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

class _InfoTileData {
  const _InfoTileData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.data});

  final _InfoTileData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: colors.primaryText, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
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

class _ProfileDisplayBlock extends StatelessWidget {
  const _ProfileDisplayBlock({required this.label, required this.value});

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
            value.isEmpty
                ? _tr(context, 'Not added yet', 'لم تتم إضافته بعد')
                : value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlToggleTile extends StatelessWidget {
  const _ControlToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colors.primaryText),
        ),
        const SizedBox(width: 12),
        Expanded(
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
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colors.primaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text, required this.tint});

  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: tint,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EmptyStoreState extends StatelessWidget {
  const _EmptyStoreState();

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
            child: Icon(Icons.storefront_outlined, color: colors.inactiveIcon),
          ),
          const SizedBox(height: 12),
          Text(
            _tr(
              context,
              'No featured products yet',
              'لا توجد منتجات مميزة بعد',
            ),
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tr(
              context,
              'Once products are added to the catalog, this seller profile will automatically feel richer here.',
              'بمجرد إضافة منتجات إلى الكتالوج سيصبح ملف البائع هنا أكثر اكتمالًا.',
            ),
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

class _MetricItem {
  const _MetricItem({
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

String _compactNumber(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return '$value';
}

Future<void> _showSellerProfileSheet(
  BuildContext context,
  SellerStoreController controller,
) async {
  final sellerNameController = TextEditingController(
    text: controller.sellerName,
  );
  final phoneController = TextEditingController(text: controller.sellerPhone);
  final storeNameEnController = TextEditingController(
    text: controller.storeNameText.en,
  );
  final storeNameArController = TextEditingController(
    text: controller.storeNameText.ar,
  );
  final descriptionEnController = TextEditingController(
    text: controller.storeDescriptionText.en,
  );
  final descriptionArController = TextEditingController(
    text: controller.storeDescriptionText.ar,
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final colors = context.appColors;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr(context, 'Edit seller profile', 'تعديل ملف البائع'),
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tr(
                  context,
                  'Update the account identity and the storefront details together.',
                  'حدّث هوية الحساب وتفاصيل المتجر معًا.',
                ),
                style: TextStyle(color: colors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 18),
              _SheetTextField(
                controller: sellerNameController,
                label: _tr(context, 'Seller name', 'اسم البائع'),
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: phoneController,
                label: _tr(context, 'Phone number', 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: storeNameEnController,
                label: _tr(
                  context,
                  'Store name (English)',
                  'اسم المتجر بالإنجليزية',
                ),
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: storeNameArController,
                label: _tr(
                  context,
                  'Store name (Arabic)',
                  'اسم المتجر بالعربية',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: descriptionEnController,
                label: _tr(
                  context,
                  'Store description (English)',
                  'وصف المتجر بالإنجليزية',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: descriptionArController,
                label: _tr(
                  context,
                  'Store description (Arabic)',
                  'وصف المتجر بالعربية',
                ),
                maxLines: 4,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_tr(context, 'Cancel', 'إلغاء')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final sellerName = sellerNameController.text.trim();
                        final storeNameEn = storeNameEnController.text.trim();
                        if (sellerName.isEmpty || storeNameEn.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(
                                  context,
                                  'Seller name and English store name are required.',
                                  'اسم البائع واسم المتجر بالإنجليزية مطلوبان.',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        controller.updateSellerProfile(
                          sellerName: sellerName,
                          phone: phoneController.text.trim(),
                          storeNameEn: storeNameEn,
                          storeNameAr: storeNameArController.text.trim(),
                          descriptionEn: descriptionEnController.text.trim(),
                          descriptionAr: descriptionArController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(_tr(context, 'Save', 'حفظ')),
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

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.textDirection,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

String _tr(BuildContext context, String en, String ar) {
  return context.isArabic ? ar : en;
}
