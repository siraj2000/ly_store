import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/payment_method_model.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    this.selected = false,
    this.onTap,
  });

  final PaymentMethodModel method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? colors.primaryText : colors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? colors.surfaceSoft : colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            method.brand.characters.first.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
        ),
        title: Text(
          method.brand,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.primaryText,
          ),
        ),
        subtitle: Text(
          method.maskedNumber,
          style: TextStyle(color: colors.secondaryText, fontSize: 12),
        ),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: colors.primaryText)
            : Icon(Icons.chevron_right_rounded, color: colors.inactiveIcon),
      ),
    );
  }
}
