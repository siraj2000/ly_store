import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  String _country = 'United States';
  AppLanguage _language = AppLanguage.english;
  String _currency = 'USD';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<AuthController>().completeOnboarding();
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _pageIndex = index),
            children: [
              _EditorialPage(
                pageIndex: 0,
                title: l10n.onboardingStartTitle,
                subtitle: l10n.onboardingStartSubtitle,
                primaryLabel: l10n.onboardingStartShopping,
                secondaryLabel: l10n.onboardingSignIn,
                tag: context.tr('NEW SEASON EDIT', 'مجموعة الموسم'),
                heroImage:
                    'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=1000&q=80',
                sideImage:
                    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=700&q=80',
                accent: AppColors.coral,
                metricTop: context.tr('40%', '40%'),
                metricBottom: context.tr('OFF TODAY', 'خصم اليوم'),
                onPrimary: _finish,
                onSecondary: () =>
                    Navigator.pushNamed(context, AppRoutes.login),
              ),
              _PreferencesPage(
                pageIndex: 1,
                country: _country,
                language: _language,
                currency: _currency,
                onCountryChanged: (value) => setState(() => _country = value),
                onLanguageChanged: (value) => setState(() => _language = value),
                onCurrencyChanged: (value) => setState(() => _currency = value),
                onSave: () async {
                  final settings = context.read<SettingsController>();
                  settings.changeCountry(_country);
                  settings.changeCurrency(_currency);
                  await context.read<LanguageController>().setLanguage(
                    _language,
                  );
                  if (!mounted) return;
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
              _EditorialPage(
                pageIndex: 2,
                title: l10n.onboardingStayCloseTitle,
                subtitle: l10n.onboardingStayCloseSubtitle,
                primaryLabel: l10n.onboardingEnableNotifications,
                secondaryLabel: l10n.onboardingNotNow,
                tag: context.tr('DROP ALERTS', 'تنبيهات العروض'),
                heroImage:
                    'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1000&q=80',
                sideImage:
                    'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=700&q=80',
                accent: AppColors.sky,
                metricTop: context.tr('LIVE', 'مباشر'),
                metricBottom: context.tr('SALE ALERTS', 'تنبيهات التخفيض'),
                onPrimary: () {
                  context.read<SettingsController>().toggleNotifications(true);
                  _finish();
                },
                onSecondary: _finish,
              ),
            ],
          ),
          _TopChrome(pageIndex: _pageIndex, onSkip: _finish),
        ],
      ),
    );
  }
}

class _EditorialPage extends StatelessWidget {
  const _EditorialPage({
    required this.pageIndex,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.tag,
    required this.heroImage,
    required this.sideImage,
    required this.accent,
    required this.metricTop,
    required this.metricBottom,
    required this.onPrimary,
    required this.onSecondary,
  });

  final int pageIndex;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final String tag;
  final String heroImage;
  final String sideImage;
  final Color accent;
  final String metricTop;
  final String metricBottom;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0E14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final topHeight = height * 0.62;

