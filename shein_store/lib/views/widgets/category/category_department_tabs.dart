import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CategoryDepartmentTabData {
  const CategoryDepartmentTabData({required this.id, required this.label});

  final String id;
  final String label;
}

class CategoryDepartmentTabs extends StatelessWidget {
  const CategoryDepartmentTabs({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryDepartmentTabData> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedId == tab.id;
          return InkWell(
            onTap: () => onSelected(tab.id),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: isSelected ? 20 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.primaryText,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
