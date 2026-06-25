import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final items = [
      _NavItemData(
        label: context.l10n.navShop,
        icon: Icons.storefront_outlined,
      ),
      _NavItemData(
        label: context.l10n.navCategory,
        icon: Icons.grid_view_outlined,
      ),
      _NavItemData(
        label: context.l10n.navTrends,
        icon: Icons.auto_awesome_outlined,
      ),
      _NavItemData(
        label: context.l10n.navCart,
        icon: Icons.shopping_bag_outlined,
      ),
      _NavItemData(label: context.l10n.navProfile, icon: Icons.person_outline),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bottomNav,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62 + bottomInset.clamp(0, 10),
          child: Row(
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: _BottomNavItem(
                  item: items[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItemData item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = isActive ? colors.primaryText : colors.inactiveIcon;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isActive ? colors.primaryText : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Icon(item.icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
