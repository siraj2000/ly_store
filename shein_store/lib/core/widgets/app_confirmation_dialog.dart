import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';

enum AppConfirmationTone { neutral, warning, destructive, purchase, success }

class AppConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    IconData? icon,
    AppConfirmationTone tone = AppConfirmationTone.neutral,
    Widget? details,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => _AppConfirmationDialogBody(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        tone: tone,
        details: details,
      ),
    );
    return result ?? false;
  }
}

class _AppConfirmationDialogBody extends StatefulWidget {
  const _AppConfirmationDialogBody({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.tone,
    this.icon,
    this.details,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final AppConfirmationTone tone;
  final Widget? details;

  @override
  State<_AppConfirmationDialogBody> createState() =>
      _AppConfirmationDialogBodyState();
}

class _AppConfirmationDialogBodyState
    extends State<_AppConfirmationDialogBody> {
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final toneColor = _toneColor(colors, widget.tone);
    final icon = widget.icon ?? _toneIcon(widget.tone);

    return PopScope(
      canPop: !_isConfirming,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1),
                  duration: AppMotion.duration(context, AppMotion.normal),
                  curve: AppMotion.standard,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    alignment: Alignment.center,
                    child: child,
                  ),
                  child: Semantics(
                    label: widget.title,
                    image: true,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: toneColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: toneColor, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.message,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                if (widget.details != null) ...[
                  const SizedBox(height: 16),
                  widget.details!,
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isConfirming
                            ? null
                            : () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(widget.cancelLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isConfirming
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() => _isConfirming = true);
                                Navigator.pop(context, true);
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: toneColor,
                          foregroundColor: _foregroundFor(toneColor),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: AnimatedSwitcher(
                          duration: AppMotion.fast,
                          child: _isConfirming
                              ? const SizedBox(
                                  key: ValueKey('spinner'),
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.confirmLabel,
                                  key: const ValueKey('label'),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _toneColor(AppThemeColors colors, AppConfirmationTone tone) {
    switch (tone) {
      case AppConfirmationTone.warning:
        return colors.warning;
      case AppConfirmationTone.destructive:
        return colors.discount;
      case AppConfirmationTone.purchase:
        return colors.accent;
      case AppConfirmationTone.success:
        return colors.success;
      case AppConfirmationTone.neutral:
        return colors.primaryText;
    }
  }

  IconData _toneIcon(AppConfirmationTone tone) {
    switch (tone) {
      case AppConfirmationTone.warning:
        return Icons.warning_amber_rounded;
      case AppConfirmationTone.destructive:
        return Icons.delete_outline_rounded;
      case AppConfirmationTone.purchase:
        return Icons.shopping_bag_outlined;
      case AppConfirmationTone.success:
        return Icons.check_circle_outline_rounded;
      case AppConfirmationTone.neutral:
        return Icons.help_outline_rounded;
    }
  }

  Color _foregroundFor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : const Color(0xFF111827);
}

class AppConfirmationDetails extends StatelessWidget {
  const AppConfirmationDetails({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class AppConfirmationDetailRow extends StatelessWidget {
  const AppConfirmationDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
