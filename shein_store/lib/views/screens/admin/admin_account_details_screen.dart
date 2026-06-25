import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_account_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/locale_formatters.dart';
import '../../../models/admin/admin_user_model.dart';
import '../../../views/widgets/common/app_header.dart';

class AdminAccountDetailsScreen extends StatelessWidget {
  const AdminAccountDetailsScreen({super.key, required this.adminUserId});

  final String adminUserId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminAccountController>();
    final account = controller.adminUserById(adminUserId);

    return Scaffold(
      appBar: AppHeader(title: _tr(context, 'Admin Details', 'تفاصيل الإدارة')),
      body: account == null
          ? Center(
              child: Text(
                _tr(
                  context,
                  'Admin account could not be loaded.',
                  'تعذر تحميل حساب الإدارة.',
                ),
              ),
            )
          : _AdminDetailsBody(account: account),
    );
  }
}

class _AdminDetailsBody extends StatelessWidget {
  const _AdminDetailsBody({required this.account});

  final AdminUserModel account;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminAccountController>();
    final colors = context.appColors;
    final role = controller.roleFor(account);
    final permissions = controller.permissionsFor(account);
    final auditLogs = controller.auditLogsFor(account);
    final linkedUser = controller.linkedMarketplaceUser(account);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.info.withValues(alpha: 0.18), colors.surfaceSoft],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                account.email,
                style: TextStyle(color: colors.secondaryText),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Tag(
                    label: account.roleName,
                    backgroundColor: colors.surface,
                    foregroundColor: colors.primaryText,
                  ),
                  _Tag(
                    label: account.isActive
                        ? _tr(context, 'Active', 'نشط')
                        : _tr(context, 'Inactive', 'غير نشط'),
                    backgroundColor: account.isActive
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.warning.withValues(alpha: 0.12),
                    foregroundColor: account.isActive
                        ? colors.success
                        : colors.warning,
                  ),
                  if (controller.isCurrentAccount(account))
                    _Tag(
                      label: _tr(context, 'Signed in account', 'الحساب الحالي'),
                      backgroundColor: colors.accent.withValues(alpha: 0.12),
                      foregroundColor: colors.accent,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                role?.description ??
                    _tr(
                      context,
                      'Marketplace admin account for operational controls.',
                      'حساب إدارة للسوق مخصص لعناصر التحكم التشغيلية.',
                    ),
                style: TextStyle(color: colors.secondaryText, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _DetailsGrid(account: account),
        const SizedBox(height: AppSizes.lg),
        if (controller.canManageAccounts)
          FilledButton.icon(
            onPressed: () => _toggleAccount(context, account),
            icon: Icon(
              account.isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
            ),
            label: Text(
              account.isActive
                  ? _tr(
                      context,
                      'Deactivate Admin Access',
                      'تعطيل وصول الإدارة',
                    )
                  : _tr(context, 'Activate Admin Access', 'تفعيل وصول الإدارة'),
            ),
          ),
        if (controller.canManageAccounts) const SizedBox(height: AppSizes.lg),
        _SectionTitle(
          title: _tr(context, 'Permission coverage', 'نطاق الصلاحيات'),
          subtitle: _tr(
            context,
            '${permissions.length} assigned permissions across the admin workspace.',
            '${permissions.length} صلاحية مخصصة عبر مساحة الإدارة.',
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: permissions
              .map(
                (permission) => _Tag(
                  label: permission.id,
                  backgroundColor: colors.surfaceSoft,
                  foregroundColor: colors.secondaryText,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSizes.xl),
        _SectionTitle(
          title: _tr(context, 'Recent audit activity', 'آخر نشاط تدقيقي'),
          subtitle: _tr(
            context,
            'Access changes and administrative actions tied to this account.',
            'تغييرات الوصول والإجراءات الإدارية المرتبطة بهذا الحساب.',
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (auditLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: Text(
              _tr(
                context,
                'No audit entries are recorded for this account yet.',
                'لا توجد سجلات تدقيق لهذا الحساب حتى الآن.',
              ),
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
        ...auditLogs.map(
          (log) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.action,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        formatShortDate(context, log.timestamp),
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${log.adminName} • ${log.result}',
                    style: TextStyle(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (linkedUser != null)
          Text(
            _tr(
              context,
              'Linked marketplace record: ${linkedUser.id}',
              'سجل السوق المرتبط: ${linkedUser.id}',
            ),
            style: TextStyle(color: colors.secondaryText),
          ),
      ],
    );
  }

  Future<void> _toggleAccount(
    BuildContext context,
    AdminUserModel account,
  ) async {
    final controller = context.read<AdminAccountController>();
    final result = await controller.toggleAccountStatus(account);
    if (!context.mounted) {
      return;
    }
    final message = switch (result) {
      AdminAccountActionResult.success =>
        account.isActive
            ? _tr(context, 'Admin access disabled.', 'تم تعطيل وصول الإدارة.')
            : _tr(context, 'Admin access enabled.', 'تم تفعيل وصول الإدارة.'),
      AdminAccountActionResult.forbidden => _tr(
        context,
        'Only a Super Admin can update admin access.',
        'فقط المشرف الأعلى يمكنه تحديث وصول الإدارة.',
      ),
      AdminAccountActionResult.notFound => _tr(
        context,
        'Admin account not found.',
        'لم يتم العثور على حساب الإدارة.',
      ),
      AdminAccountActionResult.protectedAccount => _tr(
        context,
        'You must keep one active Super Admin account.',
        'يجب الإبقاء على حساب مشرف أعلى واحد نشط.',
      ),
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.account});

  final AdminUserModel account;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminAccountController>();
    final role = controller.roleFor(account);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _DetailTile(
          label: _tr(context, 'Role type', 'نوع الدور'),
          value: role?.isReadOnly == true
              ? _tr(context, 'Read only', 'قراءة فقط')
              : _tr(context, 'Operational', 'تشغيلي'),
        ),
        _DetailTile(
          label: _tr(context, 'Linked user id', 'معرف المستخدم المرتبط'),
          value: account.userId,
        ),
        _DetailTile(
          label: _tr(context, 'Permission count', 'عدد الصلاحيات'),
          value: '${account.permissionIds.length}',
        ),
        _DetailTile(
          label: _tr(context, 'Last login', 'آخر تسجيل دخول'),
          value: account.lastLoginAt == null
              ? _tr(context, 'Not recorded yet', 'غير مسجل بعد')
              : formatShortDate(context, account.lastLoginAt!),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: colors.secondaryText)),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _tr(BuildContext context, String english, String arabic) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}
