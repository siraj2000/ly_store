import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../models/store_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/store_rating_stars.dart';

class AllStoresScreen extends StatefulWidget {
  const AllStoresScreen({super.key});

  @override
  State<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends State<AllStoresScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, _) {
        final stores = productController.publicStores.where((store) {
          final searchable = [
            store.nameText.en,
            store.nameText.ar,
            store.city,
            store.businessActivityType,
            store.addressText.en,
            store.addressText.ar,
          ].join(' ').toLowerCase();
          return searchable.contains(_query.toLowerCase().trim());
        }).toList();

        return Scaffold(
          appBar: AppHeader(title: context.tr('All Stores', 'كل المتاجر')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: context.tr('Search store', 'ابحث عن متجر'),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              ...stores.map(
                (store) => _StoreListCard(
                  store: store,
                  productCount: productController
                      .productsForStore(store.id)
                      .length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreListCard extends StatelessWidget {
  const _StoreListCard({required this.store, required this.productCount});

  final StoreModel store;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.storefront,
          arguments: store.id,
        ),
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          child: Icon(Icons.storefront_outlined, color: colors.icon),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                store.localizedName(locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colors.primaryText,
                ),
              ),
            ),
            if (store.isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr('Featured', 'مميز'),
                  style: TextStyle(
                    color: colors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${store.city}  ·  $productCount ${context.tr('products', 'منتجات')}',
                style: TextStyle(color: colors.secondaryText),
              ),
              const SizedBox(height: 6),
              StoreRatingStars(
                rating: store.rating,
                reviewCount: store.reviewCount,
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: colors.icon,
          size: 16,
        ),
      ),
    );
  }
}
