import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class TrendFilterPanel extends StatelessWidget {
  const TrendFilterPanel({
    super.key,
    required this.title,
    required this.closeLabel,
    required this.selectedId,
    required this.options,
    required this.labelForId,
    required this.onSelected,
    required this.onClose,
  });

  final String title;
  final String closeLabel;
  final String selectedId;
  final List<String> options;
  final String Function(String id) labelForId;
  final ValueChanged<String> onSelected;
  final VoidCallback onClose;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.primaryText,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: closeLabel,
                  onPressed: onClose,
                  icon: Icon(Icons.close_rounded, color: colors.primaryText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((id) {
                final selected = id == selectedId;
                return ChoiceChip(
                  label: Text(labelForId(id)),
                  selected: selected,
                  onSelected: (_) => onSelected(id),
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? colors.accent : colors.secondaryText,
                  ),
                  side: BorderSide(
                    color: selected ? colors.accent : colors.border,
                  ),
                  selectedColor: colors.accent.withValues(alpha: 0.12),
                  backgroundColor: colors.surfaceSoft,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
