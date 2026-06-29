import 'package:flutter/material.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

import '../../../core/constants/app_routes.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key, this.orderId});

  final String? orderId;

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
          if (orderId != null && orderId!.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(
                  context.tr(
                    'Related order: #$orderId',
                    'الطلب المرتبط: #$orderId',
                  ),
                ),
              ),
            ),
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
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showTopic(context, topic),
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
            trailing: const Icon(Icons.support_agent_outlined),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.liveChat,
              arguments: orderId,
            ),
          ),
        ],
      ),
    );
  }

  void _showTopic(BuildContext context, String topic) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'This demo help topic explains the next steps locally. For real accounts, this can connect to an FAQ API or ticket system.',
                  'يوضح هذا الموضوع التجريبي الخطوات محلياً. في الحسابات الحقيقية يمكن ربطه بواجهة أسئلة شائعة أو نظام تذاكر.',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.liveChat,
                    arguments: orderId,
                  );
                },
                child: Text(context.tr('Contact support', 'التواصل مع الدعم')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
