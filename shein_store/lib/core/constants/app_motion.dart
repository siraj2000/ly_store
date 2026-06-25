import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration duration(BuildContext context, Duration value) =>
      reduceMotion(context) ? Duration.zero : value;
}
