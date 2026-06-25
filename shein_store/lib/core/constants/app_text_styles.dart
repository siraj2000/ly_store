import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme buildTextTheme(AppThemeColors colors) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w800,
        color: colors.primaryText,
        height: 1.1,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w800,
        color: colors.primaryText,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      bodyLarge: TextStyle(color: colors.primaryText, height: 1.4),
      bodyMedium: TextStyle(color: colors.primaryText, height: 1.35),
      bodySmall: TextStyle(color: colors.secondaryText, height: 1.35),
      labelLarge: TextStyle(
        color: colors.primaryText,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        color: colors.secondaryText,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        color: colors.mutedText,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
