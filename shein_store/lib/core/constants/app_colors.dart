import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blush = Color(0xFFF4D7D9);
  static const Color rose = Color(0xFFC65D7B);
  static const Color ink = Color(0xFF1D2433);
  static const Color sand = Color(0xFFF7F2EC);
  static const Color teal = Color(0xFF2D8C7A);
  static const Color amber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFFF4D4F);
  static const Color sky = Color(0xFF60A5FA);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFF7F7F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightPrimaryText = Color(0xFF111827);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightMutedText = Color(0xFF9CA3AF);
  static const Color lightAccent = Color(0xFFFF4D4F);
  static const Color lightPrice = Color(0xFFFF4D4F);
  static const Color lightDiscount = Color(0xFFFF3B30);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightIcon = Color(0xFF111827);
  static const Color lightInactiveIcon = Color(0xFF9CA3AF);
  static const Color lightBottomNav = Color(0xFFFFFFFF);
  static const Color lightInputFill = Color(0xFFFFFFFF);
  static const Color lightInfo = Color(0xFF3B82F6);

  static const Color darkBackground = Color(0xFF0B0F14);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceSoft = Color(0xFF1F2937);
  static const Color darkCard = Color(0xFF151C27);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkPrimaryText = Color(0xFFF9FAFB);
  static const Color darkSecondaryText = Color(0xFFD1D5DB);
  static const Color darkMutedText = Color(0xFF9CA3AF);
  static const Color darkAccent = Color(0xFFFF6B6B);
  static const Color darkPrice = Color(0xFFFF6B6B);
  static const Color darkDiscount = Color(0xFFFF4D4F);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkIcon = Color(0xFFF9FAFB);
  static const Color darkInactiveIcon = Color(0xFF9CA3AF);
  static const Color darkBottomNav = Color(0xFF111827);
  static const Color darkInputFill = Color(0xFF151C27);
  static const Color darkInfo = Color(0xFF60A5FA);
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.card,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.accent,
    required this.price,
    required this.discount,
    required this.success,
    required this.warning,
    required this.info,
    required this.icon,
    required this.inactiveIcon,
    required this.bottomNav,
    required this.inputFill,
  });

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color card;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color accent;
  final Color price;
  final Color discount;
  final Color success;
  final Color warning;
  final Color info;
  final Color icon;
  final Color inactiveIcon;
  final Color bottomNav;
  final Color inputFill;

  static const light = AppThemeColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceSoft: AppColors.lightSurfaceSoft,
    card: AppColors.lightCard,
    border: AppColors.lightBorder,
    primaryText: AppColors.lightPrimaryText,
    secondaryText: AppColors.lightSecondaryText,
    mutedText: AppColors.lightMutedText,
    accent: AppColors.lightAccent,
    price: AppColors.lightPrice,
    discount: AppColors.lightDiscount,
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    info: AppColors.lightInfo,
    icon: AppColors.lightIcon,
    inactiveIcon: AppColors.lightInactiveIcon,
    bottomNav: AppColors.lightBottomNav,
    inputFill: AppColors.lightInputFill,
  );

  static const dark = AppThemeColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceSoft: AppColors.darkSurfaceSoft,
    card: AppColors.darkCard,
    border: AppColors.darkBorder,
    primaryText: AppColors.darkPrimaryText,
    secondaryText: AppColors.darkSecondaryText,
    mutedText: AppColors.darkMutedText,
    accent: AppColors.darkAccent,
    price: AppColors.darkPrice,
    discount: AppColors.darkDiscount,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    info: AppColors.darkInfo,
    icon: AppColors.darkIcon,
    inactiveIcon: AppColors.darkInactiveIcon,
    bottomNav: AppColors.darkBottomNav,
    inputFill: AppColors.darkInputFill,
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? card,
    Color? border,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? accent,
    Color? price,
    Color? discount,
    Color? success,
    Color? warning,
    Color? info,
    Color? icon,
    Color? inactiveIcon,
    Color? bottomNav,
    Color? inputFill,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      card: card ?? this.card,
      border: border ?? this.border,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      accent: accent ?? this.accent,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      icon: icon ?? this.icon,
      inactiveIcon: inactiveIcon ?? this.inactiveIcon,
      bottomNav: bottomNav ?? this.bottomNav,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      price: Color.lerp(price, other.price, t)!,
      discount: Color.lerp(discount, other.discount, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      inactiveIcon: Color.lerp(inactiveIcon, other.inactiveIcon, t)!,
      bottomNav: Color.lerp(bottomNav, other.bottomNav, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  AppThemeColors get appColors => theme.extension<AppThemeColors>()!;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
