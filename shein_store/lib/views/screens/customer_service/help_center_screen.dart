import 'package:flutter/material.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      context.tr('Track order', 'تتبع الطلب'),
      context.tr('Cancel order', 'إلغاء الطلب'),
      context.tr('Return/refund', 'إرجاع/استرداد'),
      context.tr('Payment issue', 'مشكلة في الدفع'),
      context.tr('Address issue', 'مشكلة في العنوان'),
      context.tr('Account security', 'أمان الحساب'),
      context.tr('Coupons/points/wallet', 'الكوبونات/النقاط/المحفظة'),
    ];
    return Scaffold(
      appBar: AppHeader(title: context.tr('Help Center', 'مركز المساعدة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...topics.map(
            (topic) => Card(
              child: ListTile(
                title: Text(topic),
                subtitle: Text(
                  context.tr(
                    'Tap for FAQ and support guidance.',
                    'اضغط لعرض الأسئلة الشائعة وإرشادات الدعم.',
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(context.tr('Contact support', 'التواصل مع الدعم')),
            subtitle: Text(
              context.tr(
                'Reach the mock support team for general questions.',
                'تواصل مع فريق الدعم التجريبي للأسئلة العامة.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
