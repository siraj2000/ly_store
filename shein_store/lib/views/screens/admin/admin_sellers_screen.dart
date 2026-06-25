import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_seller_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/admin_seller_localization_helper.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../widgets/common/app_header.dart';

class AdminSellersScreen extends StatelessWidget {
  const AdminSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSellerController>(
      builder: (context, controller, _) {
        final colors = context.appColors;
        final sellers = controller.sellers;
        final activeCount = sellers
            .where((item) => item.user.sellerStatus == 'active')
            .length;
        final pendingCount = sellers
            .where((item) => item.user.sellerStatus == 'pending')
            .length;

        return Scaffold(
          appBar: AppHeader(
            title: context.l10n.adminSellersTitle,
            actions: [
              IconButton(
                tooltip: context.l10n.adminAddSeller,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.adminAddSeller),
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.adminAddSeller),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.adminAddSeller),
          ),
          body: RefreshIndicator(
            onRefresh: controller.loadSellers,
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 96),
              children: [
                _HeroCard(
                  total: sellers.length,
                  active: activeCount,
                  pending: pendingCount,
                ),
                const SizedBox(height: 16),
                _SearchCard(
                  value: controller.searchQuery,
                  onChanged: controller.setSearchQuery,
                ),
                const SizedBox(height: 16),
                if (controller.errorMessage != null)
                  _MessageBanner(
                    message: localizedAdminSellerMessage(
                      context,
                      controller.errorMessage!,
                    ),
                    color: colors.discount,
                  ),
                if (controller.successMessage != null)
                  _MessageBanner(
                    message: localizedAdminSellerMessage(
                      context,
                      controller.successMessage!,
                    ),
                    color: colors.success,
                  ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.adminSellerListSummary(sellers.length),
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                if (controller.isLoading && sellers.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (sellers.isEmpty)
                  _EmptyState(message: context.l10n.adminNoSellersFound)
                else
                  ...sellers.map((seller) => _SellerCard(summary: seller)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.total,
    required this.active,
    required this.pending,
  });

  final int total;
  final int active;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _HeroStat(label: context.l10n.adminTotalSellers, value: '$total'),
          _HeroStat(label: context.l10n.adminStatusActive, value: '$active'),
          _HeroStat(label: context.l10n.adminStatusPending, value: '$pending'),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 140,
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
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

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
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.l10n.adminSearchSellersHint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colors.surfaceSoft,
        ),
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.summary});

  final AdminSellerSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final store = summary.store;
    final statusColor = _statusColor(
      colors,
      SellerAccountStatusX.fromId(summary.user.sellerStatus),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.user.name,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.user.email,
                      style: TextStyle(color: colors.secondaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.user.phone,
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, value, summary),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Text(context.l10n.commonDetails),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(context.l10n.commonEdit),
                  ),
                  PopupMenuItem(
                    value: 'credentials',
                    child: Text(context.l10n.adminViewCredentials),
                  ),
                  PopupMenuItem(
                    value: 'reset',
                    child: Text(context.l10n.adminResetSellerPassword),
                  ),
                  PopupMenuItem(
                    value: summary.user.sellerStatus == 'active'
                        ? 'suspend'
                        : 'activate',
                    child: Text(
                      summary.user.sellerStatus == 'active'
                          ? context.l10n.adminSuspendSeller
                          : context.l10n.adminActivateSeller,
                    ),
                  ),
                  if (store != null)
                    PopupMenuItem(
                      value: 'store',
                      child: Text(context.l10n.adminOpenStore),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: localizedSellerAccountStatusId(
                  context,
                  summary.user.sellerStatus,
                ),
                color: statusColor,
              ),
              if (store != null)
                _MutedPill(
                  label: localizedBusinessActivity(
                    context,
                    store.businessActivityType,
                  ),
                ),
              if (store != null && !store.isActive)
                _MutedPill(label: context.l10n.adminStoreInactive),
            ],
          ),
          const SizedBox(height: 12),
          if (store != null) ...[
            Text(
              store.nameText.valueFor(Localizations.localeOf(context)),
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${store.storePhone} • ${store.city}',
              style: TextStyle(color: colors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              store.addressText.valueFor(Localizations.localeOf(context)),
              style: TextStyle(color: colors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: context.l10n.navProducts,
                  value: '${summary.productCount}',
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  label: context.l10n.navOrders,
                  value: '${summary.orderCount}',
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  label: context.l10n.adminTotalSales,
                  value: formatCurrency(context, summary.totalSales),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.adminCreatedOn(
              formatShortDate(context, summary.user.createdAt),
            ),
            style: TextStyle(color: colors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.adminSellerDetails,
                  arguments: summary.user.id,
                ),
                child: Text(context.l10n.commonDetails),
              ),
              FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.adminEditSeller,
                  arguments: summary.user.id,
                ),
                child: Text(context.l10n.commonEdit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String value,
    AdminSellerSummary summary,
  ) async {
    final controller = context.read<AdminSellerController>();
    switch (value) {
      case 'view':
        Navigator.pushNamed(
          context,
          AppRoutes.adminSellerDetails,
          arguments: summary.user.id,
        );
        return;
      case 'edit':
        Navigator.pushNamed(
          context,
          AppRoutes.adminEditSeller,
          arguments: summary.user.id,
        );
        return;
      case 'store':
        if (summary.store != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.adminStoreDetails,
            arguments: summary.store!.id,
          );
        }
        return;
      case 'credentials':
        await _showCredentialsDialog(
          context,
          sellerName: summary.user.name,
          storeName:
              summary.store?.nameText.valueFor(
                Localizations.localeOf(context),
              ) ??
              context.l10n.adminStoreDetails,
          email: summary.user.email,
          password: summary.user.mockPassword,
        );
        return;
      case 'activate':
        await controller.activateSeller(summary.user.id);
        if (!context.mounted) return;
        _showControllerMessage(context, controller);
        return;
      case 'suspend':
        final reason = await _showReasonDialog(context);
        if (reason == null || reason.trim().isEmpty) {
          return;
        }
        await controller.suspendSeller(summary.user.id, reason);
        if (!context.mounted) return;
        _showControllerMessage(context, controller);
        return;
      case 'reset':
        final password = await _showResetPasswordDialog(
          context,
          controller.generatePassword(),
        );
        if (password == null) {
          return;
        }
        final newPassword = await controller.resetSellerPassword(
          summary.user.id,
          password: password,
        );
        if (!context.mounted) return;
        if (newPassword != null) {
          await _showCredentialsDialog(
            context,
            sellerName: summary.user.name,
            storeName:
                summary.store?.nameText.valueFor(
                  Localizations.localeOf(context),
                ) ??
                context.l10n.adminStoreDetails,
            email: summary.user.email,
            password: newPassword,
          );
        } else {
          _showControllerMessage(context, controller);
        }
        return;
    }
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.secondaryText, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MutedPill extends StatelessWidget {
  const _MutedPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.secondaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

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
      child: Text(
        message,
        style: TextStyle(color: colors.secondaryText, height: 1.35),
      ),
    );
  }
}

