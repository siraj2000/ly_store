import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class TrendFilterChips extends StatelessWidget {
  const TrendFilterChips({
    super.key,
    required this.labels,
    required this.selectedId,
    required this.labelForId,
    required this.onSelected,
    required this.onOpenFilter,
  });

  final List<String> labels;
  final String selectedId;
  final String Function(String id) labelForId;
  final ValueChanged<String> onSelected;
  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == labels.length) {
            return _FilterActionChip(
              icon: Icons.tune_rounded,
              onTap: onOpenFilter,
              colors: colors,
            );
          }
          final id = labels[index];
          final selected = id == selectedId;
          return _TrendTextChip(
            label: labelForId(id),
            selected: selected,
            colors: colors,
            onTap: () => onSelected(id),
          );
        },
      ),
    );
  }
}

class _TrendTextChip extends StatelessWidget {
  const _TrendTextChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppThemeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colors.accent.withValues(alpha: 0.12)
          : colors.surfaceSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? colors.accent : colors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterActionChip extends StatelessWidget {
  const _FilterActionChip({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surfaceSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          child: Icon(icon, color: colors.primaryText, size: 20),
        ),
      ),
    );
  }
}
