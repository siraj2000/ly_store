import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';

class AppSkeletonLoader extends StatefulWidget {
  const AppSkeletonLoader({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 18,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<AppSkeletonLoader> createState() => _AppSkeletonLoaderState();
}

class _AppSkeletonLoaderState extends State<AppSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.slow);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final block = LayoutBuilder(
      builder: (context, constraints) {
        final resolvedHeight = widget.height.isFinite
            ? widget.height
            : (constraints.hasBoundedHeight ? constraints.maxHeight : 120.0);
        final resolvedWidth =
            widget.width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);

        return Bone(
          height: resolvedHeight,
          width: resolvedWidth,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      },
    );

    if (AppMotion.reduceMotion(context)) {
      return Skeletonizer.zone(
        enabled: false,
        containersColor: colors.surfaceSoft,
        child: block,
      );
    }

    return Skeletonizer.zone(
      containersColor: colors.surfaceSoft,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            Opacity(opacity: 0.85 + (_controller.value * 0.15), child: block),
      ),
    );
  }
}
