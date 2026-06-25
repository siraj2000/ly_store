import 'package:flutter/material.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/trend_campaign_model.dart';

class TrendCampaignCarousel extends StatefulWidget {
  const TrendCampaignCarousel({
    super.key,
    required this.campaigns,
    required this.productsForCampaign,
    required this.currentIndex,
    required this.shopNowLabel,
    required this.onPageChanged,
    required this.onCampaignTap,
  });

  final List<TrendCampaignModel> campaigns;
  final List<ProductModel> Function(TrendCampaignModel campaign)
  productsForCampaign;
  final int currentIndex;
  final String shopNowLabel;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onCampaignTap;

  @override
  State<TrendCampaignCarousel> createState() => _TrendCampaignCarouselState();
}

class _TrendCampaignCarouselState extends State<TrendCampaignCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void didUpdateWidget(covariant TrendCampaignCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 198,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.campaigns.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final campaign = widget.campaigns[index];
              final previewProducts = widget
                  .productsForCampaign(campaign)
                  .take(3)
                  .toList();
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  end: index == widget.campaigns.length - 1 ? 0 : 12,
                ),
                child: InkWell(
                  onTap: () => widget.onCampaignTap(campaign.id),
                  borderRadius: BorderRadius.circular(22),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5D463C).withValues(alpha: 0.72),
                          const Color(0xFF241D22).withValues(alpha: 0.82),
                          const Color(0xFF171D28).withValues(alpha: 0.90),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              campaign.hashtag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.36),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${index + 1}/${widget.campaigns.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.titleText.valueFor(
                                  Localizations.localeOf(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                campaign.subtitleText.valueFor(
                                  Localizations.localeOf(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 92,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: previewProducts.map((
                                          product,
                                        ) {
                                          return Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.only(
                                                    end: 6,
                                                  ),
                                              child: _CampaignPreviewCard(
                                                product: product,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.bottomEnd,
                                        child: SizedBox(
                                          height: 40,
                                          child: FilledButton(
                                            onPressed: () => widget
                                                .onCampaignTap(campaign.id),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(
                                                0xFF111827,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                            ),
                                            child: Text(
                                              widget.shopNowLabel,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.campaigns.length, (index) {
            final selected = index == widget.currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 22 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CampaignPreviewCard extends StatelessWidget {
  const _CampaignPreviewCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
