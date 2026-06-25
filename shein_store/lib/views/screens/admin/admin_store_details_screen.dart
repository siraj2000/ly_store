import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_seller_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../widgets/common/app_header.dart';

class AdminStoreDetailsScreen extends StatelessWidget {
  const AdminStoreDetailsScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSellerController>(
      builder: (context, controller, _) {
        final colors = context.appColors;
        final matches = controller.stores.where((store) => store.id == storeId);
        final store = matches.isEmpty ? null : matches.first;
        if (store == null) {
          return Scaffold(
            appBar: AppHeader(title: context.l10n.adminStoreDetails),
            body: Center(child: Text(context.l10n.adminStoreNotFound)),
          );
        }
        return Scaffold(
          appBar: AppHeader(title: context.l10n.adminStoreDetails),
          body: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            children: [
              _StoreInfoCard(
                title: store.nameText.valueFor(Localizations.localeOf(context)),
                subtitle: localizedBusinessActivity(
                  context,
                  store.businessActivityType,
                ),
              ),
              const SizedBox(height: 16),
              _Block(
                title: context.l10n.adminStoreInformation,
                children: [
                  _RowItem(
                    label: context.l10n.adminStorePhone,
                    value: store.storePhone,
                  ),
                  _RowItem(label: context.l10n.adminCity, value: store.city),
                  _RowItem(
                    label: context.l10n.adminCountry,
                    value: store.countryCode,
                  ),
                  _RowItem(
                    label: context.l10n.adminStoreAddressEn,
                    value: store.addressText.valueFor(
                      Localizations.localeOf(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Block(
                title: context.l10n.adminStoreSettings,
                children: [
                  _RowItem(
                    label: context.l10n.adminCommissionPercentage,
                    value: '${store.commissionPercentage.toStringAsFixed(0)}%',
                  ),
                  _RowItem(
                    label: context.l10n.adminStoreActive,
                    value: store.isActive
                        ? context.l10n.adminStatusActive
                        : context.l10n.adminStoreInactive,
                  ),
                  _RowItem(
                    label: context.l10n.adminVerifiedStore,
                    value: store.isVerified
                        ? context.l10n.commonDone
                        : context.l10n.commonCancel,
                  ),
                  _RowItem(
                    label: context.l10n.adminFeaturedStore,
                    value: store.isFeatured
                        ? context.l10n.commonDone
                        : context.l10n.commonCancel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Block(
                title: context.l10n.adminAllowedCategories,
                children: [
                  if (store.allowedCategoryIds.isEmpty)
                    Text(
                      context.l10n.adminAllCategoriesAllowed,
                      style: TextStyle(color: colors.secondaryText),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: store.allowedCategoryIds
                          .map(
                            (id) => Chip(
                              label: Text(id),
                              backgroundColor: colors.surfaceSoft,
                            ),
                          )
                          .toList(),
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

class _StoreInfoCard extends StatelessWidget {
  const _StoreInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: colors.secondaryText)),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
          ...children,
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.label, required this.value});

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
              value.isEmpty ? '-' : value,
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
