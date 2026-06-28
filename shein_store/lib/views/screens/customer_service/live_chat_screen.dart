import 'package:flutter/material.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../widgets/common/app_header.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: context.tr('Live Chat', 'الدردشة المباشرة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Chip(
              label: Text(
                context.tr(
                  'Support: Hi! What can we help with today?',
                  'الدعم: مرحباً! كيف يمكننا مساعدتك اليوم؟',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Chip(
              label: Text(
                context.tr(
                  'Customer: I need help with sizing.',
                  'العميل: أحتاج مساعدة في المقاسات.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Chip(
              label: Text(
                context.tr(
                  'Support: Open the size guide on the product page for measurements.',
                  'الدعم: افتح دليل المقاسات في صفحة المنتج لمعرفة القياسات.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: context.tr('Type a message', 'اكتب رسالة'),
            ),
          ),
        ],
      ),
    );
  }
}
