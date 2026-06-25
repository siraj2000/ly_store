import 'package:flutter/material.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/trend_campaign_model.dart';
import 'trend_campaign_carousel.dart';

class TrendHeader extends StatelessWidget {
  const TrendHeader({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.campaigns,
    required this.currentCampaignIndex,
    required this.heroImageUrl,
    required this.shopNowLabel,
    required this.searchExpanded,
    required this.onSearchChanged,
    required this.onWishlistTap,
    required this.onSearchTap,
    required this.onToggleSearch,
    required this.onCampaignPageChanged,
    required this.onCampaignTap,
    required this.productsForCampaign,
  });

  final TextEditingController searchController;
  final String searchHint;
  final List<TrendCampaignModel> campaigns;
  final int currentCampaignIndex;
  final String heroImageUrl;
  final String shopNowLabel;
  final bool searchExpanded;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onWishlistTap;
  final VoidCallback onSearchTap;
  final VoidCallback onToggleSearch;
  final ValueChanged<int> onCampaignPageChanged;
  final ValueChanged<String> onCampaignTap;
  final List<ProductModel> Function(TrendCampaignModel campaign)
  productsForCampaign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: searchExpanded ? 360 : 322,
      child: Stack(
        children: [
          Positioned.fill(
            child: heroImageUrl.isNotEmpty
                ? ProductImage(imageUrl: heroImageUrl, fit: BoxFit.cover)
                : Container(color: const Color(0xFF171F2A)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    const Color(0xFF151C27).withValues(alpha: 0.74),
                    const Color(0xFF0B0F14).withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'trends',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      _HeaderIcon(
                        icon: searchExpanded
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        onTap: onToggleSearch,
                      ),
                      const SizedBox(width: 10),
                      _HeaderIcon(
                        icon: Icons.favorite_border_rounded,
                        onTap: onWishlistTap,
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: !searchExpanded
                        ? const SizedBox(height: 12)
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Container(
                              key: const ValueKey('expanded-search'),
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      onChanged: onSearchChanged,
                                      onSubmitted: (_) => onSearchTap(),
                                      textInputAction: TextInputAction.search,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: searchHint,
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.62,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 13,
                                            ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: onSearchTap,
                                    icon: const Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const Spacer(),
                  TrendCampaignCarousel(
                    campaigns: campaigns,
                    productsForCampaign: productsForCampaign,
                    currentIndex: currentCampaignIndex,
                    shopNowLabel: shopNowLabel,
                    onPageChanged: onCampaignPageChanged,
                    onCampaignTap: onCampaignTap,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
