import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_skeleton.dart';

export 'app_skeleton.dart' show AppLoadingLayout;

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.layout = AppLoadingLayout.marketplace,
  });

  final String? message;
  final AppLoadingLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ColoredBox(
      color: colors.background,
      child: AppSkeletonLayout(layout: layout, message: message),
    );
  }
}
