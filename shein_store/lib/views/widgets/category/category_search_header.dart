import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CategorySearchHeader extends StatelessWidget {
  const CategorySearchHeader({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onNotificationsTap,
    required this.onCameraTap,
    required this.onSearchTap,
    required this.onWishlistTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCameraTap;
  final VoidCallback onSearchTap;
  final VoidCallback onWishlistTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onChanged: onChanged,
                    onSubmitted: (_) => onSearchTap(),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: colors.secondaryText),
                    ),
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onCameraTap,
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 42,
          width: 52,
          child: FilledButton(
            onPressed: onSearchTap,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onWishlistTap,
          icon: const Icon(Icons.favorite_border_rounded),
        ),
      ],
    );
  }
}
