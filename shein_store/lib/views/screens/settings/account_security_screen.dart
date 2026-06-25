import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../widgets/common/app_header.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(title: context.tr('Account Security', 'أمان الحساب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SecurityTile(
            icon: Icons.lock_outline_rounded,
            title: context.tr('Password', 'كلمة المرور'),
            subtitle: context.tr(
              'Change password can be connected to the backend later.',
              'يمكن ربط تغيير كلمة المرور بالخادم لاحقاً.',
            ),
          ),
          _SecurityTile(
            icon: Icons.verified_user_outlined,
            title: context.tr('Two-step verification', 'التحقق بخطوتين'),
            subtitle: context.tr(
              'API-ready placeholder for stronger sign-in protection.',
              'جاهز للربط لاحقاً لحماية تسجيل الدخول.',
            ),
          ),
          _SecurityTile(
            icon: Icons.devices_other_outlined,
            title: context.tr('Trusted devices', 'الأجهزة الموثوقة'),
            subtitle: context.tr(
              'Device management can be added when backend sessions exist.',
              'يمكن إضافة إدارة الأجهزة عند توفر جلسات الخادم.',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmDeleteAccount(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.discount,
              side: BorderSide(color: colors.discount.withValues(alpha: 0.45)),
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(context.tr('Delete account', 'حذف الحساب')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final warned = await AppConfirmationDialog.show(
      context,
      title: context.tr('Delete account?', 'حذف الحساب؟'),
      message: context.tr(
        'This action is permanent when connected to the backend. Orders and history may be retained according to policy.',
        'سيكون هذا الإجراء نهائياً عند ربطه بالخادم. قد يتم الاحتفاظ بالطلبات والسجل حسب السياسة.',
      ),
      cancelLabel: context.tr('Cancel', 'إلغاء'),
      confirmLabel: context.tr('Continue', 'متابعة'),
      icon: Icons.warning_amber_rounded,
      tone: AppConfirmationTone.destructive,
      barrierDismissible: false,
    );
    if (!context.mounted || !warned) {
      return;
    }

    final expected = context.isArabic ? 'حذف' : 'DELETE';
    var typed = '';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final colors = dialogContext.appColors;
          final canDelete = typed.trim() == expected;
          return AlertDialog(
            title: Text(dialogContext.tr('Type to confirm', 'اكتب للتأكيد')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogContext.tr(
                    'Type $expected to continue. Account deletion is not connected yet.',
                    'اكتب $expected للمتابعة. حذف الحساب غير مربوط بعد.',
                  ),
                  style: TextStyle(color: colors.secondaryText, height: 1.45),
                ),
                const SizedBox(height: 14),
                TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => typed = value),
                  decoration: InputDecoration(
                    labelText: expected,
                    prefixIcon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogContext.tr('Cancel', 'إلغاء')),
              ),
              FilledButton(
                onPressed: canDelete
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
                style: FilledButton.styleFrom(backgroundColor: colors.discount),
                child: Text(dialogContext.tr('Delete', 'حذف')),
              ),
            ],
          );
        },
      ),
    );
    if (!context.mounted || confirmed != true) {
      return;
    }

    AppActionFeedback.warning(
      context,
      context.tr(
        'Account deletion is not connected yet.',
        'حذف الحساب غير مربوط بعد.',
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.secondaryText, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
