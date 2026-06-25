import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme =>
      _buildTheme(brightness: Brightness.light, colors: AppThemeColors.light);

  static ThemeData get darkTheme =>
      _buildTheme(brightness: Brightness.dark, colors: AppThemeColors.dark);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeColors colors,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.primaryText,
          onPrimary: brightness == Brightness.dark
              ? colors.background
              : colors.surface,
          secondary: colors.accent,
          onSecondary: brightness == Brightness.dark
              ? colors.background
              : colors.surface,
          error: colors.discount,
          onError: brightness == Brightness.dark
              ? colors.background
              : colors.surface,
          surface: colors.surface,
          onSurface: colors.primaryText,
          outline: colors.border,
          outlineVariant: colors.border,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      dividerColor: colors.border,
      splashFactory: InkSparkle.splashFactory,
      extensions: [colors],
      textTheme: AppTextStyles.buildTextTheme(colors),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.icon),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          side: BorderSide(color: colors.border),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: colors.primaryText,
        ),
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.secondaryText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceSoft,
        contentTextStyle: TextStyle(
          color: colors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: colors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        labelStyle: TextStyle(color: colors.secondaryText),
        hintStyle: TextStyle(color: colors.mutedText),
        helperStyle: TextStyle(color: colors.mutedText),
        errorStyle: TextStyle(color: colors.discount),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primaryText, width: 1.1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.discount),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.discount, width: 1.1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.surfaceSoft,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          color: colors.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: colors.primaryText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: colors.primaryText,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: colors.border,
        indicatorColor: colors.primaryText,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colors.primaryText,
        unselectedLabelColor: colors.secondaryText,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.icon,
        textColor: colors.primaryText,
        tileColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: colors.icon),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primaryText,
        foregroundColor: brightness == Brightness.dark
            ? colors.background
            : colors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.bottomNav,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colors.primaryText
                : colors.inactiveIcon,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primaryText
                : colors.inactiveIcon,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: colors.border),
        checkColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? colors.background : colors.surface,
        ),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryText
              : Colors.transparent,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryText
              : colors.inactiveIcon,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.surface
              : colors.mutedText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryText
              : colors.border,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryText,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryText,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size.fromHeight(46),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryText,
          foregroundColor: brightness == Brightness.dark
              ? colors.background
              : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size.fromHeight(46),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primaryText,
          foregroundColor: brightness == Brightness.dark
              ? colors.background
              : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
          ),
        ),
        textStyle: TextStyle(color: colors.primaryText),
      ),
    );
  }
}
