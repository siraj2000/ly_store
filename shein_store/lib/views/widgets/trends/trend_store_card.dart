import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/store_model.dart';
import '../../../models/trend_store_section_model.dart';

class TrendStoreCard extends StatelessWidget {
  const TrendStoreCard({
    super.key,
    required this.store,
    required this.section,
    required this.hashtags,
    required this.products,
    required this.newLabel,
    required this.trendingLabel,
    required this.followersLabel,
    required this.soldLabel,
    required this.viewStoreLabel,
    required this.onStoreTap,
    required this.onProductTap,
  });

  final StoreModel store;
  final TrendStoreSectionModel section;
  final List<String> hashtags;
  final List<ProductModel> products;
  final String newLabel;
  final String trendingLabel;
  final String followersLabel;
  final String soldLabel;
  final String viewStoreLabel;
  final VoidCallback onStoreTap;
  final ValueChanged<ProductModel> onProductTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final soldCount = products.fold<int>(
      0,
      (sum, item) => sum + item.soldCount,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onStoreTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.border.withValues(alpha: 0.65)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      store.localizedName(locale).substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              store.localizedName(locale),
                              style: TextStyle(
                                color: colors.primaryText,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (section.isNew)
                              _MiniBadge(label: newLabel, color: colors.info),
                            if (section.isTrending)
                              _MiniBadge(
                                label: trendingLabel,
                                color: colors.accent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hashtags.take(3).join('   '),
                          maxLines: 1,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatText(
                    text: '${store.rating.toStringAsFixed(1)} ★',
                    color: colors.warning,
                  ),
                  const SizedBox(width: 10),
                  _StatText(
                    text: '${store.followersCount} $followersLabel',
                    color: colors.secondaryText,
                  ),
                  const SizedBox(width: 10),
                  _StatText(
                    text: '$soldCount $soldLabel',
                    color: colors.secondaryText,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: Row(
                  children: products.take(4).map((product) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () => onProductTap(product),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ProductImage(
                                    imageUrl: product.imageUrl ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.primaryText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (section.reviewPreviewText != null) ...[
                const SizedBox(height: 10),
                Text(
                  section.reviewPreviewText!.valueFor(locale),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  const _StatText({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}
