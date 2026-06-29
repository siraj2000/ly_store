import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_action_feedback.dart';

class AppCopyHelper {
  const AppCopyHelper._();

  static Future<void> copyText(
    BuildContext context, {
    required String text,
    String? feedback,
  }) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    AppActionFeedback.success(
      context,
      feedback ?? AppLocalizations.of(context)!.copied,
    );
  }
}

class AppCopyIconButton extends StatelessWidget {
  const AppCopyIconButton({
    super.key,
    required this.text,
    this.feedback,
    this.tooltip,
    this.iconSize = 20,
  });

  final String text;
  final String? feedback;
  final String? tooltip;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: tooltip ?? l10n.copy,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      iconSize: iconSize,
      onPressed: text.trim().isEmpty
          ? null
          : () =>
                AppCopyHelper.copyText(context, text: text, feedback: feedback),
      icon: const Icon(Icons.copy_rounded),
    );
  }
}
