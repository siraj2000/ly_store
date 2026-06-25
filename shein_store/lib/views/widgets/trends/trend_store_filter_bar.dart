import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class TrendStoreFilterBar extends StatelessWidget {
  const TrendStoreFilterBar({
    super.key,
    required this.categoryLabel,
    required this.selectedCategoryLabel,
    required this.newLabel,
    required this.isNewOnly,
    required this.onCategoryTap,
    required this.onNewTap,
  });

  final String categoryLabel;
  final String selectedCategoryLabel;
  final String newLabel;
  final bool isNewOnly;
  final VoidCallback onCategoryTap;
  final VoidCallback onNewTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCategoryTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.border),
              backgroundColor: colors.surfaceSoft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.primaryText,
            ),
            label: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '$categoryLabel: $selectedCategoryLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: Text(newLabel),
          selected: isNewOnly,
          onSelected: (_) => onNewTap(),
          selectedColor: colors.accent.withValues(alpha: 0.12),
          backgroundColor: colors.surfaceSoft,
          side: BorderSide(color: isNewOnly ? colors.accent : colors.border),
          labelStyle: TextStyle(
            color: isNewOnly ? colors.accent : colors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
