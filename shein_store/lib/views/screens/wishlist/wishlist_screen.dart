import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/product/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    if (authController.isGuest) {
      return Scaffold(
        appBar: AppHeader(title: context.tr('Wishlist', 'Ø§Ù„Ù…ÙØ¶Ù„Ø©')),
        body: AppEmptyState(
          title: context.tr(
            'Sign in to use wishlist',
            'Ø³Ø¬Ù„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ù„Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ù…ÙØ¶Ù„Ø©',
          ),
          message: context.tr(
            'Save favorites, organize boards, and track price drops after you sign in.',
            'Ø§Ø­ÙØ¸ Ø§Ù„Ù…ÙØ¶Ù„Ø© ÙˆÙ†Ø¸Ù… Ø§Ù„Ù‚ÙˆØ§Ø¦Ù… ÙˆØªØ§Ø¨Ø¹ Ø§Ù†Ø®ÙØ§Ø¶ Ø§Ù„Ø£Ø³Ø¹Ø§Ø± Ø¨Ø¹Ø¯ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„.',
          ),
          action: AppButton(
            text: context.tr('Sign In', 'ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„'),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            isExpanded: false,
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 4,
      child: Consumer<WishlistController>(
        builder: (context, wishlistController, _) => Scaffold(
          appBar: AppHeader(title: context.tr('Wishlist', 'Ø§Ù„Ù…ÙØ¶Ù„Ø©')),
          body: Column(
            children: [
              TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(text: context.tr('Items', 'Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª')),
                  Tab(text: context.tr('Boards', 'Ø§Ù„Ù‚ÙˆØ§Ø¦Ù…')),
                  Tab(
                    text: context.tr(
                      'Price Drops',
                      'Ø§Ù†Ø®ÙØ§Ø¶ Ø§Ù„Ø£Ø³Ø¹Ø§Ø±',
                    ),
                  ),
                  Tab(
                    text: context.tr('Back in Stock', 'Ø¹Ø§Ø¯ Ù„Ù„Ù…Ø®Ø²ÙˆÙ†'),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    wishlistController.wishlistProducts.isEmpty
                        ? AppEmptyState(
                            title: context.tr(
                              'Your wishlist is empty',
                              'Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„Ù…ÙØ¶Ù„Ø© ÙØ§Ø±ØºØ©',
                            ),
                            message: context.tr(
                              'Save styles you love to find them faster later.',
                              'Ø§Ø­ÙØ¸ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª Ø§Ù„ØªÙŠ ØªØ¹Ø¬Ø¨Ùƒ Ù„Ù„ÙˆØµÙˆÙ„ Ø¥Ù„ÙŠÙ‡Ø§ Ø¨Ø³Ø±Ø¹Ø© Ù„Ø§Ø­Ù‚Ø§Ù‹.',
                            ),
                            action: AppButton(
                              text: context.tr(
                                'Start Shopping',
                                'Ø§Ø¨Ø¯Ø£ Ø§Ù„ØªØ³ÙˆÙ‚',
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.main),
                              isExpanded: false,
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              const spacing = 10.0;
                              final cardWidth =
                                  (constraints.maxWidth -
                                      AppSizes.lg * 2 -
                                      spacing) /
                                  2;
                              return GridView.builder(
                                padding: const EdgeInsets.all(AppSizes.lg),
                                itemCount:
                                    wishlistController.wishlistProducts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent:
                                          ProductCard.mainAxisExtentForWidth(
                                            cardWidth,
                                            compact: true,
                                          ),
                                    ),
                                itemBuilder: (context, index) {
                                  final product = wishlistController
                                      .wishlistProducts[index];
                                  return ProductCard(
                                    product: product,
                                    compact: true,
                                    isWishlisted: true,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.productDetails,
                                      arguments: product.id,
                                    ),
                                    onWishlistTap: () => wishlistController
                                        .removeFromWishlist(product.id),
                                    onQuickAddTap: () async {
                                      final selection =
                                          await AppBottomSheet.showVariantSelector(
                                            context,
                                            colors: product.colors,
                                            sizes: product.sizes,
                                            maxQuantity: product.stock,
                                          );
                                      if (!context.mounted ||
                                          selection == null) {
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
                                      CartActionFeedbackHelper.show(
                                        context,
                                        result,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: context.tr('Boards', 'Ø§Ù„Ù‚ÙˆØ§Ø¦Ù…'),
                            actionLabel: context.tr(
                              'Create Board',
                              'Ø¥Ù†Ø´Ø§Ø¡ Ù‚Ø§Ø¦Ù…Ø©',
                            ),
                            onActionTap: () => _showCreateBoard(context),
                          ),
                          const SizedBox(height: AppSizes.md),
                          ...wishlistController.boards.map(
                            (board) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: context.appColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.appColors.border,
                                ),
                              ),
                              child: ListTile(
                                title: Text(board.name),
                                subtitle: Text(
                                  context.tr(
                                    '${board.productIds.length} items',
                                    '${board.productIds.length} Ù…Ù†ØªØ¬Ø§Øª',
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.wishlistBoard,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppEmptyState(
                      title: context.tr(
                        'No price drops yet',
                        'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø§Ù†Ø®ÙØ§Ø¶Ø§Øª Ø£Ø³Ø¹Ø§Ø± Ø¨Ø¹Ø¯',
                      ),
                      message: context.tr(
                        'We will flag favorites as soon as prices move.',
                        'Ø³Ù†Ù‚ÙˆÙ… Ø¨ØªÙ†Ø¨ÙŠÙ‡Ùƒ Ø¹Ù†Ø¯ ØªØºÙŠØ± Ø£Ø³Ø¹Ø§Ø± Ø§Ù„Ù…ÙØ¶Ù„Ø©.',
                      ),
                    ),
                    AppEmptyState(
                      title: context.tr(
                        'No restock alerts yet',
                        'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªÙ†Ø¨ÙŠÙ‡Ø§Øª Ø¥Ø¹Ø§Ø¯Ø© ØªØ®Ø²ÙŠÙ† Ø¨Ø¹Ø¯',
                      ),
                      message: context.tr(
                        'Items that return to stock will appear here.',
                        'Ø³ØªØ¸Ù‡Ø± Ù‡Ù†Ø§ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª Ø§Ù„ØªÙŠ Ø¹Ø§Ø¯Øª Ø¥Ù„Ù‰ Ø§Ù„Ù…Ø®Ø²ÙˆÙ†.',
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
  }

  void _showCreateBoard(BuildContext context) {
    final controller = TextEditingController();
    bool isPrivate = false;
    AppBottomSheet.show(
      context,
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('Create board', 'Ø¥Ù†Ø´Ø§Ø¡ Ù‚Ø§Ø¦Ù…Ø©'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.lg),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: context.tr('Board name', 'Ø§Ø³Ù… Ø§Ù„Ù‚Ø§Ø¦Ù…Ø©'),
              ),
            ),
            SwitchListTile(
              value: isPrivate,
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Private board', 'Ù‚Ø§Ø¦Ù…Ø© Ø®Ø§ØµØ©')),
              onChanged: (value) => setState(() => isPrivate = value),
            ),
            AppButton(
              text: context.tr('Create', 'Ø¥Ù†Ø´Ø§Ø¡'),
              onPressed: () {
                context.read<WishlistController>().createBoard(
                  controller.text.trim(),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
