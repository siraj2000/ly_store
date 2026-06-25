import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreRatingStars extends StatelessWidget {
  const StoreRatingStars({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
    this.compact = false,
    this.onChanged,
  });

  final double rating;
  final int? reviewCount;
  final double size;
  final bool compact;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeRating = rating.clamp(0, 5).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Padding(
            padding: EdgeInsetsDirectional.only(end: compact ? 1 : 2),
            child: GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(index + 1),
              child: Icon(
                _iconFor(index, safeRating),
                size: size,
                color: colors.warning,
              ),
            ),
          ),
        if (reviewCount != null) ...[
          SizedBox(width: compact ? 4 : 6),
          Text(
            '${safeRating.toStringAsFixed(1)} (${reviewCount!})',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w700,
              color: colors.primaryText,
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconFor(int index, double value) {
    if (index + 1 <= value.floor()) {
      return Icons.star;
    }
    if (index < value && value - index >= 0.5) {
      return Icons.star_half;
    }
    return Icons.star_border;
  }
}
