import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 360);
  static const pageTransition = Duration(milliseconds: 240);
  static const dialogTransition = Duration(milliseconds: 200);
  static const cardStaggerDelay = Duration(milliseconds: 50);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve bounceSoft = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;

  static bool reduceMotion(BuildContext context) =>
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
      (MediaQuery.maybeOf(context)?.accessibleNavigation ?? false);

  static Duration duration(BuildContext context, Duration value) =>
      reduceMotion(context) ? Duration.zero : value;

  static Duration stagger(BuildContext context, int index) {
    if (reduceMotion(context)) {
      return Duration.zero;
    }
    return Duration(
      milliseconds: (cardStaggerDelay.inMilliseconds * index).clamp(0, 240),
    );
  }

  static Offset pageSlideOffset(BuildContext context) {
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return Offset(direction == TextDirection.rtl ? -0.035 : 0.035, 0);
  }
}
