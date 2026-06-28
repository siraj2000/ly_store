import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_skeleton_loader.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.height = 120, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      height: height,
      width: width,
      borderRadius: AppSizes.radius,
    );
  }
}
