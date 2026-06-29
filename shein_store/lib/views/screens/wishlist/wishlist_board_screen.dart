import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/product_model.dart';
import '../../../models/wishlist_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/product/product_card.dart';

class WishlistBoardScreen extends StatelessWidget {
  const WishlistBoardScreen({super.key, this.boardId});

  final String? boardId;

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistController>(
      builder: (context, wishlistController, _) {
        final board = wishlistController.boardById(boardId);
        if (board == null) {
          return Scaffold(
            appBar: AppHeader(
              title: context.tr('Board Details', 'تفاصيل القائمة'),
            ),
            body: AppEmptyState(
              title: context.tr('Board not found', 'القائمة غير موجودة'),
              message: context.tr(
                'This wishlist board is no longer available.',
                'هذه القائمة لم تعد متاحة.',
              ),
            ),
          );
        }
        final products = wishlistController.productsForBoard(board.id);
        return Scaffold(
          appBar: AppHeader(
            title: board.name,
            actions: [
              IconButton(
                tooltip: context.tr('Board actions', 'إجراءات القائمة'),
                onPressed: () => _showBoardActions(context, board),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          body: products.isEmpty
              ? AppEmptyState(
                  title: context.tr('Empty board', 'القائمة فارغة'),
                  message: context.tr(
                    'Add wishlist products to this board to organize your favorites.',
                    'أضف منتجات المفضلة إلى هذه القائمة لتنظيم اختياراتك.',
                  ),
                  action: AppButton(
                    text: context.tr('Start Shopping', 'ابدأ التسوق'),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.main),
                    isExpanded: false,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width > 720
                        ? 3
                        : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    mainAxisExtent: ProductCard.mainAxisExtentForWidth(
                      (MediaQuery.sizeOf(context).width -
                              (AppSizes.lg * 2) -
                              10) /
                          2,
                      compact: true,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      compact: true,
                      isWishlisted: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: product.id,
                      ),
                      onWishlistTap: () =>
                          _removeFromBoard(context, board, product),
                      onQuickAddTap: () => _quickAdd(context, product),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _quickAdd(BuildContext context, ProductModel product) async {
    final selection = await AppBottomSheet.showVariantSelector(
      context,
      colors: product.colors,
      sizes: product.sizes,
      maxQuantity: product.stock,
    );
    if (!context.mounted || selection == null) {
      return;
    }
    final result = context.read<CartController>().addToCart(
      product,
      selection['color'] as String,
      selection['size'] as String,
      selection['quantity'] as int,
    );
    CartActionFeedbackHelper.show(context, result);
  }

  void _removeFromBoard(
    BuildContext context,
    WishlistBoardModel board,
    ProductModel product,
  ) {
    context.read<WishlistController>().removeFromBoard(board.id, product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('Removed from board', 'تمت الإزالة من القائمة'),
        ),
      ),
    );
  }

  void _showBoardActions(BuildContext context, WishlistBoardModel board) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(context.tr('Rename Board', 'إعادة تسمية القائمة')),
              onTap: () {
                Navigator.pop(sheetContext);
                _showRenameDialog(context, board);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.tr('Delete Board', 'حذف القائمة')),
              subtitle: board.isPrivate
                  ? Text(context.tr('Private board', 'قائمة خاصة'))
                  : null,
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(context.tr('Delete Board?', 'حذف القائمة؟')),
                    content: Text(
                      context.tr(
                        'This board will be removed. Products stay in your wishlist.',
                        'سيتم حذف القائمة فقط وستبقى المنتجات في المفضلة.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(context.tr('Cancel', 'إلغاء')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(context.tr('Delete', 'حذف')),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) {
                  return;
                }
                context.read<WishlistController>().deleteBoard(board.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WishlistBoardModel board,
  ) async {
    final controller = TextEditingController(text: board.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('Rename Board', 'إعادة تسمية القائمة')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: context.tr('Board name', 'اسم القائمة'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () {
              final renamed = context.read<WishlistController>().renameBoard(
                board.id,
                controller.text,
              );
              if (!renamed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'Enter a unique board name',
                        'أدخل اسم قائمة غير مكرر',
                      ),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
            },
            child: Text(context.tr('Save', 'حفظ')),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
