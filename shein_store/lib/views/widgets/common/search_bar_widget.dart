import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.hintText,
    this.onTap,
    this.controller,
    this.onChanged,
    this.readOnly = true,
    this.trailing,
  });

  final String hintText;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      cursorColor: colors.primaryText,
      style: TextStyle(fontSize: 15, color: colors.primaryText),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.mutedText, fontSize: 15),
        prefixIcon: Icon(Icons.search, size: 22, color: colors.inactiveIcon),
        suffixIcon: trailing,
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryText, width: 1.1),
        ),
      ),
    );
  }
}
