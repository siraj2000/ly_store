import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/profile_menu_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      SettingsController,
      ThemeController,
      AuthController,
      LanguageController
    >(
      builder:
          (
            context,
            settingsController,
            themeController,
            authController,
            languageController,
            _,
          ) {
            final preferences = settingsController.preferences;
            final colors = context.appColors;

            return Scaffold(
              appBar: AppHeader(title: context.l10n.settingsTitle),
              body: ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: [
                  _SettingsPanel(
                    title: context.l10n.settingsPreferences,
                    child: Column(
                      children: [
                        _LanguageSelector(controller: languageController),
                        const SizedBox(height: AppSizes.md),
                        DropdownButtonFormField<String>(
                          initialValue: preferences.country,
                          decoration: InputDecoration(
                            labelText: context.l10n.settingsCountryRegion,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'United States',
                              child: Text(context.l10n.settingsCountryUs),
                            ),
                            DropdownMenuItem(
                              value: 'United Kingdom',
                              child: Text(context.l10n.settingsCountryUk),
                            ),
                            DropdownMenuItem(
                              value: 'UAE',
                              child: Text(context.l10n.settingsCountryUae),
                            ),
                          ],
                          onChanged: (value) =>
                              settingsController.changeCountry(value!),
                        ),
                        const SizedBox(height: AppSizes.md),
                        DropdownButtonFormField<String>(
                          initialValue: preferences.currency,
                          decoration: InputDecoration(
                            labelText: context.l10n.settingsCurrency,
                          ),
                          items: const ['USD', 'EUR', 'GBP']
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              settingsController.changeCurrency(value!),
                        ),
                        const SizedBox(height: AppSizes.md),
                        _ThemeModeSelector(
                          currentMode: themeController.themeMode,
                          onChanged: (mode) {
                            themeController.setThemeMode(mode);
                            settingsController.changeTheme(switch (mode) {
                              ThemeMode.light => 'light',
                              ThemeMode.dark => 'dark',
                              ThemeMode.system => 'system',
                            });
                          },
                        ),
                        SwitchListTile(
                          value: preferences.notificationsEnabled,
                          contentPadding: EdgeInsets.zero,
                          onChanged: settingsController.toggleNotifications,
                          title: Text(
                            context.l10n.settingsNotifications,
                            style: TextStyle(color: colors.primaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: context.l10n.settingsPrivacyPreferences,
                    subtitle: context.l10n.settingsManageVisibility,
                  ),
                  ProfileMenuItem(
                    icon: Icons.cleaning_services_outlined,
                    title: context.l10n.settingsClearCache,
                    subtitle: context.l10n.settingsClearCacheSubtitle,
                  ),
                  ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: context.l10n.settingsAboutApp,
                    subtitle: context.l10n.settingsAboutSubtitle,
                  ),
                  ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: context.l10n.settingsTermsConditions,
                  ),
                  ProfileMenuItem(
                    icon: Icons.shield_outlined,
                    title: context.l10n.settingsPrivacyPolicy,
                  ),
                  if (authController.isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.md),
                      child: OutlinedButton(
                        onPressed: () =>
                            _confirmLogout(context, authController),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.discount,
                          side: BorderSide(color: colors.border),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(
                          context.l10n.commonLogout,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AuthController authController,
  ) async {
    if (!authController.isLoggedIn) {
      return;
    }
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: context.tr('Log out?', 'تسجيل الخروج؟'),
      message: context.tr(
        'Are you sure you want to log out? Your saved account data and cart will not be deleted.',
        'هل أنت متأكد من تسجيل الخروج من حسابك؟ لن يتم حذف السلة أو بيانات الحساب المحفوظة.',
      ),
      cancelLabel: context.tr('Stay', 'البقاء'),
      confirmLabel: context.tr('Log Out', 'تسجيل الخروج'),
      icon: Icons.logout_rounded,
      tone: AppConfirmationTone.warning,
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.controller});

  final LanguageController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsLanguage,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          RadioGroup<AppLanguage>(
            groupValue: controller.selectedLanguage,
            onChanged: (value) async {
              if (value != null) {
                await controller.setLanguage(value);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr('Language changed', 'تم تغيير اللغة'),
                    ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                RadioListTile<AppLanguage>(
                  value: AppLanguage.system,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settingsSystemLanguage),
                ),
                RadioListTile<AppLanguage>(
                  value: AppLanguage.english,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settingsEnglish),
                ),
                RadioListTile<AppLanguage>(
                  value: AppLanguage.arabic,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.languageArabicNative),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsTheme,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          RadioGroup<ThemeMode>(
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.commonSystemDefault),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settingsLightMode),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settingsDarkMode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