Color _statusColor(AppThemeColors colors, SellerAccountStatus status) {
  switch (status) {
    case SellerAccountStatus.active:
      return colors.success;
    case SellerAccountStatus.pending:
      return colors.warning;
    case SellerAccountStatus.suspended:
      return colors.discount;
  }
}

void _showControllerMessage(
  BuildContext context,
  AdminSellerController controller,
) {
  final key = controller.errorMessage ?? controller.successMessage;
  if (key == null) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(localizedAdminSellerMessage(context, key))),
  );
}

Future<String?> _showReasonDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.l10n.adminSuspendSeller),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.l10n.adminSuspendReasonHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.commonSave),
          ),
        ],
      );
    },
  );
}

Future<String?> _showResetPasswordDialog(
  BuildContext context,
  String suggestedPassword,
) async {
  final controller = TextEditingController(text: suggestedPassword);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.l10n.adminResetSellerPassword),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.l10n.adminPassword),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.commonSave),
          ),
        ],
      );
    },
  );
}

Future<void> _showCredentialsDialog(
  BuildContext context, {
  required String sellerName,
  required String storeName,
  required String email,
  required String password,
}) async {
  final l10n = context.l10n;
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.adminSellerCreatedSuccessfully),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.adminSellerFullName}: $sellerName'),
            Text('${l10n.adminStoreLabel}: $storeName'),
            Text('${l10n.adminSellerEmail}: $email'),
            Text('${l10n.adminPassword}: $password'),
            Text('${l10n.adminRoleLabel}: ${l10n.adminRoleSeller}'),
            const SizedBox(height: 12),
            Text(
              l10n.adminDemoPasswordNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '$email\n$password'));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.adminCredentialsCopied)),
              );
            },
            child: Text(l10n.adminCopyCredentials),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonClose),
          ),
        ],
      );
    },
  );
}
