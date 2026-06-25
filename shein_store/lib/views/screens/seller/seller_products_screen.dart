import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/product_status.dart';
import '../../widgets/common/app_header.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProductController>(
      builder: (context, controller, _) {
        final colors = context.appColors;
        final l10n = context.l10n;
        final filteredProducts = controller.products;
        final catalogProducts = controller.catalogProducts;
        final activeCount = catalogProducts
            .where((product) => product.status == ProductStatus.active)
            .length;
        final pendingCount = catalogProducts
            .where((product) => product.status == ProductStatus.pendingApproval)
            .length;
        final lowStockCount = catalogProducts
            .where((product) => product.stock <= 5)
            .length;

        return Scaffold(
          appBar: AppHeader(
            title: l10n.sellerProductsTitle,
            actions: [
              IconButton(
                tooltip: l10n.sellerProductsAddTooltip,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.sellerAddProduct),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 120),
            children: [
              _SellerProductsHero(
                totalProducts: catalogProducts.length,
                activeCount: activeCount,
                pendingCount: pendingCount,
                lowStockCount: lowStockCount,
              ),
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
                    hintText: l10n.sellerProductsSearchHint,
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
                  children: const [
                    _SellerStatusChip(filterValue: 'All'),
                    _SellerStatusChip(filterValue: 'Active'),
                    _SellerStatusChip(filterValue: 'Pending Approval'),
                    _SellerStatusChip(filterValue: 'Rejected'),
                    _SellerStatusChip(filterValue: 'Out of Stock'),
                    _SellerStatusChip(filterValue: 'Draft'),
                    _SellerStatusChip(filterValue: 'Inactive'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SectionRow(
                title: l10n.sellerProductsCatalogTitle,
                subtitle: l10n.sellerProductsCatalogSubtitle(
                  filteredProducts.length,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredProducts.isEmpty)
                const _EmptyProductsState()
              else
                ...filteredProducts.map(
                  (product) => _SellerProductCard(product: product),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SellerProductsHero extends StatelessWidget {
  const _SellerProductsHero({
    required this.totalProducts,
    required this.activeCount,
    required this.pendingCount,
    required this.lowStockCount,
  });

  final int totalProducts;
  final int activeCount;
  final int pendingCount;
  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF151F2C), Color(0xFF24364A), Color(0xFF35304F)]
              : const [Color(0xFF181818), Color(0xFF41516B), Color(0xFF916C56)],
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
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sellerProductsHeroTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.sellerProductsHeroSubtitle,
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
                  label: context.l10n.sellerProductsTotalProducts,
                  value: '$totalProducts',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  label: context.l10n.statusActive,
                  value: '$activeCount',
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
                icon: Icons.schedule_outlined,
                text: context.l10n.sellerProductsPendingApprovalCount(
                  pendingCount,
                ),
              ),
              _HeroPill(
                icon: Icons.warning_amber_rounded,
                text: context.l10n.sellerProductsLowStockCount(lowStockCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SellerStatusChip extends StatelessWidget {
  const _SellerStatusChip({required this.filterValue});

  final String filterValue;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SellerProductController>();
    final colors = context.appColors;
    final selected = controller.statusFilter == filterValue;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(_statusFilterLabel(context, filterValue)),
        selected: selected,
        labelStyle: TextStyle(
          color: selected ? colors.surface : colors.primaryText,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: colors.border),
        backgroundColor: colors.card,
        selectedColor: colors.primaryText,
        onSelected: (_) => controller.setStatusFilter(filterValue),
      ),
    );
  }
}

class _SellerProductCard extends StatelessWidget {
  const _SellerProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SellerProductController>();
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final status = localizedSellerProductStatus(context, product.status);
    final statusColor = _statusColor(colors, product.status);

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.background.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ProductImage(
                  imageUrl: product.imageUrl,
                  imageUrls: product.imageUrls,
                  width: 98,
                  height: 128,
                  radius: 18,
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
                            product.resolvedTitle(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatCurrency(context, product.price),
                          style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusBadge(label: status, color: statusColor),
                        _TinyBadge(
                          label: product.isActive
                              ? context.l10n.sellerProductsVisible
                              : context.l10n.sellerProductsHidden,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        'SKU ${product.sku}',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _productClassificationPath(context, product),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            label: context.l10n.sellerProductsStock,
                            value: '${product.stock}',
                            hint: product.stock <= 5
                                ? context.l10n.sellerProductsLow
                                : context.l10n.sellerProductsGood,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoTile(
                            label: context.l10n.sellerProductsViews,
                            value: '${product.views}',
                            hint: context.l10n.sellerProductsTraffic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoTile(
                            label: context.l10n.sellerProductsSold,
                            value: '${product.soldCount}',
                            hint: context.l10n.sellerProductsOrders,
                          ),
                        ),
                      ],
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
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.sellerEditProduct,
                    arguments: product,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(context.l10n.commonEdit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showActionsSheet(
                    context,
                    controller: controller,
                    product: product,
                  ),
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(context.l10n.commonManage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

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
            fontWeight: FontWeight.w800,
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

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sellerProductsEmptyTitle,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.sellerProductsEmptyMessage,
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

void _showActionsSheet(
  BuildContext context, {
  required SellerProductController controller,
  required ProductModel product,
}) {
  final locale = Localizations.localeOf(context);

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final colors = sheetContext.appColors;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.resolvedTitle(locale),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sheetContext.l10n.sellerProductsActionPrompt,
                style: TextStyle(color: colors.secondaryText),
              ),
              const SizedBox(height: 14),
              _ActionSheetTile(
                icon: Icons.copy_outlined,
                label: sheetContext.l10n.sellerProductsDuplicate,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.duplicateProduct(product);
                },
              ),
              _ActionSheetTile(
                icon: Icons.inventory_2_outlined,
                label: sheetContext.l10n.sellerProductsAddFiveStock,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.changeStock(product.id, product.stock + 5);
                },
              ),
              _ActionSheetTile(
                icon: Icons.attach_money_outlined,
                label: sheetContext.l10n.sellerProductsIncreasePrice,
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.changePrice(product.id, product.price + 2);
                },
              ),
              if (controller.isPublicListing(product))
                _ActionSheetTile(
                  icon: Icons.storefront_outlined,
                  label: sheetContext.tr('View as customer', 'عرض كعميل'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetails,
                      arguments: product.id,
                    );
                  },
                ),
              _ActionSheetTile(
                icon: product.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                label: product.isActive
                    ? sheetContext.l10n.sellerProductsDeactivate
                    : sheetContext.l10n.sellerProductsActivate,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmToggleProduct(context, controller, product);
                },
              ),
              _ActionSheetTile(
                icon: Icons.delete_outline,
                label: sheetContext.l10n.commonDelete,
                destructive: true,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteProduct(context, controller, product);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmToggleProduct(
  BuildContext context,
  SellerProductController controller,
  ProductModel product,
) async {
  final locale = Localizations.localeOf(context);
  final title = product.resolvedTitle(locale);
  final isDeactivating = product.isActive;
  final confirmed = await AppConfirmationDialog.show(
    context,
    title: isDeactivating
        ? context.tr('Deactivate product?', 'إيقاف المنتج؟')
        : context.tr('Activate product?', 'تفعيل المنتج؟'),
    message: isDeactivating
        ? context.tr(
            'Deactivating $title will hide it from guests and customers while keeping it in your product list.',
            'عند إيقاف $title لن يظهر للضيوف والعملاء، لكنه سيبقى محفوظاً في قائمة منتجاتك.',
          )
        : context.tr(
            'This product may become visible to guests and customers if the product, store, seller, and stock remain eligible.',
            'قد يصبح هذا المنتج ظاهراً للضيوف والعملاء إذا كان المنتج والمتجر والبائع والمخزون مؤهلين.',
          ),
    cancelLabel: context.tr('Cancel', 'إلغاء'),
    confirmLabel: isDeactivating
        ? context.tr('Deactivate', 'إيقاف')
        : context.tr('Activate', 'تفعيل'),
    icon: isDeactivating
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined,
    tone: isDeactivating
        ? AppConfirmationTone.warning
        : AppConfirmationTone.neutral,
  );
  if (!confirmed) {
    return;
  }
  controller.toggleActive(product.id);
  if (context.mounted) {
    AppActionFeedback.success(
      context,
      isDeactivating
          ? context.tr('Product deactivated', 'تم إيقاف المنتج')
          : context.tr('Product activated', 'تم تفعيل المنتج'),
    );
  }
}

Future<void> _confirmDeleteProduct(
  BuildContext context,
  SellerProductController controller,
  ProductModel product,
) async {
  final title = product.resolvedTitle(Localizations.localeOf(context));
  final confirmed = await AppConfirmationDialog.show(
    context,
    title: context.tr('Delete product?', 'حذف المنتج؟'),
    message: context.tr(
      'Delete $title from your catalog? Historical order data will stay available for reporting.',
      'هل تريد حذف $title من منتجاتك؟ ستبقى بيانات الطلبات السابقة متاحة للتقارير.',
    ),
    cancelLabel: context.tr('Keep Product', 'إبقاء المنتج'),
    confirmLabel: context.tr('Delete', 'حذف'),
    icon: Icons.delete_outline_rounded,
    tone: AppConfirmationTone.destructive,
    barrierDismissible: false,
  );
  if (!confirmed) {
    return;
  }
  controller.deleteProduct(product.id);
  if (context.mounted) {
    AppActionFeedback.success(
      context,
      context.tr('Product deleted', 'تم حذف المنتج'),
    );
  }
}

class _ActionSheetTile extends StatelessWidget {
  const _ActionSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = destructive ? colors.discount : colors.primaryText;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: foreground),
      title: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}

String _statusFilterLabel(BuildContext context, String value) {
  switch (value) {
    case 'All':
      return context.l10n.statusAll;
    case 'Active':
      return context.l10n.statusActive;
    case 'Pending Approval':
      return context.l10n.statusPendingApproval;
    case 'Rejected':
      return context.l10n.statusRejected;
    case 'Out of Stock':
      return context.l10n.statusOutOfStock;
    case 'Draft':
      return context.l10n.statusDraft;
    case 'Inactive':
      return context.tr('Inactive', 'غير نشط');
    default:
      return value;
  }
}

String _productClassificationPath(BuildContext context, ProductModel product) {
  final labels = [
    localizedDepartmentName(context, product.department),
    localizedCategoryName(context, product.categoryName),
    if (product.subcategoryName.isNotEmpty)
      localizedSubcategoryName(context, product.subcategoryName),
  ];
  return labels.join(' • ');
}

Color _statusColor(AppThemeColors colors, ProductStatus status) {
  switch (status) {
    case ProductStatus.active:
      return colors.success;
    case ProductStatus.pendingApproval:
      return colors.warning;
    case ProductStatus.rejected:
      return colors.discount;
    case ProductStatus.outOfStock:
      return colors.info;
    case ProductStatus.draft:
      return colors.secondaryText;
    case ProductStatus.inactive:
      return colors.secondaryText;
    default:
      return colors.secondaryText;
  }
}
