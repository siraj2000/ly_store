import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/config/loyalty_policy.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileController>().user;
    final points = user?.points ?? 0;
    final transactions = user?.pointsTransactions ?? const [];
    return Scaffold(
      appBar: AppHeader(title: context.tr('Points', 'النقاط')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceCard(
            title: context.tr('Points Balance', 'رصيد النقاط'),
            value: '$points',
            icon: Icons.stars_outlined,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: context.tr('Redeem rules', 'قواعد الاستبدال'),
            subtitle: context.tr(
              'Every ${LoyaltyPolicy.pointsPerDiscountUnit} points = 1.00 LYD discount. You can redeem up to 20% of the product subtotal.',
              'كل ${LoyaltyPolicy.pointsPerDiscountUnit} نقطة = خصم 1.00 د.ل. يمكنك استخدام حتى 20% من إجمالي المنتجات.',
            ),
          ),
          if (transactions.isEmpty)
            _InfoCard(
              title: context.tr('Earning history', 'سجل الكسب'),
              subtitle: context.tr(
                'Complete a paid order to earn reward points.',
                'أكمل طلباً مدفوعاً لكسب نقاط المكافآت.',
              ),
            )
          else
            ...transactions.map(
              (transaction) => _InfoCard(
                title: transaction.type == 'earn'
                    ? context.tr('Points earned', 'نقاط مكتسبة')
                    : context.tr('Points redeemed', 'نقاط مستخدمة'),
                subtitle:
                    '${transaction.points > 0 ? '+' : ''}${transaction.points} • ${transaction.description}',
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.discount.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.discount),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
