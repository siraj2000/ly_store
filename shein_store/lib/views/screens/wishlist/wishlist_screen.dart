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
        appBar: AppHeader(title: context.tr('Wishlist', 'المفضلة')),
        body: AppEmptyState(
          title: context.tr(
            'Sign in to use wishlist',
            'سجل الدخول لاستخدام المفضلة',
          ),
          message: context.tr(
            'Save favorites, organize boards, and track price drops after you sign in.',
            'احفظ المفضلة ونظم القوائم وتابع انخفاض الأسعار بعد تسجيل الدخول.',
          ),
          action: AppButton(
            text: context.tr('Sign In', 'تسجيل الدخول'),
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
          appBar: AppHeader(title: context.tr('Wishlist', 'المفضلة')),
          body: Column(
            children: [
              TabBar(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(text: context.tr('Items', 'المنتجات')),
                  Tab(text: context.tr('Boards', 'القوائم')),
                  Tab(text: context.tr('Price Drops', 'انخفاض الأسعار')),
                  Tab(text: context.tr('Back in Stock', 'عاد للمخزون')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    wishlistController.wishlistProducts.isEmpty
                        ? AppEmptyState(
                            title: context.tr(
                              'Your wishlist is empty',
                              'قائمة المفضلة فارغة',
                            ),
                            message: context.tr(
                              'Save styles you love to find them faster later.',
                              'احفظ المنتجات التي تعجبك للوصول إليها بسرعة لاحقاً.',
                            ),
                            action: AppButton(
                              text: context.tr('Start Shopping', 'ابدأ التسوق'),
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
                            title: context.tr('Boards', 'القوائم'),
                            actionLabel: context.tr(
                              'Create Board',
                              'إنشاء قائمة',
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
                                    '${board.productIds.length} منتجات',
                                  ),
                                ),
                                trailing: Icon(
                                  Directionality.of(context) ==
                                          TextDirection.rtl
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                ),
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
                        'لا توجد انخفاضات أسعار بعد',
                      ),
                      message: context.tr(
                        'We will flag favorites as soon as prices move.',
                        'سنقوم بتنبيهك عند تغير أسعار المفضلة.',
                      ),
                    ),
                    AppEmptyState(
                      title: context.tr(
                        'No restock alerts yet',
                        'لا توجد تنبيهات إعادة تخزين بعد',
                      ),
                      message: context.tr(
                        'Items that return to stock will appear here.',
                        'ستظهر هنا المنتجات التي عادت إلى المخزون.',
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
              context.tr('Create board', 'إنشاء قائمة'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.lg),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: context.tr('Board name', 'اسم القائمة'),
              ),
            ),
            SwitchListTile(
              value: isPrivate,
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Private board', 'قائمة خاصة')),
              onChanged: (value) => setState(() => isPrivate = value),
            ),
            AppButton(
              text: context.tr('Create', 'إنشاء'),
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
