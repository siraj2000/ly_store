import 'package:flutter/material.dart';

import '../constants/app_motion.dart';

class AnimatedPageWrapper extends StatelessWidget {
  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset,
  });

  final Widget child;
  final Duration delay;
  final Offset? beginOffset;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.duration(context, AppMotion.normal + delay),
      curve: AppMotion.standard,
      builder: (context, value, child) {
        final easedValue = value.clamp(0.0, 1.0);
        final offset = Offset.lerp(
          beginOffset ?? const Offset(0, 0.025),
          Offset.zero,
          easedValue,
        )!;
        return Opacity(
          opacity: easedValue,
          child: FractionalTranslation(translation: offset, child: child),
        );
      },
      child: child,
    );
  }
}
