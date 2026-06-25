import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.label,
    this.height,
    this.width,
    this.radius = AppSizes.radius,
  });

  final String label;
  final double? height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final icon = _iconForLabel(label);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [colors.surfaceSoft, colors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -8,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? colors.background.withValues(alpha: 0.28)
                    : colors.surfaceSoft,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 18,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: colors.background.withValues(
                      alpha: context.isDarkMode ? 0.22 : 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: colors.icon, size: 22),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? colors.border
                    : colors.border.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final value = label.toLowerCase();
    if (value.contains('shoe')) return Icons.shopping_bag_outlined;
    if (value.contains('bag')) return Icons.work_outline;
    if (value.contains('beauty')) return Icons.spa_outlined;
    if (value.contains('dress')) return Icons.checkroom_outlined;
    if (value.contains('home')) return Icons.chair_outlined;
    return Icons.checkroom_rounded;
  }
}
