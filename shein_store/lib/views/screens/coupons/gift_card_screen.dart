import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/app_header.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final walletController = context.watch<WalletController>();
    final transactions = walletController.transactions
        .where((item) => item.type == 'gift_card')
        .toList();

    return Scaffold(
      appBar: AppHeader(title: context.tr('Gift Card', 'بطاقة هدية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      'Add gift card code',
                      'أضف رمز بطاقة الهدية',
                    ),
                    hintText: 'LY25',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _redeem,
                  icon: const Icon(Icons.redeem_outlined),
                  label: Text(context.tr('Redeem', 'استبدال')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GiftInfoCard(
            title: context.tr('Wallet balance', 'رصيد المحفظة'),
            subtitle: formatCurrency(walletController.balance),
          ),
          _GiftInfoCard(
            title: context.tr(
              'Redeemed gift cards',
              'بطاقات الهدايا المستبدلة',
            ),
            subtitle: transactions.isEmpty
                ? context.tr(
                    'Redeemed gift cards will appear here.',
                    'ستظهر بطاقات الهدايا المستبدلة هنا.',
                  )
                : transactions
                      .map(
                        (item) =>
                            '${item.description} • ${formatCurrency(item.amount)}',
                      )
                      .join('\n'),
          ),
          _GiftInfoCard(
            title: context.tr('Demo codes', 'الأكواد التجريبية'),
            subtitle: context.tr(
              'Try LY25, LY50, or LY100 once per app state.',
              'جرّب LY25 أو LY50 أو LY100 مرة واحدة في حالة التطبيق.',
            ),
          ),
        ],
      ),
    );
  }

  void _redeem() {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMessage(
        context.tr('Enter a gift card code', 'أدخل رمز بطاقة الهدية'),
      );
      return;
    }
    final result = context.read<WalletController>().redeemGiftCard(code);
    if (result.isSuccess) {
      _controller.clear();
      _showMessage(context.tr('Gift card redeemed', 'تم استبدال بطاقة الهدية'));
      return;
    }
    _showMessage(_localizedRedeemError(context, result.messageKey));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _localizedRedeemError(BuildContext context, String key) {
  return switch (key) {
    'customer_not_found' => context.tr(
      'Sign in as a customer first',
      'سجل الدخول كعميل أولاً',
    ),
    'empty_code' => context.tr(
      'Enter a gift card code',
      'أدخل رمز بطاقة الهدية',
    ),
    'invalid_code' => context.tr(
      'Invalid gift card code',
      'رمز بطاقة الهدية غير صحيح',
    ),
    'inactive' => context.tr(
      'This gift card is not active',
      'بطاقة الهدية غير مفعلة',
    ),
    'expired' => context.tr(
      'This gift card has expired',
      'انتهت صلاحية بطاقة الهدية',
    ),
    'already_redeemed' => context.tr(
      'This gift card was already redeemed',
      'تم استبدال بطاقة الهدية من قبل',
    ),
    _ => context.tr(
      'Gift card could not be redeemed',
      'تعذر استبدال بطاقة الهدية',
    ),
  };
}

class _GiftInfoCard extends StatelessWidget {
  const _GiftInfoCard({required this.title, required this.subtitle});

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
