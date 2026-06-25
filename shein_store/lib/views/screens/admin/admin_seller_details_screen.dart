import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_seller_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/admin_seller_localization_helper.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../widgets/common/app_header.dart';

class AdminSellerDetailsScreen extends StatelessWidget {
  const AdminSellerDetailsScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSellerController>(
      builder: (context, controller, _) {
        final summary = controller.getSellerDetails(sellerId);
        final colors = context.appColors;
        if (summary == null) {
          return Scaffold(
            appBar: AppHeader(title: context.l10n.adminSellerDetails),
            body: Center(
              child: Text(
                localizedAdminSellerMessage(context, 'adminSellerNotFound'),
              ),
            ),
          );
        }

        final store = summary.store;
        return Scaffold(
          appBar: AppHeader(title: context.l10n.adminSellerDetails),
          body: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.user.name,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(summary.user.email),
                    Text(summary.user.phone),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailPill(
                          label: localizedSellerAccountStatusId(
                            context,
                            summary.user.sellerStatus,
                          ),
                        ),
                        if (store != null)
                          _DetailPill(
                            label: localizedBusinessActivity(
                              context,
                              store.businessActivityType,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: context.l10n.adminStoreInformation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: context.l10n.adminStoreLabel,
                      value:
                          store?.nameText.valueFor(
                            Localizations.localeOf(context),
                          ) ??
                          '-',
                    ),
                    _InfoRow(
                      label: context.l10n.adminStorePhone,
                      value: store?.storePhone ?? '-',
                    ),
                    _InfoRow(
                      label: context.l10n.adminStoreAddressEn,
                      value:
                          store?.addressText.valueFor(
                            Localizations.localeOf(context),
                          ) ??
                          '-',
                    ),
                    _InfoRow(
                      label: context.l10n.adminCommissionPercentage,
                      value: store == null
                          ? '-'
                          : '${store.commissionPercentage.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: context.l10n.adminPerformanceSnapshot,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      label: context.l10n.navProducts,
                      value: '${summary.productCount}',
                    ),
                    _MetricCard(
                      label: context.l10n.navOrders,
                      value: '${summary.orderCount}',
                    ),
                    _MetricCard(
                      label: context.l10n.adminTotalSales,
                      value: formatCurrency(context, summary.totalSales),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: context.l10n.adminAuditSummary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: context.l10n.adminCreatedAt,
                      value: formatShortDate(context, summary.user.createdAt),
                    ),
                    _InfoRow(
                      label: context.l10n.adminUpdatedAt,
                      value: formatShortDate(context, summary.user.updatedAt),
                    ),
                    if (summary.user.sellerStatusReason.isNotEmpty)
                      _InfoRow(
                        label: context.l10n.adminSuspendReason,
                        value: summary.user.sellerStatusReason,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.adminEditSeller,
                      arguments: summary.user.id,
                    ),
                    child: Text(context.l10n.commonEdit),
                  ),
                  OutlinedButton(
                    onPressed: store == null
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.adminStoreDetails,
                            arguments: store.id,
                          ),
                    child: Text(context.l10n.adminOpenStore),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 150,
            child: Text(label, style: TextStyle(color: colors.secondaryText)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.secondaryText)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

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
          color: colors.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
