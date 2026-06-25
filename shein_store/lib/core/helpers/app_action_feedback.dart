import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

enum AppFeedbackType { success, error, warning, info }

class AppActionFeedback {
  AppActionFeedback._();

  static void success(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) => _show(context, message, AppFeedbackType.success, action: action);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppFeedbackType.error);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppFeedbackType.warning);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppFeedbackType.info);

  static void undo(
    BuildContext context, {
    required String message,
    required String undoLabel,
    required VoidCallback onUndo,
  }) {
    _show(
      context,
      message,
      AppFeedbackType.info,
      action: SnackBarAction(label: undoLabel, onPressed: onUndo),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    AppFeedbackType type, {
    SnackBarAction? action,
  }) {
    final colors = context.appColors;
    final color = _color(colors, type);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (type == AppFeedbackType.success) {
      HapticFeedback.mediumImpact();
    }
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: action,
        content: Row(
          children: [
            Icon(_icon(type), color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _color(AppThemeColors colors, AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.success:
        return colors.success;
      case AppFeedbackType.error:
        return colors.discount;
      case AppFeedbackType.warning:
        return colors.warning;
      case AppFeedbackType.info:
        return colors.info;
    }
  }

  static IconData _icon(AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.success:
        return Icons.check_circle_outline_rounded;
      case AppFeedbackType.error:
        return Icons.error_outline_rounded;
      case AppFeedbackType.warning:
        return Icons.warning_amber_rounded;
      case AppFeedbackType.info:
        return Icons.info_outline_rounded;
    }
  }
}