          return Stack(
            children: [
              SizedBox(
                height: topHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RemoteImage(url: heroImage, radius: 0),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.42),
                            const Color(0xFF0A0E14),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 22,
                      top: 112,
                      child: _EditorialTag(label: tag),
                    ),
                    PositionedDirectional(
                      end: 22,
                      top: 142,
                      child: _FloatingPhotoCard(
                        imageUrl: sideImage,
                        accent: accent,
                      ),
                    ),
                    PositionedDirectional(
                      start: 22,
                      bottom: 44,
                      child: _MetricBadge(
                        top: metricTop,
                        bottom: metricBottom,
                        accent: accent,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _BottomStoryCard(
                  pageIndex: pageIndex,
                  title: title,
                  subtitle: subtitle,
                  primaryLabel: primaryLabel,
                  secondaryLabel: secondaryLabel,
                  accent: accent,
                  onPrimary: onPrimary,
                  onSecondary: onSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PreferencesPage extends StatelessWidget {
  const _PreferencesPage({
    required this.pageIndex,
    required this.country,
    required this.language,
    required this.currency,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onCurrencyChanged,
    required this.onSave,
  });

  final int pageIndex;
  final String country;
  final AppLanguage language;
  final String currency;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Container(
      color: context.isDarkMode ? AppColors.darkBackground : AppColors.sand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                bottom: constraints.maxHeight * 0.4,
                child: const _PreferenceBackdrop(),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 88, 20, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 112,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EditorialTag(
                          label: context.tr(
                            'PERSONALIZE LY STORE',
                            'خصص LY STORE',
                          ),
                          dark: !context.isDarkMode,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.onboardingPreferencesTitle,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 0.96,
                                letterSpacing: -1.4,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.onboardingPreferencesSubtitle,
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 17,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 34,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _PreferenceSelect<String>(
                                label: l10n.onboardingCountry,
                                icon: Icons.location_on_outlined,
                                value: country,
                                items: [
                                  DropdownMenuItem(
                                    value: 'United States',
                                    child: Text(l10n.settingsCountryUs),
                                  ),
                                  DropdownMenuItem(
                                    value: 'United Kingdom',
                                    child: Text(l10n.settingsCountryUk),
                                  ),
                                  DropdownMenuItem(
                                    value: 'UAE',
                                    child: Text(l10n.settingsCountryUae),
                                  ),
                                ],
                                onChanged: onCountryChanged,
                              ),
                              const SizedBox(height: 12),
                              _PreferenceSelect<AppLanguage>(
                                label: l10n.onboardingLanguage,
                                icon: Icons.translate_rounded,
                                value: language,
                                items: [
                                  DropdownMenuItem(
                                    value: AppLanguage.english,
                                    child: Text(l10n.languageEnglishNative),
                                  ),
                                  DropdownMenuItem(
                                    value: AppLanguage.arabic,
                                    child: Text(l10n.languageArabicNative),
                                  ),
                                ],
                                onChanged: onLanguageChanged,
                              ),
                              const SizedBox(height: 12),
                              _PreferenceSelect<String>(
                                label: l10n.onboardingCurrency,
                                icon: Icons.payments_outlined,
                                value: currency,
                                items: const ['USD', 'EUR', 'GBP']
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: onCurrencyChanged,
                              ),
                              const SizedBox(height: 16),
                              _PreferencePreview(
                                country: country,
                                language: language == AppLanguage.arabic
                                    ? l10n.languageArabicNative
                                    : l10n.languageEnglishNative,
                                currency: currency,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _PageDots(
                          currentIndex: pageIndex,
                          count: 3,
                          dark: true,
                        ),
                        const SizedBox(height: 18),
                        _ActionRow(
                          primaryLabel: l10n.commonSave,
                          secondaryLabel: context.tr('Continue later', 'لاحقا'),
                          accent: AppColors.teal,
                          onPrimary: onSave,
                          onSecondary: onSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomStoryCard extends StatelessWidget {
  const _BottomStoryCard({
    required this.pageIndex,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.accent,
    required this.onPrimary,
    required this.onSecondary,
  });

  final int pageIndex;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final Color accent;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 26, 22, bottomPadding + 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageDots(currentIndex: pageIndex, count: 3, dark: true),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              height: 0.96,
              letterSpacing: -1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF647084),
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _BenefitPill(
                icon: Icons.verified_outlined,
                label: context.tr('Trusted sellers', 'بائعون موثوقون'),
              ),
              const SizedBox(width: 8),
              _BenefitPill(
                icon: Icons.replay_rounded,
                label: context.tr('Easy return', 'إرجاع سهل'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ActionRow(
            primaryLabel: primaryLabel,
            secondaryLabel: secondaryLabel,
            accent: accent,
            onPrimary: onPrimary,
            onSecondary: onSecondary,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.accent,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final Color accent;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              primaryLabel,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              secondaryLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class _RemoteImage extends StatelessWidget {
  const _RemoteImage({required this.url, required this.radius});

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFF202938),
          child: Center(
            child: Icon(Icons.image_outlined, color: Colors.white70, size: 34),
          ),
        ),
      ),
    );
  }
}

class _FloatingPhotoCard extends StatelessWidget {
  const _FloatingPhotoCard({required this.imageUrl, required this.accent});

  final String imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 154,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _RemoteImage(url: imageUrl, radius: 24),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.top,
    required this.bottom,
    required this.accent,
  });

  final String top;
  final String bottom;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            top,
            style: TextStyle(
              color: accent,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bottom,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialTag extends StatelessWidget {
  const _EditorialTag({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.ink : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.08 : 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: dark ? 0.1 : 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceBackdrop extends StatelessWidget {
  const _PreferenceBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PositionedDirectional(
          end: -80,
          top: -80,
          child: _SoftOrb(
            color: AppColors.rose.withValues(alpha: 0.32),
            size: 240,
          ),
        ),
        PositionedDirectional(
          start: -64,
          top: 160,
          child: _SoftOrb(
            color: AppColors.teal.withValues(alpha: 0.22),
            size: 180,
          ),
        ),
        PositionedDirectional(
          end: 34,
          top: 132,
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 128,
              height: 156,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.public_rounded,
                size: 58,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PreferenceSelect<T> extends StatelessWidget {
  const _PreferenceSelect({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: (nextValue) {
        if (nextValue != null) onChanged(nextValue);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: colors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.primaryText, width: 1.4),
        ),
      ),
    );
  }
}

class _PreferencePreview extends StatelessWidget {
  const _PreferencePreview({
    required this.country,
    required this.language,
    required this.currency,
  });

  final String country;
  final String language;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.primaryText,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$country / $language / $currency',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({required this.pageIndex, required this.onSkip});

  final int pageIndex;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onLightPage = pageIndex == 1;
    final foreground = onLightPage ? AppColors.ink : Colors.white;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          children: [
            Text(
              'LY STORE',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.7,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                backgroundColor: foreground.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                l10n.commonSkip,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentIndex,
    required this.count,
    this.dark = false,
  });

  final int currentIndex;
  final int count;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.ink : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: isActive ? 30 : 7,
          height: 7,
          margin: const EdgeInsetsDirectional.only(end: 6),
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
