import 'package:flutter/material.dart';

import '../../../controllers/trend_controller.dart';
import '../../../core/constants/app_colors.dart';

class TrendMainTabs extends StatelessWidget {
  const TrendMainTabs({
    super.key,
    required this.selectedTab,
    required this.trendingPicksLabel,
    required this.trendsStoreLabel,
    required this.onSelected,
  });

  final TrendMainTab selectedTab;
  final String trendingPicksLabel;
  final String trendsStoreLabel;
  final ValueChanged<TrendMainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: _TrendTabButton(
            label: trendingPicksLabel,
            selected: selectedTab == TrendMainTab.trendingPicks,
            onTap: () => onSelected(TrendMainTab.trendingPicks),
            colors: colors,
          ),
        ),
        Expanded(
          child: _TrendTabButton(
            label: trendsStoreLabel,
            selected: selectedTab == TrendMainTab.trendsStore,
            onTap: () => onSelected(TrendMainTab.trendsStore),
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _TrendTabButton extends StatelessWidget {
  const _TrendTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? colors.primaryText : colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: selected ? 92 : 0,
              decoration: BoxDecoration(
                color: selected ? colors.primaryText : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
