import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/app_header.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = context.watch<WalletController>();
    return Scaffold(
      appBar: AppHeader(title: context.tr('Wallet', 'المحفظة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceCard(
            title: context.tr('Wallet Balance', 'رصيد المحفظة'),
            value: formatCurrency(walletController.balance),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          ...walletController.transactions.map(
            (transaction) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: context.appColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.border),
              ),
              child: ListTile(
                title: Text(
                  transaction.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${transaction.type} • ${transaction.status}'),
                trailing: Text(
                  formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: transaction.amount < 0
                        ? context.appColors.discount
                        : context.appColors.success,
                  ),
                ),
              ),
            ),
          ),
          _InfoCard(
            title: context.tr(
              'Withdrawals require payout setup',
              'السحب يحتاج إعداد الدفع',
            ),
            subtitle: context.tr(
              'Withdrawals require a real payment integration.',
              'السحب يحتاج إلى تكامل دفع حقيقي.',
            ),
          ),
          _InfoCard(
            title: context.tr('Add funds disabled', 'إضافة الرصيد غير مفعلة'),
            subtitle: context.tr(
              'Real wallet funding requires a connected payment provider before launch.',
              'شحن المحفظة الحقيقي يحتاج إلى مزود دفع متصل قبل الإطلاق.',
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
              color: colors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.icon),
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
