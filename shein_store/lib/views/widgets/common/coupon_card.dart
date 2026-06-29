import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_copy_helper.dart';
import '../../../models/coupon_model.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({super.key, required this.coupon, this.onTap});

  final CouponModel coupon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final amountLabel = coupon.isPercentage
        ? '${coupon.amount.toInt()}%'
        : '\$${coupon.amount.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 84,
                decoration: BoxDecoration(
                  color: colors.discount.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      amountLabel,
                      style: TextStyle(
                        color: colors.price,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('OFF', 'خصم'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8,
                            end: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                coupon.code,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primaryText,
                                ),
                              ),
                              AppCopyIconButton(
                                text: coupon.code,
                                feedback: context.l10n.copiedCouponCode,
                                tooltip: context.l10n.copy,
                                iconSize: 16,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context.tr(
                            'Min \$${coupon.minimumSpend.toStringAsFixed(0)}',
                            'الحد الأدنى \$${coupon.minimumSpend.toStringAsFixed(0)}',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
