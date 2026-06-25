import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';

class CategorySideMenuItemData {
  const CategorySideMenuItemData({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class CategorySideMenu extends StatelessWidget {
  const CategorySideMenu({
    super.key,
    required this.items,
    required this.selectedId,
    required this.isOpen,
    required this.onToggle,
    required this.onSelected,
  });

  final List<CategorySideMenuItemData> items;
  final String selectedId;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final width = isOpen ? 128.0 : 48.0;

    return AnimatedContainer(
      duration: Duration.zero,
      width: width,
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              tooltip: isOpen
                  ? context.tr('Close menu', 'إغلاق القائمة')
                  : context.tr('Open menu', 'فتح القائمة'),
              onPressed: onToggle,
              icon: Icon(
                isOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
                color: colors.primaryText,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedId == item.id;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 6,
                    end: 6,
                    bottom: 4,
                  ),
                  child: InkWell(
                    onTap: () => onSelected(item.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: EdgeInsetsDirectional.only(
                        start: isOpen ? 8 : 0,
                        end: isOpen ? 6 : 0,
                        top: 9,
                        bottom: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: isOpen
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colors.primaryText
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      item.icon,
                                      size: 17,
                                      color: isSelected
                                          ? colors.primaryText
                                          : colors.inactiveIcon,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 9,
                                  ),
                                  child: Text(
                                    item.label,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      height: 1.15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primaryText
                                          : colors.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Icon(
                                item.icon,
                                size: 17,
                                color: isSelected
                                    ? colors.primaryText
                                    : colors.inactiveIcon,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
