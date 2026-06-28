import 'package:flutter/material.dart';

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
    if (AppMotion.reduceMotion(context)) {
      return _SkeletonBlock(
        height: widget.height,
        width: widget.width,
        borderRadius: widget.borderRadius,
        color: colors.surfaceSoft,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.55 + (_controller.value * 0.25);
        return _SkeletonBlock(
          height: widget.height,
          width: widget.width,
          borderRadius: widget.borderRadius,
          color: colors.surfaceSoft.withValues(alpha: opacity),
        );
      },
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.color,
  });

  final double height;
  final double? width;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
