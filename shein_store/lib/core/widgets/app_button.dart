import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
  }) : _secondary = false;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
  }) : _secondary = true;

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;
  final bool _secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primaryForeground = context.isDarkMode
        ? colors.background
        : colors.surface;

    final button = SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _secondary ? colors.surface : colors.primaryText,
          foregroundColor: _secondary ? colors.primaryText : primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(
            color: _secondary ? colors.border : colors.primaryText,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
    return isExpanded ? button : IntrinsicWidth(child: button);
  }
}
