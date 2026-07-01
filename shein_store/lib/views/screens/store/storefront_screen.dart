import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/store_review_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/notification_model.dart';
import '../../../models/store_review_model.dart';
import '../../../models/user_role.dart';
import '../../../services/mock_data_service.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/store_rating_stars.dart';
import '../../widgets/product/product_card.dart';

class StorefrontScreen extends StatefulWidget {
  const StorefrontScreen({super.key, required this.storeId});

  final String storeId;

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<StoreReviewController>().loadStoreReviews(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      ProductController,
      WishlistController,
      StoreReviewController,
      AuthController
    >(
      builder:
          (
            context,
            productController,
            wishlistController,
            reviewController,
            authController,
            _,
          ) {
            final colors = context.appColors;
            final locale = Localizations.localeOf(context);
            final store = productController.storeById(widget.storeId);
            if (store == null) {
              return Scaffold(
                appBar: AppHeader(
                  title: context.tr('Storefront', 'واجهة المتجر'),
                ),
                body: AppEmptyState(
                  title: context.tr('Store unavailable', 'المتجر غير متاح'),
                  message: context.tr(
                    'This store could not be found.',
                    'تعذر العثور على هذا المتجر.',
                  ),
                ),
              );
            }

            final products = productController.productsForStore(store.id).where(
              (product) {
                if (_query.trim().isEmpty) {
                  return true;
                }
                final text = [
                  product.title,
                  product.titleText.en,
                  product.titleText.ar,
                  product.description,
                  product.descriptionText.en,
                  product.descriptionText.ar,
                ].join(' ').toLowerCase();
                return text.contains(_query.toLowerCase().trim());
              },
            ).toList();

            return Scaffold(
              appBar: AppHeader(title: store.localizedName(locale)),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: context.isDarkMode
                            ? const [
                                Color(0xFF16202B),
                                Color(0xFF2A3D52),
                                Color(0xFF5A4151),
                              ]
                            : const [
                                Color(0xFF171717),
                                Color(0xFF48627D),
                                Color(0xFFB66761),
                              ],
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
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          store.localizedName(locale),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      if (store.isVerified)
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  StoreRatingStars(
                                    rating: store.rating,
                                    reviewCount: store.reviewCount,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          store.localizedDescription(locale),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StoreInfoPill(
                              label: store.localizedAddress(locale),
                              icon: Icons.location_on_outlined,
                            ),
                            _StoreInfoPill(
                              label: store.storePhone,
                              icon: Icons.call_outlined,
                            ),
                            _StoreInfoPill(
                              label: localizedBusinessActivity(
                                context,
                                store.businessActivityType,
                              ),
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: context.tr('Search store', 'ابحث داخل المتجر'),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        context.tr('Store Products', 'منتجات المتجر'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colors.primaryText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${products.length}',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 10.0;
                      final cardWidth = (constraints.maxWidth - spacing) / 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: spacing,
                          mainAxisExtent: ProductCard.mainAxisExtentForWidth(
                            cardWidth,
                            compact: true,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            compact: true,
                            isWishlisted: wishlistController.isWishlisted(
                              product.id,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: product.id,
                            ),
                            onWishlistTap: () =>
                                wishlistController.toggleWishlist(product),
                            onQuickAddTap: () async {
                              final selection =
                                  await AppBottomSheet.showVariantSelector(
                                    context,
                                    colors: product.colors,
                                    sizes: product.sizes,
                                    variants: product.variants,
                                    maxQuantity: product.stock,
                                  );
                              if (!context.mounted || selection == null) {
                                return;
                              }
                              final result = context
                                  .read<CartController>()
                                  .addToCart(
                                    product,
                                    selection['color'] as String,
                                    selection['size'] as String,
                                    selection['quantity'] as int,
                                  );
                              CartActionFeedbackHelper.show(context, result);
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final rateButton = FilledButton.tonal(
                        onPressed: () => _openRatingFlow(
                          context,
                          storeId: store.id,
                          sellerId: store.sellerId,
                          authController: authController,
                          reviewController: reviewController,
                          mockDataService: context.read<MockDataService>(),
                        ),
                        child: Text(context.tr('Rate Store', 'قيّم المتجر')),
                      );

                      if (constraints.maxWidth < 430) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('Store Reviews', 'تقييمات المتجر'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 12),
                            rateButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('Store Reviews', 'تقييمات المتجر'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colors.primaryText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          rateButton,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (reviewController.reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        context.tr('No reviews yet', 'لا توجد تقييمات بعد'),
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    )
                  else
                    ...reviewController.reviews.map((review) {
                      final author =
                          context
                              .read<MockDataService>()
                              .userById(review.customerId)
                              ?.name ??
                          context.tr('Customer', 'عميل');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    author,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: colors.primaryText,
                                    ),
                                  ),
                                ),
                                StoreRatingStars(
                                  rating: review.rating.toDouble(),
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (review.verifiedPurchase)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  context.tr('Verified Purchase', 'شراء موثق'),
                                  style: TextStyle(
                                    color: colors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            Text(
                              review.comment,
                              style: TextStyle(
                                color: colors.secondaryText,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
    );
  }

  Future<void> _openRatingFlow(
    BuildContext context, {
    required String storeId,
    required String sellerId,
    required AuthController authController,
    required StoreReviewController reviewController,
    required MockDataService mockDataService,
  }) async {
    if (authController.isGuest) {
      AppBottomSheet.showAuthRequired(context);
      return;
    }
    final customer = authController.currentUser;
    if (customer == null || customer.role != UserRole.customer) {
      return;
    }
    final eligibleOrders = mockDataService.sellerOrders.where(
      (order) =>
          order.customerId == customer.id &&
          order.storeId == storeId &&
          (order.status == 'Delivered' || order.status == 'Review'),
    );
    if (eligibleOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'A completed purchase is required before rating this store.',
              'يجب إكمال عملية شراء قبل تقييم هذا المتجر.',
            ),
          ),
        ),
      );
      return;
    }
    final eligibleOrder = eligibleOrders.first;
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        var rating = 5;
        final commentController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.tr('Rate Store', 'قيّم المتجر')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StoreRatingStars(
                    rating: rating.toDouble(),
                    onChanged: (value) => setState(() => rating = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'Share a quick comment',
                        'أضف تعليقاً سريعاً',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.tr('Cancel', 'إلغاء')),
                ),
                FilledButton(
                  onPressed: () async {
                    final review = StoreReviewModel(
                      id: 'store_review_${storeId}_${eligibleOrder.masterOrderId}_${customer.id}',
                      storeId: storeId,
                      sellerId: sellerId,
                      customerId: customer.id,
                      orderId: eligibleOrder.masterOrderId,
                      rating: rating,
                      comment: commentController.text.trim(),
                      verifiedPurchase: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    await reviewController.submitStoreReview(review);
                    if (!context.mounted) {
                      return;
                    }
                    context.read<NotificationController>().createForUser(
                      NotificationModel(
                        id: 'notif_store_review_${review.id}',
                        recipientUserId: sellerId,
                        recipientRole: UserRole.seller,
                        type: NotificationType.storeReviewed,
                        entityType: 'storeReview',
                        entityId: review.id,
                        route: AppRoutes.storefront,
                        data: {'storeId': storeId},
                        createdAt: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(context.tr('Submit', 'إرسال')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StoreInfoPill extends StatelessWidget {
  const _StoreInfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
