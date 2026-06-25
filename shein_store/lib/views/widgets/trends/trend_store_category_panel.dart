import 'package:flutter/material.dart';

import '../../../controllers/trend_controller.dart';
import '../../../core/constants/app_colors.dart';

class TrendStoreCategoryPanel extends StatelessWidget {
  const TrendStoreCategoryPanel({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.labelForOption,
    required this.onSelected,
  });

  final String title;
  final List<TrendStoreCategoryOption> options;
  final String selectedId;
  final String Function(TrendStoreCategoryOption option) labelForOption;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.card,
      elevation: 18,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final selected = option.id == selectedId;
                return ChoiceChip(
                  label: Text(labelForOption(option)),
                  selected: selected,
                  onSelected: (_) => onSelected(option.id),
                  selectedColor: colors.accent.withValues(alpha: 0.12),
                  backgroundColor: colors.surfaceSoft,
                  side: BorderSide(
                    color: selected ? colors.accent : colors.border,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? colors.accent : colors.secondaryText,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
