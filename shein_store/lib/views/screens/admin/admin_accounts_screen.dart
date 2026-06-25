import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_account_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/admin/admin_user_model.dart';
import '../../../views/widgets/common/app_header.dart';
import 'admin_account_details_screen.dart';

class AdminAccountsScreen extends StatelessWidget {
  const AdminAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminAccountController>();
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final accounts = controller.adminUsers;

    return Scaffold(
      appBar: AppHeader(
        title: _tr(context, 'Admin Accounts', 'حسابات الإدارة'),
        actions: [
          IconButton(
            tooltip: _tr(context, 'Refresh', 'تحديث'),
            onPressed: controller.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: controller.isLoading && accounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                _SummaryRow(controller: controller),
                const SizedBox(height: AppSizes.lg),
                if (!controller.canManageAccounts)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      _tr(
                        context,
                        'This account can review admin access details, but only a Super Admin can change account status.',
                        'يمكن لهذا الحساب مراجعة تفاصيل وصول الإدارة، لكن المشرف الأعلى فقط يمكنه تغيير حالة الحساب.',
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSizes.lg),
                TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: _tr(
                      context,
                      'Search by admin name, role, or email',
                      'ابحث باسم المسؤول أو الدور أو البريد',
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterChip(
                      label: _tr(context, 'All', 'الكل'),
                      selected: controller.filter == AdminAccountFilter.all,
                      onTap: () => controller.setFilter(AdminAccountFilter.all),
                    ),
                    _FilterChip(
                      label: _tr(context, 'Active', 'نشط'),
                      selected: controller.filter == AdminAccountFilter.active,
                      onTap: () =>
                          controller.setFilter(AdminAccountFilter.active),
                    ),
                    _FilterChip(
                      label: _tr(context, 'Inactive', 'غير نشط'),
                      selected:
                          controller.filter == AdminAccountFilter.inactive,
                      onTap: () =>
                          controller.setFilter(AdminAccountFilter.inactive),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                if (accounts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      _tr(
                        context,
                        'No admin accounts matched this filter.',
                        'لا توجد حسابات إدارة مطابقة لهذا الفلتر.',
                      ),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ...accounts.map(
                  (account) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: _AdminAccountCard(account: account),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});

  final AdminAccountController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryTile(
          label: _tr(context, 'Admin users', 'المسؤولون'),
          value: '${controller.totalCount}',
          icon: Icons.admin_panel_settings_outlined,
        ),
        _SummaryTile(
          label: _tr(context, 'Active accounts', 'الحسابات النشطة'),
          value: '${controller.activeCount}',
          icon: Icons.verified_user_outlined,
        ),
        _SummaryTile(
          label: _tr(context, 'Inactive accounts', 'الحسابات غير النشطة'),
          value: '${controller.inactiveCount}',
          icon: Icons.pause_circle_outline_rounded,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
          Icon(icon, color: colors.info),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primaryText : colors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? colors.primaryText : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.surface : colors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AdminAccountCard extends StatelessWidget {
  const _AdminAccountCard({required this.account});

  final AdminUserModel account;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminAccountController>();
    final colors = context.appColors;
    final permissions = controller.permissionsFor(account);
    final role = controller.roleFor(account);
    final linkedUser = controller.linkedMarketplaceUser(account);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  AdminAccountDetailsScreen(adminUserId: account.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.surfaceSoft,
                    foregroundColor: colors.primaryText,
                    child: Text(
                      _initialsFor(account.name),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.email,
                          style: TextStyle(color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.secondaryText,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill(
                    label: account.roleName,
                    color: colors.info.withValues(alpha: 0.12),
                    textColor: colors.info,
                  ),
                  _Pill(
                    label: account.isActive
                        ? _tr(context, 'Active', 'نشط')
                        : _tr(context, 'Inactive', 'غير نشط'),
                    color: account.isActive
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.warning.withValues(alpha: 0.12),
                    textColor: account.isActive
                        ? colors.success
                        : colors.warning,
                  ),
                  _Pill(
                    label: _tr(
                      context,
                      '${permissions.length} permissions',
                      '${permissions.length} صلاحيات',
                    ),
                    color: colors.surfaceSoft,
                    textColor: colors.secondaryText,
                  ),
                  if (controller.isCurrentAccount(account))
                    _Pill(
                      label: _tr(context, 'Signed in now', 'مسجل الآن'),
                      color: colors.accent.withValues(alpha: 0.1),
                      textColor: colors.accent,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                role?.description ??
                    _tr(
                      context,
                      'This admin account is ready for marketplace operations.',
                      'هذا الحساب الإداري جاهز لعمليات السوق.',
                    ),
                style: TextStyle(color: colors.secondaryText, height: 1.45),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: _tr(context, 'Linked user', 'الحساب المرتبط'),
                      value: linkedUser?.id ?? '--',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: _tr(context, 'Role type', 'نوع الدور'),
                      value: role?.isReadOnly == true
                          ? _tr(context, 'Read only', 'قراءة فقط')
                          : _tr(context, 'Operational', 'تشغيلي'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: account.isActive,
                onChanged: controller.canManageAccounts
                    ? (_) => _toggleStatus(context, account)
                    : null,
                title: Text(
                  _tr(context, 'Admin account access', 'وصول حساب الإدارة'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  account.isActive
                      ? _tr(
                          context,
                          'This admin can enter the protected admin workspace.',
                          'يمكن لهذا المسؤول دخول مساحة الإدارة المحمية.',
                        )
                      : _tr(
                          context,
                          'This admin is blocked from opening protected admin routes.',
                          'هذا المسؤول محظور من فتح مسارات الإدارة المحمية.',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(
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
            ? _tr(
                context,
                'Admin account deactivated.',
                'تم تعطيل حساب الإدارة.',
              )
            : _tr(
                context,
                'Admin account activated.',
                'تم تفعيل حساب الإدارة.',
              ),
      AdminAccountActionResult.forbidden => _tr(
        context,
        'Only a Super Admin can change admin account status.',
        'فقط المشرف الأعلى يمكنه تغيير حالة حساب الإدارة.',
      ),
      AdminAccountActionResult.notFound => _tr(
        context,
        'Admin account was not found.',
        'لم يتم العثور على حساب الإدارة.',
      ),
      AdminAccountActionResult.protectedAccount => _tr(
        context,
        'At least one active Super Admin must remain available.',
        'يجب أن يبقى مشرف أعلى واحد نشط على الأقل.',
      ),
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
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
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _initialsFor(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  final initials = words.take(2).map((part) => part[0].toUpperCase()).join();
  return initials.isEmpty ? 'A' : initials;
}

String _tr(BuildContext context, String english, String arabic) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? arabic
      : english;
}
