import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

class GiftCardScreen extends StatelessWidget {
  const GiftCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: context.tr(
                      'Add gift card code',
                      'أضف رمز بطاقة الهدية',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GiftInfoCard(
            title: context.tr('Balance list', 'قائمة الرصيد'),
            subtitle: context.tr(
              'Saved gift cards will appear here.',
              'ستظهر بطاقات الهدايا المحفوظة هنا.',
            ),
          ),
          _GiftInfoCard(
            title: context.tr('History', 'السجل'),
            subtitle: context.tr(
              'Usage history is available after real integration.',
              'سجل الاستخدام يتوفر بعد إضافة التكامل الحقيقي.',
            ),
          ),
        ],
      ),
    );
  }
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
