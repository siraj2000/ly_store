import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import 'notification_bell_button.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title = 'StyleHub',
    this.leading,
    this.actions = const [],
    this.centerTitle = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: AppBar(
        elevation: 0,
        centerTitle: centerTitle,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colors.primaryText,
          ),
        ),
        leading: leading,
        actions: actions,
        backgroundColor: colors.surface,
        foregroundColor: colors.primaryText,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ShopHeaderActions extends StatelessWidget {
  const ShopHeaderActions({super.key, required this.onWishlistTap});

  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NotificationBellButton(),
        IconButton(
          tooltip: context.tr('Wishlist', 'المفضلة'),
          onPressed: onWishlistTap,
          icon: const Icon(Icons.favorite_border),
        ),
        IconButton(
          tooltip: context.tr('Cart', 'السلة'),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    );
  }
}
