import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.oldPrice,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final double price;
  final double? oldPrice;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final alignment = switch (crossAxisAlignment) {
      CrossAxisAlignment.end => WrapAlignment.end,
      CrossAxisAlignment.center => WrapAlignment.center,
      _ => WrapAlignment.start,
    };

    return Wrap(
      alignment: alignment,
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          formatCurrency(price),
          style: TextStyle(
            color: colors.price,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        if (oldPrice != null)
          Text(
            formatCurrency(oldPrice!),
            style: TextStyle(
              color: colors.mutedText,
              decoration: TextDecoration.lineThrough,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
